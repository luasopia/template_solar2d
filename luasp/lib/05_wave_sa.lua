--------------------------------------------------------------------------------
-- 2022/08/27(created) 
--------------------------------------------------------------------------------
--[[-----------------------------------------------------------------------------
-- dobj:waveRot(opt)
-- opt= {
        peak (default:100)          첨두값
        peak2 (default:-peak)       첨두값2
        period (in ms, default:1000 ms) 주기
        loops (default:INF)             반복횟수
        onEnd
}
-- dobj:stopWaveRot(true/false) : 인수가 true이면 원래 각도를 회복

사용예: 항상 peak로 지정된 곳으로 맨 먼저 향한다.
    d:wave(peak=20) +-20사이를 진동, 20으로 먼저 간다
    d:wave(peak=-30) +-30사이를 진동, -30으로 먼저 간다
    d:wave(peak=20, peak2=90) 20~90사이를 진동, 20으로 먼저 간다
    d:wave(peak=-90, peak2=180) -90~180사이를 진동, -90으로 먼저 간다
------------------------------------------------------------------------------]]
--------------------------------------------------------------------------------
local tmgap = 1000/screen.fps -- 매frame마다 갱신
local period0 = 1000 -- ms default period for x and y
local peak0 = 1.1 -- default peak for x and y
--------------------------------------------------------------------------------
local luasp = _luasopia
local sin, exp, _2PI = math.sin, math.exp, 2*math.pi
local Disp = luasp.Display
local nilfunc = luasp.nilfunc
local INF = INF
--------------------------------------------------------------------------------


local function waveSupd(self)

    local wvs = self.__wvs
    wvs.time = wvs.time + tmgap
    local tt = wvs.tau*wvs.time

    if wvs.endTime == INF then
        -- (1-wvs.cntr)*exp(-tt) + wvs.cntr + wvs.ampl*sin(tt)
        -- where tt = tau*t, _1_cntr == 1-wvs.sntr
        -- (1-wvs.cntr)*exp(-tt)+wvs.cntr : 1 → cntr 로 변화
        local ds =  wvs._1_cntr*exp(-tt) + wvs.cntr + wvs.ampl*sin(tt)
        self:setScale(wvs.attr0*ds)
    else
        -- (1-wvs.cntr)*(exp(-tt)+exp(tt-wvs.endTmC) ) + wvs.cntr + wvs.ampl*sin(tt)
        -- where tt = tau*t, _1_cntr == 1-wvs.sntr
        -- (1-wvs.cntr)*(exp(-tt)+exp(tt-wvs.endTmC))+wvs.cntr : 1 → cntr → 1 순서로 변화
        local ds = wvs._1_cntr*(exp(-tt)+exp(tt-wvs.endTmC) ) + wvs.cntr + wvs.ampl*sin(tt)
        self:setScale(wvs.attr0*ds)
    end

    if wvs.time >= wvs.endTime then
        self:stopWaveScale(true)
        if wvs.onEnd then wvs.onEnd(self) end
    end

end


function Disp:waveScale(opt)
    
    opt = opt or {}
    
    self:stopWaveScale() -- 현재 실행중인 waveRot()(가 있다면) 중지
    
    local period = opt.period or period0
    local peak1 = opt.peak or peak0 -- top peak value
    local peak2 = opt.peak2 or (2-peak1) -- bottom peak value
    local cntr = (peak1+peak2)*0.5
    local ampl = (peak1-peak2)*0.5
    local tau = _2PI/period -- time constanst
    local endTime = (opt.loops or INF)*period

    local wvs = {
        attr0 = self:getScale(), -- original attribute
        time = 0,                -- 시작시간
        period= period,          -- 주기
        tau = tau,               -- time constant
        ampl = ampl,            -- amplitude of sine wave
        cntr = cntr,            -- center of sine wave
        endTime = endTime,
        onEnd = opt.onEnd or nilfunc,
        endTmC = tau*endTime,
        -- tmc2 = 0.74*tmConst  -- 0.74 endTime이 inf가 아닐 때 사용된다.
        _1_cntr = 1-cntr
    }
    -- puts(wvs.cntr, wvs.ampl, wvs.endTime)
    self.__wvs = wvs
    self.__iupds[waveSupd] = waveSupd
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveScale(isTo0)

    self.__iupds[waveSupd] = nil
    if isTo0 and self.__wvs then  self:setScale(self.__wvs.attr0)  end
    self.__wvs = nil
    return self

end    