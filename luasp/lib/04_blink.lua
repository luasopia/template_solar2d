--[[----------------------------------------------------------------------------
-- 2021/08/29: refactored

dobj:blink( period_in_ms )

or

dobj:blink{
    period = ms : peroid time in ms (default: 1000 ms)
    loops = n : number of repeatition (deafult:INF)
    onEnd = function() .. end : call-back funtion when all the loops are done
}
------------------------------------------------------------------------------]]
local Disp = _luasopia.Display


local function tmrfunc(self, e)

    if e.isFinal then
        self:setVisible(self.__wasv)
        self.__wasv = nil
        return
    end
    
    return self:setVisible(not self:isVisible())

end


function Disp:blink(opt)

    local period, loops1, onEnd
    if type(opt)=='number' then

        period = opt
        loops1 = INF
        onEnd = nil

    else

        opt = opt or {}
        period = opt.period or 1000
        loops1 = opt.loops==nil and INF or (opt.loops*2+1)
        onEnd = opt.onEnd

    end
    -- print('loops1:'..loops1)

    if self.__tmrblink and not self.__tmrblink:isRemoved() then
        self.__tmrblink:remove()
        self:setVisible(self.__wasv)
    end

    self.__wasv = self:isVisible() -- wasSeen
    --self:setVisible(not self.__wasv)

    self.__tmrblink = self:addTimer(period*0.5, tmrfunc, loops1, onEnd)
    return self

end


function Disp:stopblink()

    if self.__tmrblink and not self.__tmrblink:isRemoved() then
        self.__tmrblink:remove()
    end

    self:setVisible(self.__wasv) -- 원래의 visibility로 복구
    self.__wasv = nil
    return self

end