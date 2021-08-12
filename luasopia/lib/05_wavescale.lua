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

    local wv = 0.5*(1-cos(_2PI*e.time/self.__prd))
    self:scale( self.__scale0*(1 + self.__drt*wv) )

end


function Disp:wavescale(prd, amp)

    if self.__tmrwave and not self.__tmrwave:isremoved() then
        self.__tmrwave:remove()
    end
    
    self.__drt = (amp or amp0) - 1
    self.__scale0 = self:getscale() -- original scale
    self.__prd = prd or prd0
    self.__tmrwave = self:addtimer(tmgap, wvtmr, INF)

    return self
end


function Disp:stopwave()

    if self.__tmrwave and not self.__tmrwave:isremoved() then
        self.__tmrwave:remove()
        self:scale(dobj.__scale0)
    end

    return self

end

--------------------------------------------------------------------------------

local function xwvtmr(self, e)

    local wv = 0.5*(1-cos(_2PI*e.time/self.__prd))
    self:xs( self.__scale0*(1 + self.__drt*wv) )

end

function Disp:wavexscale(prd, amp)
    
    if self.__tmrwave and not self.__tmrwave:isremoved() then
        self.__tmrwave:remove()
    end
    
    self.__drt = (amp or amp0) - 1
    self.__scale0 = self:getscale() -- original scale
    self.__prd = prd or prd0
    self.__tmrwave = self:addtimer(tmgap, xwvtmr, INF)

end

--------------------------------------------------------------------------------

local function ywvtmr(self, e)

    local wv = 0.5*(1-cos(_2PI*e.time/self.__prd))
    self:ys( self.__scale0*(1 + self.__drt*wv) )

end



function Disp:waveyscale(prd, amp)
    
    if self.__tmrwave and not self.__tmrwave:isremoved() then
        self.__tmrwave:remove()
    end
    
    self.__drt = (amp or amp0) - 1
    self.__scale0 = self:getscale() -- original scale
    self.__prd = prd or prd0
    self.__tmrwave = self:addtimer(tmgap, ywvtmr, INF)

end