--------------------------------------------------------------------------------
local luasp = _luasopia
local sin, exp, _2PI,cos = math.sin, math.exp, 2*math.pi, math.cos
local Disp = luasp.Display
local nilfunc = luasp.nilfunc
local INF = INF
local tmgap = 1000/screen.fps -- 매frame마다 갱신
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 2022/08/27(created) 
--------------------------------------------------------------------------------
--[[-----------------------------------------------------------------------------
-- dobj:waveScale(opt)
-- opt= {
        peak (default:100)          첨두값
        peak2 (default:-peak)       첨두값2
        period (in ms, default:1000 ms) 주기
        loops (default:INF)             반복횟수
        onEnd (function)
}
-- dobj:stopWaveScale(true/false) : 인수가 true이면 원래 각도를 회복

사용예: 시작시의 scale을 s0라고 하면 항상 peak로 지정된 곳으로 맨 먼저 향한다.
    d:waveScale{peak=1.2} s0*(1.2~1) 사이를 진동, 1.2로 먼저 간다
    d:waveScale{peak=0.5} s0*(1~0.5) 사이를 진동, 0.5로 먼저 간다
    d:waveScale{peak=1.2, peak2=0.5} s0*(1.2~0.5)사이를 진동, 1.2으로 먼저 간다
    d:waveScale{peak=0,5, peak2=1,2} s0*(0.5~1.2)사이를 진동, 0.5으로 먼저 간다
------------------------------------------------------------------------------]]

--------------------------------------------------------------------------------
local periodRot0 = 1000 -- ms default period for x and y
local periodAlpha0 = 1000 -- ms default period for x and y
local peakRot0 = 1.1 -- default peak for x and y


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
    
    local period = opt.period or periodRot0
    local peak1 = opt.peak or peakRot0 -- top peak value
    local peak2 = opt.peak2 or 1 -- bottom peak value
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
        _1_cntr = 1-cntr -- waveSUpd() 내부 연산에 사용되는 상수
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


--------------------------------------------------------------------------------
--[[----------------------------------------------------------------------------
-- dobj:waveAlpha(opt)
-- opt= {
    peak (default:100)          첨두값
    period (in ms, default:1000 ms) 주기
    loops (default:INF)             반복횟수
    onEnd
}
-- dobj:stopWaveRot(true/false) : 인수가 true이면 원래 각도를 회복

사용예: peak는 현재 alpha값(attr0<=1)보다 작은 값
d:wave()            attr0 ~ 0  사이를 진동
d:wave{peak=0.5}    attr0 ~ 0.5  사이를 진동
------------------------------------------------------------------------------]]

local function waveAupd(self)

    local wva = self.__wva
    wva.time = wva.time + tmgap
    local tt = wva.tau*wva.time

    if wva.endTime == INF then
        -- local da = wva.cntr*(1-exp(-tt)) + wva.ampl*sin(tt)
        local da = wva.cntr + wva.ampl*cos(tt)
        self:setAlpha(da)
    else
        -- 원공식:     cntr*( 1-exp(-tau*t)-exp(tau*(t-endTime)) ) + ampl*sin(tau*t)
        -- 계산향상식: cntr*( 1-exp(-tt)-exp(tt-endTmC) ) + ampl*sin(tt)   where tt = tau*t
        local da = wva.cntr + wva.ampl*cos(tt)
        self:setAlpha(da)
    end

    if wva.time >= wva.endTime then
        self:stopWaveAlpha(true)
        if wva.onEnd then wva.onEnd(self) end
    end

end


function Disp:waveAlpha(opt)
    
    opt = opt or {}
    
    self:stopWaveAlpha() -- 현재 실행중인 waveRot()(가 있다면) 중지
    
    local attr0 = self:getAlpha()

    local period = opt.period or periodAlpha0
    local peak1 = attr0 -- top peak value
    local peak2 = opt.peak or 0 -- bottom peak value
    local cntr = (peak1+peak2)*0.5
    local ampl = (peak1-peak2)*0.5
    local tau = _2PI/period -- time constanst
    local endTime = (opt.loops or INF)*period

    local wva = {
        attr0 = attr0, -- original attribute
        time = 0,                -- 시작시간
        period= period,          -- 주기
        tau = tau,               -- time constant
        ampl = ampl,            -- amplitude of sine wave
        cntr = cntr,            -- center of sine wave
        endTime = endTime,
        onEnd = opt.onEnd or nilfunc,
        endTmC = tau*endTime,
        _1_cntr = 1-cntr -- waveSUpd() 내부 연산에 사용되는 상수
    }
    -- puts(wvs.cntr, wvs.ampl, wvs.endTime)
    self.__wva = wva
    self.__iupds[waveAupd] = waveAupd
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveAlpha(isTo0)

    self.__iupds[waveAupd] = nil
    if isTo0 and self.__wva then  self:setAlpha(self.__wva.attr0)  end
    self.__wva = nil
    return self

end    