-- 2020/06/14 refactored
-- 2020/07/01 moved from lib into displys's method

local cos, _2PI = math.cos, 2*math.pi
local tmgap = 50
--local function wavefn(t, p) return (1-cos(_2PI*t/p))/2 end
local Disp = Display
local prd0, amp0 = 1000, 1.2
--------------------------------------------------------------------------------
-- dobj:wave(period, amplitude)
--      period (default:1000)
--      amplitude (default:1.2)
--------------------------------------------------------------------------------
local function wvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:s( self._orgns*(1 + self._drt*wv) )
end

function Disp:wave(prd, amp)
    
    if self._tmrwv then self._tmrwv:remove() end
    
    self._drt = (amp or amp0) - 1
    self._orgns = self:gets() -- original scale
    self._prd = prd or prd0
    self._tmrwv = self:timer(tmgap, wvtmr, INF)

    return self
end

function Disp:stopwave()
    if self._tmrwv then
        self._tmrwv:remove() -- dobj:removetimer(dobj._tmrwv)
        self:s(dobj._orgns)
    end
    return self
end

Disp.stopxwave = Disp.stopwave
Disp.stopywave = Disp.stopwave
--------------------------------------------------------------------------------

local function xwvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:xs( self._orgns*(1 + self._drt*wv) )
end

function Disp:xwave(prd, amp)
    
    if self._tmrwv then self._tmrwv:remove() end
    
    self._drt = (amp or amp0) - 1
    self._orgns = self:gets() -- original scale
    self._prd = prd or prd0
    self._tmrwv = self:timer(tmgap, xwvtmr, INF)

end

--------------------------------------------------------------------------------

local function ywvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:ys( self._orgns*(1 + self._drt*wv) )
end



function Disp:ywave(prd, amp)
    
    if self._tmrwv then self._tmrwv:remove() end
    
    self._drt = (amp or amp0) - 1
    self._orgns = self:gets() -- original scale
    self._prd = prd or prd0
    self._tmrwv = self:timer(tmgap, ywvtmr, INF)

end

