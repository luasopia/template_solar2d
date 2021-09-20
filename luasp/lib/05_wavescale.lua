--------------------------------------------------------------------------------
-- 2021/09/20 refactored
--------------------------------------------------------------------------------
--[[-----------------------------------------------------------------------------
-- dobj:wavescale(opt)
--
        opt.period (default:1000 ms)
        opt.peakscale (default:1.2)
        opt.loops (default:INF)
        opt.onend

-- dobj:wavexscale(opt)
-- dobj:waveyscale(opt)
-- dobj:stopwave()
------------------------------------------------------------------------------]]

local tmgap = 25 -- 1000/screen.fps -- 매frame마다 갱신
local prd0 = 1000 -- ms default period
local pkscl0 = 1.2 -- default peakscale
--------------------------------------------------------------------------------
local luasp = _luasopia
local cos, _2PI = math.cos, 2*math.pi
local Disp = Display
local nilfunc = luasp.nilfunc
--------------------------------------------------------------------------------

local function getloops(self, opt)

    opt=opt or {}

    self._ws_prd = opt.period or prd0
    self._ws_onend = opt.onend or nilfunc

    return (opt.loops or INF)*(self._ws_prd/tmgap) -- loops

end


local function wstmr(self, e)
    
    local wv = 0.5*(1-cos(_2PI*e.time/self._ws_prd))
    self:setscale( self._ws_s0*(1 + self._ws_pks*wv) )

end


local function wsend(self)

    self:setscale(self._ws_s0)

    if self._ws_onend then
        self:_ws_onend()
    end

end

-- function Disp:wavescale(prd, amp)
function Disp:wavescale(opt)

    if self._ws_tmr and not self._ws_tmr:isremoved() then
        self._ws_tmr:remove()
    end
    
    self._ws_s0 = self:getscale() -- original scale

    opt = opt or {}
    self._ws_prd = opt.period or prd0
    local loops= (opt.loops or INF)*(self._ws_prd/tmgap) -- loops
    self._ws_onend = opt.onend or nilfunc

    self._ws_pks = (opt.peakscale or pkscl0) - 1 -- peak scale
    self._ws_tmr = self:addtimer(tmgap, wstmr, loops, wsend)

    return self

end


function Disp:stopwavescale()

    if self._ws_tmr and not self._ws_tmr:isremoved() then

        self._ws_tmr:remove()
        self:setscale(self._ws_s0)

    end

    return self

end

--------------------------------------------------------------------------------

local function wxstmr(self, e)

    local wv = 0.5*(1-cos(_2PI*e.time/self._ws_prd))
    self:setxscale( self._ws_xs0*(1 + self._ws_pkxs*wv) )

end


local function wxs_end(self)

    self:setxscale(self._ws_xs0)

    if self._ws_onend then
        self:_ws_onend()
    end

end


function Disp:wavexscale(opt)

    if self._ws_xtmr and not self._ws_xtmr:isremoved() then
        self._ws_xtmr:remove()
    end
    
    self._ws_xs0 = self:getxscale() -- original scale

    opt=opt or {}
    self._ws_prd = opt.period or prd0
    local loops = (opt.loops or INF)*(self._ws_prd/tmgap) 
    self._ws_onend = opt.onend or nilfunc

    self._ws_pkxs = (opt.peakscale or pkscl0) - 1 -- peak scale
    self._ws_xtmr = self:addtimer(tmgap, wxstmr, loops, wxs_end)

    return self
end


function Disp:stopwavexscale()

    if self._ws_xtmr and not self._ws_xtmr:isremoved() then

        self._ws_xtmr:remove()
        self:setxscale(self._ws_xs0)

    end

    return self

end

--------------------------------------------------------------------------------

local function wystmr(self, e)

    local wv = 0.5*(1-cos(_2PI*e.time/self._ws_prd))
    self:setyscale( self._ws_ys0*(1 + self._ws_pkys*wv) )

end


local function wys_end(self)

    self:setyscale(self._ws_ys0)

    if self._ws_onend then
        self:_ws_onend()
    end

end


function Disp:waveyscale(opt)

    if self._ws_ytmr and not self._ws_ytmr:isremoved() then
        self._ws_ytmr:remove()
    end
    
    self._ws_ys0 = self:getyscale() -- original scale


    opt=opt or {}

    self._ws_prd = opt.period or prd0
    local loops = (opt.loops or INF)*(self._ws_prd/tmgap) 
    self._ws_onend = opt.onend or nilfunc
    
    self._ws_pkys = (opt.peakscale or pkscl0) - 1 -- peak scale
    self._ws_ytmr = self:addtimer(tmgap, wystmr, loops, wys_end)

    return self
end

function Disp:stopwaveyscale()

    if self._ws_ytmr and not self._ws_ytmr:isremoved() then

        self._ws_ytmr:remove()
        self:setyscale(self._ws_ys0)

    end

    return self

end