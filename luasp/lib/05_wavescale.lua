--------------------------------------------------------------------------------
-- 2021/09/20 refactored
--------------------------------------------------------------------------------
--[[-----------------------------------------------------------------------------
-- dobj:waveScale(opt)
--
        opt.period (default:1000 ms)
        opt.peakScale (default:1.2)
        opt.loops (default:INF)
        opt.onEnd

-- dobj:waveScaleX(opt)
-- dobj:waveScaleY(opt)
-- dobj:stopWave()
------------------------------------------------------------------------------]]

local tmgap = 25 -- 1000/screen.fps -- 매frame마다 갱신
local prd0 = 1000 -- ms default period
local pkscl0 = 1.2 -- default peakScale
--------------------------------------------------------------------------------
local luasp = _luasopia
local cos, _2PI = math.cos, 2*math.pi
local Disp = Display
local nilfunc = luasp.nilfunc
--------------------------------------------------------------------------------

local function getloops(self, opt)

    opt=opt or {}

    self._ws_prd = opt.period or prd0
    self._ws_onend = opt.onEnd or nilfunc

    return (opt.loops or INF)*(self._ws_prd/tmgap) -- loops

end


local function wstmr(self, e)
    
    local wv = 0.5*(1-cos(_2PI*e.time/self._ws_prd))
    self:setScale( self._ws_s0*(1 + self._ws_pks*wv) )

end


local function wsend(self)

    self:setScale(self._ws_s0)

    if self._ws_onend then
        self:_ws_onend()
    end

end


function Disp:waveScale(opt)

    if self._ws_tmr and not self._ws_tmr:isRemoved() then
        self._ws_tmr:remove()
    end
    
    self._ws_s0 = self:getScale() -- original scale

    opt = opt or {}
    self._ws_prd = opt.period or prd0
    local loops= (opt.loops or INF)*(self._ws_prd/tmgap) -- loops
    self._ws_onend = opt.onEnd or nilfunc

    self._ws_pks = (opt.peakScale or pkscl0) - 1 -- peak scale
    self._ws_tmr = self:addTimer(tmgap, wstmr, loops, wsend)

    return self

end


function Disp:stopWaveScale()

    if self._ws_tmr and not self._ws_tmr:isRemoved() then

        self._ws_tmr:remove()
        self:setScale(self._ws_s0)

    end

    return self

end

--------------------------------------------------------------------------------

local function wxstmr(self, e)

    local wv = 0.5*(1-cos(_2PI*e.time/self._ws_prd))
    self:setScaleX( self._ws_xs0*(1 + self._ws_pkxs*wv) )

end


local function wxs_end(self)

    self:setScaleX(self._ws_xs0)

    if self._ws_onend then
        self:_ws_onend()
    end

end


function Disp:waveScaleX(opt)

    if self._ws_xtmr and not self._ws_xtmr:isRemoved() then
        self._ws_xtmr:remove()
    end
    
    self._ws_xs0 = self:getScaleX() -- original scale

    opt=opt or {}
    self._ws_prd = opt.period or prd0
    local loops = (opt.loops or INF)*(self._ws_prd/tmgap) 
    self._ws_onend = opt.onEnd or nilfunc

    self._ws_pkxs = (opt.peakScale or pkscl0) - 1 -- peak scale
    self._ws_xtmr = self:addTimer(tmgap, wxstmr, loops, wxs_end)

    return self
end


function Disp:stopWaveScaleX()

    if self._ws_xtmr and not self._ws_xtmr:isRemoved() then

        self._ws_xtmr:remove()
        self:setScaleX(self._ws_xs0)

    end

    return self

end

--------------------------------------------------------------------------------

local function wystmr(self, e)

    local wv = 0.5*(1-cos(_2PI*e.time/self._ws_prd))
    self:setScaleY( self._ws_ys0*(1 + self._ws_pkys*wv) )

end


local function wys_end(self)

    self:setScaleY(self._ws_ys0)

    if self._ws_onend then
        self:_ws_onend()
    end

end


function Disp:WaveScaleY(opt)

    if self._ws_ytmr and not self._ws_ytmr:isRemoved() then
        self._ws_ytmr:remove()
    end
    
    self._ws_ys0 = self:getScaleY() -- original scale


    opt=opt or {}

    self._ws_prd = opt.period or prd0
    local loops = (opt.loops or INF)*(self._ws_prd/tmgap) 
    self._ws_onend = opt.onEnd or nilfunc
    
    self._ws_pkys = (opt.peakScale or pkscl0) - 1 -- peak scale
    self._ws_ytmr = self:addTimer(tmgap, wystmr, loops, wys_end)

    return self
end

function Disp:stopWaveScaleY()

    if self._ws_ytmr and not self._ws_ytmr:isRemoved() then

        self._ws_ytmr:remove()
        self:setScaleY(self._ws_ys0)

    end

    return self

end


Disp.wavescale = Disp.waveScale -- must be depricated in 2022