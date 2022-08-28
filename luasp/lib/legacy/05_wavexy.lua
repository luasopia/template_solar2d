--------------------------------------------------------------------------------
-- 2022/08/26 created
--------------------------------------------------------------------------------
-- 메모: https://keep.google.com/u/0/#NOTE/1661553643386.113836090
--[[-----------------------------------------------------------------------------
-- dobj:waveX(opt)
--
        opt.peak (default:100)
        opt.peak2 (must be hold peak>peak2)
        opt.period (in ms, default:1000 ms)
        opt.loops (default:INF)
        opt.onEnd
        opt.delay (phase shift in time, default:0)

-- dobj:stopWaveX()
------------------------------------------------------------------------------]]

local tmgap = 1000/screen.fps -- 매frame마다 갱신
local period0 = 1000 -- ms default period for x and y
local peak0 = 100 -- default peak for x and y
--------------------------------------------------------------------------------
local luasp = _luasopia
local sin, _2PI, inf, exp = math.sin, 2*math.pi, math.huge, math.exp
local Disp = luasp.Display
local nilfunc = luasp.nilfunc
--------------------------------------------------------------------------------

local function waveXUpd(self)

    local wvx = self.__wvx
    wvx.time = wvx.time + tmgap
    local dx = wvx.peak*sin(_2PI*wvx.time*wvx.invp)
    self:setX(wvx.x0 + dx )

    -- 설정된 횟수가 채워지면 멈춘다
    if wvx.time >= wvx.endTime then
        if wvx.onEnd then
            wvx.onEnd(self)
        end
        self:stopWaveX(true)
    end

end


function Disp:waveX(opt)
    
    opt = opt or {}
    
    self:stopWaveX() -- 현재 실행중인 waveX()(가 있다면) 중지
    local period = opt.period or period0 

    local wvx = {
        x0 = self:getX(),
        invp = 1/period, -- inverse of period
        peak = opt.peak or peak0, -- peak scale
        onEnd = opt.onEnd or nilfunc,
        time = opt.delay or 0,
        endTime = (opt.loops or inf)*period
    }

    self.__wvx = wvx
    self.__iupds[waveXUpd] = waveXUpd

    return self

end

-- isToOrigin==true이면 시작x점으로 위치를 복귀시킨다.
-- isToOrigin==false(nil) 이면 현재 x값을 그대로 유지시킨 채 멈춘다.
-- (loops로 지정된 횟수가 다 됐을 때 stopWaveX(true)가 호출된다.)
function Disp:stopWaveX(isToOrigin)

    self.__iupds[waveXUpd] = nil

    if isToOrigin and self.__wvx then -- 원점(시작점)으로 복귀한다
        self:setX(self.__wvx.x0)
    end

    self.__wvx = nil
    
    return self

end


--------------------------------------------------------------------------------


local function waveYUpd(self)

    local wvy = self.__wvy
    wvy.time = wvy.time + tmgap
    local dy = wvy.peak*sin(_2PI*wvy.time*wvy.invp)
    self:setY(wvy.y0 + dy )

    if wvy.time >= wvy.endTime then
        if wvy.onEnd then
            wvy.onEnd(self)
        end
        self:stopWaveY(true)
    end

end


function Disp:waveY(opt)
    
    opt = opt or {}
    
    self:stopWaveY() -- 현재 실행중인 waveX()(가 있다면) 중지
    
    local period = opt.period or period0 
    local wvy = {
        y0 = self:getY(),
        invp = 1/period,
        peak = opt.peak or peak0, -- peak scale
        onEnd = opt.onEnd or nilfunc,
        time = opt.delay or 0,
        endTime = (opt.loops or inf)*period
    }

--    puts(wvy.endTime)

    self.__wvy = wvy
    self.__iupds[waveYUpd] = waveYUpd

    return self

end


-- (loops로 지정된 횟수가 다 됐을 때 stopWaveY(true)가 호출된다.)
function Disp:stopWaveY(isToOrigin)

    self.__iupds[waveYUpd] = nil

    if isToOrigin and self.__wvy then
        self:setY(self.__wvy.y0)
    end
    self.__wvy = nil
    
    return self

end    



--------------------------------------------------------------------------------

local function waveRotUpd(self)

    local wvr = self.__wvr
    wvr.time = wvr.time + tmgap
    local tm = wvr.time*wvr.tmc

    local dr = wvr.mid*(1-exp(-tm)) + wvr.peak*sin(tm)
    self:setRot(wvr.rot0 + dr )

    if wvr.time >= wvr.endTime then

        self:stopWaveRot()

        if wvr.onEnd then

            wvr.onEnd(self)
            
        end
        
    end

end


function Disp:waveRot(opt)
    
    opt = opt or {}
    
    self:stopWaveRot() -- 현재 실행중인 waveRot()(가 있다면) 중지
    
    local period = opt.period or period0
    local peak1 = opt.peak or peak0 -- top peak value
    local peak2 = opt.peak2 or -peak1 -- bottom peak value
    local mid = (peak1+peak2)*0.5
    local peak = (peak1-peak2)*0.5

    local wvr = {
        rot0 = self:getRot(),
        period= period,
        tmc = _2PI/period, 
        peak = peak, -- positive peak value
        mid = mid,
        onEnd = opt.onEnd or nilfunc,
        time = opt.delay or 0,
        endTime = (opt.loops or inf)*period
    }

    self.__wvr = wvr
    self.__iupds[waveRotUpd] = waveRotUpd

    return self

end


-- (loops로 지정된 횟수가 다 됐을 때 stopWaveY(true)가 호출된다.)
function Disp:stopWaveRot(isToOrigin)

    self.__iupds[waveRotUpd] = nil

    if isToOrigin and self.__wvr then
        self:setRot(self.__wvr.rot0)
    end
    self.__wvr = nil
    
    return self

end    