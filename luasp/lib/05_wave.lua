--------------------------------------------------------------------------------
-- 2022/08/27(created) 
--------------------------------------------------------------------------------
local luasp = _luasopia
local sin, exp, _2PI, cos = math.sin, math.exp, 2*math.pi, math.cos
local Disp = luasp.Display
local nilfunc = luasp.nilfunc
local INF = INF
local tmgap = 1000/screen.fps -- 매frame마다 갱신
--------------------------------------------------------------------------------
local period0 = 1000 -- ms default period for all attributes
local peak0 = 100 -- default peak for x, y, and rot
--------------------------------------------------------------------------------
--[[-----------------------------------------------------------------------------
-- dobj:waveX(opt), waveY(opt), waveRot(opt)
-- opt= {
        peak (default:100)          첨두값
        peak2 (default:-peak)       첨두값2
        period (in ms, default:1000 ms) 주기
        loops (default:INF)             반복횟수
        onEnd
        phase (in ms)
}
-- dobj:stopWaveX(true/false) : 인수가 true이면 원래 각도를 회복
-- dobj:stopWaveY(true/false) : 인수가 true이면 원래 각도를 회복
-- dobj:stopWaveRot(true/false) : 인수가 true이면 원래 각도를 회복

사용 예:  항상 peak로 지정된 곳으로 맨 먼저 향한다.
        시작시의 값을 attr0라고 하면

    d:waveX(peak=20) attr0+(20~0) 사이를 진동, 20으로 먼저 간다
    d:waveX(peak=-30) attr0+(-30~0) 사이를 진동, -30으로 먼저 간다
    d:waveX(peak=20, peak2=90) attr0+(20~90)사이를 진동, 20으로 먼저 간다
    d:waveX(peak=-90, peak2=180) attr0+(-90~180)사이를 진동, -90으로 먼저 간다
------------------------------------------------------------------------------]]

-- waveX(), waveY(), waveRot()에서 공통으로 사용되는 함수
local function getInfo(attr0,opt)

    opt = opt or {}

    local period = opt.period or period0
    local peak1 = opt.peak or peak0 -- top peak value
    local peak2 = opt.peak2 or 0 -- bottom peak value
    local cntr = (peak1+peak2)*0.5
    local ampl = (peak1-peak2)*0.5
    local tau = _2PI/period -- time constanst
    local endTime = (opt.loops or INF)*period

    return {
        attr0 = attr0,
        time = opt.phase or 0, -- 시작시간
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
    if wvx == nil then return end

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
    self.__wvx = getInfo(self.__bdx,opt)
    -- upd()를 추가할 때는 반드시 self.__addUpd__()메서드로 해야한다.
    self:__addUpd__(waveXupd)
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveX(isTo0)

    self:__rmUpd__(waveXupd)
    if isTo0 and self.__wvx then  self:setX(self.__wvx.attr0)  end
    self.__wvx = nil
    return self

end    


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function waveYupd(self)
   

    local wvy = self.__wvy
    if wvy==nil then return end

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
    self.__wvy = getInfo(self.__bdy, opt)
    self:__addUpd__(waveYupd)
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveY(isTo0)

    self:__rmUpd__(waveYupd)
    if isTo0 and self.__wvy then  self:setY(self.__wvy.attr0)  end
    self.__wvy = nil
    return self

end    



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function waveRupd(self)
    
    local wvr = self.__wvr
    if wvr==nil then return end


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
    self.__wvr = getInfo(self.__bdrd, opt)
    self:__addUpd__(waveRupd)
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveRot(isTo0)

    self:__rmUpd__(waveRupd)
    if isTo0 and self.__wvr then  self:setRot(self.__wvr.attr0)  end
    self.__wvr = nil
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

사용예: peak는 현재 alpha값(a0<=1)보다 작은 값
d:wave()            a0 ~ 0  사이를 진동
d:wave{peak=0.5}    a0 ~ 0.5  사이를 진동
------------------------------------------------------------------------------]]

