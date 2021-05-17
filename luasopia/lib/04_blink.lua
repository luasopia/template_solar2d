--------------------------------------------------------------------------------
-- time  : one peroid time
-- loops : number of repeatition
-- onend
--------------------------------------------------------------------------------
local function tmrfn(self, e)

    if e.isfinal then
        self:setvisible(self.__wasv)
        self.__wasv = nil
        return
    end
    
    return self:setvisible(not self:isvisible())

end


function Display:blink(time, loops, onend)

    if self._blnktmr then self._blnktmr:remove() end

    self.__wasv = self:isvisible() -- wasSeen
    self:setvisible(not self.__wasv)
    self._blnktmr = self:timer(time/2, tmrfn, loops*2-1, onend)
    return self

end


function Display:stopblink()

    if self._blnktmr then self._blnktmr:remove() end
    self:setvisible(self.__wasv) -- 원래의 visibility로 복구
    return self

end