--------------------------------------------------------------------------------
-- time  : one peroid time
-- loops : number of repeatition
-- onend
--------------------------------------------------------------------------------
local function tmrfn(self, e)
    if e.isfinal then
        self:visible(self.__wasv)
        self.__wasv = nil
        return
    end
    return self:visible(not self:getvisible())
end

function Display:blink(time, loops, onend)
    if self._blnktmr then self._blnktmr:remove() end

    self.__wasv = self:getvisible() -- wasSeen
    self:visible(not self.__wasv)
    self._blnktmr = self:timer(time/2, tmrfn, loops*2-1, onend)
    return self
end

function Display:stopblink()
    if self._blnktmr then self._blnktmr:remove() end
    self:visible(self.__wasv) -- 원래의 visibility로 복구
    return self
end