local function waveAupd(self)

    local wva = self.__wva
    if wva == nil then return end

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
    
    local attr0 = self.__bda

    local period = opt.period or period0
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
    self:__addUpd__(waveAupd)
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveAlpha(isTo0)

    self:__rmUpd__(waveAupd)
    if isTo0 and self.__wva then  self:setAlpha(self.__wva.attr0)  end
    self.__wva = nil
    return self

end    


--------------------------------------------------------------------------------
-- 2022/08/28, 2022/09/04 programmed
--------------------------------------------------------------------------------
--[[-----------------------------------------------------------------------------
-- dobj:waveScale(opt), dobj:waveScaleX(opt), dobj:waveScaleY(opt)
-- opt= {
        peak (default:100)          첨두값
        peak2 (default:-peak)       첨두값2
        period (in ms, default:1000 ms) 주기
        loops (default:INF)             반복횟수
        onEnd (function)
        phase
}
-- dobj:stopWaveScale(true/false) : 인수가 true이면 원래 각도를 회복

사용예: 시작시의 scale을 s0라고 하면 항상 peak로 지정된 곳으로 맨 먼저 향한다.
    d:waveScale{peak=1.2} s0*(1.2~1) 사이를 진동, 1.2로 먼저 간다
    d:waveScale{peak=0.5} s0*(1~0.5) 사이를 진동, 0.5로 먼저 간다
    d:waveScale{peak=1.2, peak2=0.5} s0*(1.2~0.5)사이를 진동, 1.2으로 먼저 간다
    d:waveScale{peak=0,5, peak2=1,2} s0*(0.5~1.2)사이를 진동, 0.5으로 먼저 간다
------------------------------------------------------------------------------]]

local peakScale0 = 1.1 -- default peak for scale

--------------------------------------------------------------------------------

-- waveScale(), waveScaleX(), waveScaleY()에서 공통으로 사용되는 함수
local function getWVS(attr0,opt)

    opt = opt or {}
    local period = opt.period or period0
    local peak1 = opt.peak or peakScale0 -- top peak value
    local peak2 = opt.peak2 or 1 -- bottom peak value
    local cntr = (peak1+peak2)*0.5
    local ampl = (peak1-peak2)*0.5
    local tau = _2PI/period -- time constanst
    local endTime = (opt.loops or INF)*period

    local wvs = {
        attr0 = attr0, -- original attribute
        time = opt.phase or 0,                -- 시작시간
        period= period,          -- 주기
        tau = tau,               -- time constant
        ampl = ampl,            -- amplitude of sine wave
        cntr = cntr,            -- center of sine wave
        endTime = endTime,
        onEnd = opt.onEnd or nilfunc,
        endTmC = tau*endTime,
        _1_cntr = 1-cntr -- waveSUpd() 내부 연산에 사용되는 상수
    }

    return wvs

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function waveSupd(self)

    local wvs = self.__wvs
    if wvs == nil then return end


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
    
    self:stopWaveScale() -- 현재 실행중인 waveRot()(가 있다면) 중지
    self.__wvs = getWVS(self.__bds,opt)
    self:__addUpd__(waveSupd)
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveScale(isTo0)

    self:__rmUpd__(waveSupd)
    if isTo0 and self.__wvs then  self:setScale(self.__wvs.attr0)  end
    self.__wvs = nil
    return self

end    


--------------------------------------------------------------------------------
-- 2022/09/04 programmed
--------------------------------------------------------------------------------


