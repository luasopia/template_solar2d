--------------------------------------------------------------------------------
-- time  : one peroid time
-- loops : number of repeatition
-- onend
--------------------------------------------------------------------------------
local function tmrfunc(self, e)

    if e.isfinal then
        self:setvisible(self.__wasv)
        self.__wasv = nil
        return
    end
    
    return self:setvisible(not self:isvisible())

end


function Display:blink(time, loops, onend)

    if self.__tmrblink and not self.__tmrblink:isremoved() then
        self.__tmrblink:remove()
    end

    self.__wasv = self:isvisible() -- wasSeen
    self:setvisible(not self.__wasv)
    self.__tmrblink = self:addtimer(time/2, tmrfunc, loops*2-1, onend)
    return self

end


function Display:stopblink()

    if self.__tmrblink and not self.__tmrblink:isremoved() then
        self.__tmrblink:remove()
    end

    self:setvisible(self.__wasv) -- 원래의 visibility로 복구
    return self

end