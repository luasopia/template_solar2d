--------------------------------------------------------------------------------
-- time  : one peroid time(hide-show)
-- loops : number of repeatition (deafult:INF)
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

    local loops1 = loops==nil and INF or (loops*2+1)
    print('loops1:'..loops1)

    if self.__tmrblink and not self.__tmrblink:isremoved() then
        self.__tmrblink:remove()
        self:setvisible(self.__wasv)
    end

    self.__wasv = self:isvisible() -- wasSeen
    --self:setvisible(not self.__wasv)

    self.__tmrblink = self:addtimer(time*0.5, tmrfunc, loops1, onend)
    return self

end


function Display:stopblink()

    if self.__tmrblink and not self.__tmrblink:isremoved() then
        self.__tmrblink:remove()
    end

    self:setvisible(self.__wasv) -- 원래의 visibility로 복구
    self.__wasv = nil
    return self

end