local function waveSXupd(self)

    local wvsx = self.__wvsx
    if wvsx == nil then return end


    wvsx.time = wvsx.time + tmgap
    local tt = wvsx.tau*wvsx.time

    if wvsx.endTime == INF then
        -- (1-wvs.cntr)*exp(-tt) + wvs.cntr + wvs.ampl*sin(tt)
        -- where tt = tau*t, _1_cntr == 1-wvs.sntr
        -- (1-wvs.cntr)*exp(-tt)+wvs.cntr : 1 → cntr 로 변화
        local dsx =  wvsx._1_cntr*exp(-tt) + wvsx.cntr + wvsx.ampl*sin(tt)
        self:setScaleX(wvsx.attr0*dsx)
    else
        -- (1-wvs.cntr)*(exp(-tt)+exp(tt-wvs.endTmC) ) + wvs.cntr + wvs.ampl*sin(tt)
        -- where tt = tau*t, _1_cntr == 1-wvs.sntr
        -- (1-wvs.cntr)*(exp(-tt)+exp(tt-wvs.endTmC))+wvs.cntr : 1 → cntr → 1 순서로 변화
        local dsx = wvsx._1_cntr*(exp(-tt)+exp(tt-wvsx.endTmC) ) + wvsx.cntr + wvsx.ampl*sin(tt)
        self:setScaleX(wvsx.attr0*dsx)
    end

    if wvsx.time >= wvsx.endTime then
        self:stopWaveScaleX(true)
        if wvsx.onEnd then wvsx.onEnd(self) end
    end

end


function Disp:waveScaleX(opt)
    
    self:stopWaveScaleX() -- 현재 실행중인 waveRot()(가 있다면) 중지
    self.__wvsx = getWVS(self.__bdxs,opt)
    self:__addUpd__(waveSXupd)
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveScaleX(isTo0)

    self:__rmUpd__(waveSXupd)
    if isTo0 and self.__wvsx then  self:setScaleX(self.__wvsx.attr0)  end
    self.__wvsx = nil
    return self

end    

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function waveSYupd(self)

    local wvsy = self.__wvsy
    if wvsy == nil then return end


    wvsy.time = wvsy.time + tmgap
    local tt = wvsy.tau*wvsy.time

    if wvsy.endTime == INF then
        -- (1-wvs.cntr)*exp(-tt) + wvs.cntr + wvs.ampl*sin(tt)
        -- where tt = tau*t, _1_cntr == 1-wvs.sntr
        -- (1-wvs.cntr)*exp(-tt)+wvs.cntr : 1 → cntr 로 변화
        local dsy =  wvsy._1_cntr*exp(-tt) + wvsy.cntr + wvsy.ampl*sin(tt)
        self:setScaleY(wvsy.attr0*dsy)
    else
        -- (1-wvs.cntr)*(exp(-tt)+exp(tt-wvs.endTmC) ) + wvs.cntr + wvs.ampl*sin(tt)
        -- where tt = tau*t, _1_cntr == 1-wvs.sntr
        -- (1-wvs.cntr)*(exp(-tt)+exp(tt-wvs.endTmC))+wvs.cntr : 1 → cntr → 1 순서로 변화
        local dsy = wvsy._1_cntr*(exp(-tt)+exp(tt-wvsy.endTmC) ) + wvsy.cntr + wvsy.ampl*sin(tt)
        self:setScaleY(wvsy.attr0*dsy)
    end

    if wvsy.time >= wvsy.endTime then
        self:stopWaveScaleY(true)
        if wvsy.onEnd then wvsy.onEnd(self) end
    end

end


function Disp:waveScaleY(opt)
    
    self:stopWaveScaleY() -- 현재 실행중인 waveRot()(가 있다면) 중지
    self.__wvsy = getWVS(self.__bdys, opt)    
    self:__addUpd__(waveSYupd)
    return self

end


-- loops로 지정된 횟수가 다 됐을 때 stopWaveRot(true)가 호출되고 원래의 각도로 다시 설정됨
-- stopWaveRot()로 호출되고 원래의 각도로 되돌아가지 않고 현재 각도를 유지
function Disp:stopWaveScaleY(isTo0)

    self:__rmUpd__(waveSYupd)
    if isTo0 and self.__wvsy then  self:setScaleY(self.__wvsy.attr0)  end
    self.__wvsy = nil
    return self

end