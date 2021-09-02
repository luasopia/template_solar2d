--[[----------------------------------------------------------------------------
-- 2021/08/29: refactored
dobj:blink(period)

or

dobj:blink{
    period = ms : peroid time in ms (default: 1000 ms)
    loops = n : number of repeatition (deafult:INF)
    onend = function() .. end : call-back funtion when all the loops are done
}
------------------------------------------------------------------------------]]
local function tmrfunc(self, e)

    if e.isfinal then
        self:setvisible(self.__wasv)
        self.__wasv = nil
        return
    end
    
    return self:setvisible(not self:isvisible())

end


function Display:blink(opt)

    local period, loops1, onend
    if type(opt)=='number' then

        period = opt
        loops1 = INF
        onend = nil

    else

        opt = opt or {}
        period = opt.period or 1000
        loops1 = opt.loops==nil and INF or (opt.loops*2+1)
        onend = opt.onend

    end
    -- print('loops1:'..loops1)

    if self.__tmrblink and not self.__tmrblink:isremoved() then
        self.__tmrblink:remove()
        self:setvisible(self.__wasv)
    end

    self.__wasv = self:isvisible() -- wasSeen
    --self:setvisible(not self.__wasv)

    self.__tmrblink = self:addtimer(period*0.5, tmrfunc, loops1, onend)
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