-- 2020/06/14 refactored

local cos, _2PI = math.cos, 2*math.pi
local tmgap = 50
--local function wavefn(t, p) return (1-cos(_2PI*t/p))/2 end
local Disp = Display
local prd0, amp0 = 1000, 1.2
--------------------------------------------------------------------------------
-- dobj:wavescale(period, amplitude)
--      period (default:1000)
--      amplitude (default:1.2)
-- dobj:wavexscale(period, amp)
-- dobj:waveyscale(period, amp)
-- dobj:stopwave()
--------------------------------------------------------------------------------
local function wvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:scale( self._orgns*(1 + self._drt*wv) )
end

function Disp:wavescale(prd, amp)
    
    if self._tmrwv then self._tmrwv:remove() end
    
    self._drt = (amp or amp0) - 1
    self._orgns = self:getscale() -- original scale
    self._prd = prd or prd0
    self._tmrwv = self:timer(tmgap, wvtmr, INF)

    return self
end

function Disp:stopwave()
    if self._tmrwv then
        self._tmrwv:remove() -- dobj:removetimer(dobj._tmrwv)
        self:scale(dobj._orgns)
    end
    return self
end

--------------------------------------------------------------------------------

local function xwvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:xs( self._orgns*(1 + self._drt*wv) )
end

function Disp:wavexscale(prd, amp)
    
    if self._tmrwv then self._tmrwv:remove() end
    
    self._drt = (amp or amp0) - 1
    self._orgns = self:getscale() -- original scale
    self._prd = prd or prd0
    self._tmrwv = self:timer(tmgap, xwvtmr, INF)

end

--------------------------------------------------------------------------------

local function ywvtmr(self, e)
    local wv = 0.5*(1-cos(_2PI*e.time/self._prd))
    self:ys( self._orgns*(1 + self._drt*wv) )
end



function Disp:waveyscale(prd, amp)
    
    if self._tmrwv then self._tmrwv:remove() end
    
    self._drt = (amp or amp0) - 1
    self._orgns = self:getscale() -- original scale
    self._prd = prd or prd0
    self._tmrwv = self:timer(tmgap, ywvtmr, INF)

end