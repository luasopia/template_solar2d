--------------------------------------------------------------------------------
-- 2022/09/05 refactored
--------------------------------------------------------------------------------

local Disp = _luasopia.Display
local prd0 = 1000
local RED, ORIGIN = Color.RED, Color.WHITE
local HIDE = Color(255,255,255,0)

--------------------------------------------------------------------------------


local function tmrFlash(self, e)

    local f = self.__flsh
    -- if f == nil then return end (궂이 필요할까?)

    if e.isFinal then
        self.__flsh = nil        
    end
    
    if f.flashed then
        f.flashed = false
        return self:tint(ORIGIN)
    else
        f.flashed = true
        return self:tint(f.color)
    end

end


function Disp:flash(opt)

    self:stopFlash() -- 이미 실행되고 있는 것은 멈춘다
    
    opt = opt or {}
    local f = {
        color = opt.color or RED,
        flashed = true
    }

    local prd = opt.period or prd0
    local loops = opt.loops==nil and INF or (opt.loops*2+1)
    
    self:tint(f.color)
    f.tmr = self:addTimer(prd*0.5, tmrFlash, loops, opt.onEnd)
    self.__flsh = f
    return self

end


function Disp:stopFlash()

    if self.__flsh == nil then return self end -- 이미 flash가 끝났다면(없다면) 그냥 리턴
    
    if not self.__flsh.tmr:isRemoved() then
        self.__flsh.tmr:remove()
    end

    self:tint(ORIGIN) -- 원래의 tint로 복구
    self.__flsh = nil

    return self

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function Disp:blink(opt)

    opt = opt or {}
    opt.color = HIDE
    return self:flash(opt)
    
end

Disp.stopBlink = stopFlash