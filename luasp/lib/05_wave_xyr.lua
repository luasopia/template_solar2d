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
local peak0 = 100 -- default peak for x and y
--------------------------------------------------------------------------------
local luasp = _luasopia
local sin, exp, _2PI = math.sin, math.exp, 2*math.pi
local Disp = luasp.Display
local nilfunc = luasp.nilfunc
local INF = INF
--------------------------------------------------------------------------------

-- waveX(), waveY(), waveRot()에서 공통으로 사용되는 함수
local function getInfo(attr0,opt)

    opt = opt or {}

    local period = opt.period or period0
    local peak1 = opt.peak or peak0 -- top peak value
    local peak2 = opt.peak2 or -peak1 -- bottom peak value
    local cntr = (peak1+peak2)*0.5
    local ampl = (peak1-peak2)*0.5
    local tau = _2PI/period -- time constanst
    local endTime = (opt.loops or INF)*period

    return {
        attr0 = attr0,
        time = 0, -- 시작시간
        period= period,
        tau = tau,  -- time constant
        ampl = ampl, -- amplitude of sine wave
        cntr = cntr,  -- center of sine wave
        endTime = endTime,
        onEnd = opt.onEnd or nilfunc,
        endTmC = tau*endTime
    }

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function waveXupd(self)

    local wvx = self.__wvx
    wvx.time = wvx.time + tmgap
    local tt = wvx.tau*wvx.time

    if wvx.endTime == INF then
        local dx = wvx.cntr*(1-exp(-tt)) + wvx.ampl*sin(tt)
        self:setX(wvx.attr0 + dx )
    else
        -- 원공식:     cntr*( 1-exp(-tau*t)-exp(tau*(t-endTime)) ) + ampl*sin(tau*t)
        -- 계산향상식: cntr*( 1-exp(-tt)-exp(tt-endTmC) ) + ampl*sin(tt)   where tt = tau*t
        local dx = wvx.cntr*( 1-exp(-tt)-exp(tt-wvx.endTmC) ) + wvx.ampl*sin(tt)
        self:setX(wvx.attr0 + dx )
    end

    if wvx.time >= wvx.endTime then
        self:stopWaveX(true)
        if wvx.onEnd then wvx.onEnd(self) end
    end

end


function Disp:waveX(opt)
    
    self:stopWaveX() -- 현재 실행중인 waveRot()(가 있다면) 중지
    self.__wvx = getInfo(self:getX(),opt)
    self.__iupds[waveXupd] = waveXupd
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveX(isTo0)

    self.__iupds[waveXupd] = nil
    if isTo0 and self.__wvx then  self:setX(self.__wvx.attr0)  end
    self.__wvx = nil
    return self

end    


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function waveYupd(self)

    local wvy = self.__wvy
    wvy.time = wvy.time + tmgap
    local tt = wvy.tau*wvy.time

    if wvy.endTime == INF then
        local dy = wvy.cntr*(1-exp(-tt)) + wvy.ampl*sin(tt)
        self:setY(wvy.attr0 + dy )
    else
        -- 원공식:     cntr*( 1-exp(-tau*t)-exp(tau*(t-endTime)) ) + ampl*sin(tau*t)
        -- 계산향상식: cntr*( 1-exp(-tt)-exp(tt-endTmC) ) + ampl*sin(tt)   where tt = tau*t
        local dy = wvy.cntr*( 1-exp(-tt)-exp(tt-wvy.endTmC) ) + wvy.ampl*sin(tt)
        self:setY(wvy.attr0 + dy )
    end

    if wvy.time >= wvy.endTime then
        self:stopWaveY(true)
        if wvy.onEnd then wvy.onEnd(self) end
    end

end


function Disp:waveY(opt)
    
    self:stopWaveY() -- 현재 실행중인 waveRot()(가 있다면) 중지
    self.__wvy = getInfo(self:getY(), opt)
    self.__iupds[waveYupd] = waveYupd
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveY(isTo0)

    self.__iupds[waveYupd] = nil
    if isTo0 and self.__wvy then  self:setY(self.__wvy.attr0)  end
    self.__wvy = nil
    return self

end    



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function waveRupd(self)

    local wvr = self.__wvr
    wvr.time = wvr.time + tmgap
    local tt = wvr.tau*wvr.time

    if wvr.endTime == INF then
        local dr = wvr.cntr*(1-exp(-tt)) + wvr.ampl*sin(tt)
        self:setRot(wvr.attr0 + dr )
    else
        -- 원공식:     cntr*( 1-exp(-tau*t)-exp(tau*(t-endTime)) ) + ampl*sin(tau*t)
        -- 계산향상식: cntr*( 1-exp(-tt)-exp(tt-endTmC) ) + ampl*sin(tt)   where tt = tau*t
        local dr = wvr.cntr*( 1-exp(-tt)-exp(tt-wvr.endTmC) ) + wvr.ampl*sin(tt)
        self:setRot(wvr.attr0 + dr )
    end

    if wvr.time >= wvr.endTime then
        self:stopWaveRot(true)
        if wvr.onEnd then wvr.onEnd(self) end
    end

end


function Disp:waveRot(opt)
    
    self:stopWaveRot() -- 현재 실행중인 waveRot()(가 있다면) 중지
    self.__wvr = getInfo(self:getRot(), opt)
    self.__iupds[waveRupd] = waveRupd
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveRot(isTo0)

    self.__iupds[waveRupd] = nil
    if isTo0 and self.__wvr then  self:setRot(self.__wvr.attr0)  end
    self.__wvr = nil
    return self

end    


