--------------------------------------------------------------------------------
-- 2021/08/11: modified to use internal update
--------------------------------------------------------------------------------

local Disp = _luasopia.Display

local function move(self)
    
    local d = self.__mv
    if d==nil then return end
    
    if d.dx then  self:setX(self.__bdx + d.dx)  end
    if d.dy then self:setY(self.__bdy + d.dy) end
    if d.drot then self:setRot(self.__bdrd +  d.drot) end
    if d.dalpha then self:setAlpha(self.__bda + d.dalpha) end
    if d.dscale then self:setScale(self.__bds + d.dscale) end
    if d.dscaleX then self:setScaleX(self.__bdxs + d.dscaleX) end
    if d.dscaleY then self:setScaleY(self.__bdys + d.dscaleY) end
    
end


function Disp:pauseMove()

    self:__rmUpd__(move)
    return self

end


function Disp:resumeMove()

    self:__addUpd__(move)
    return self

end


function Disp:stopMove()

    if self.__mv == nil then return self end
    self.__mv = nil
    self:__rmUpd__(move)
    return self

end

--------------------------------------------------------------------------------
-- 2020/02/18, 2021/04/27 : modified as follows
--------------------------------------------------------------------------------
function Disp:setDx(d)

    self.__mv = self.__mv or {}
    self.__mv.dx = d
    self:__addUpd__(move)
    return self

end


function Disp:setDy(d)

    self.__mv=self.__mv or {}
    self.__mv.dy=d
    self:__addUpd__(move)
    return self

end


function Disp:setDrot(d)

    self.__mv = self.__mv or {}
    self.__mv.drot = d
    self:__addUpd__(move)
    return self

end


function Disp:setDscale(d)

    self.__mv = self.__mv or {}
    self.__mv.dscale = d
    self:__addUpd__(move)
    return self

end


function Disp:setDalpha(d)

    self.__mv = self.__mv or {}
    self.__mv.dalpha = d
    self:__addUpd__(move)
    return self

end


function Disp:setDscaleX(d)

    self.__mv=self.__mv or {}
    self.__mv.dscaleX = d
    self:__addUpd__(move)
    return self

end


function Disp:setDscaleY(d)

    self.__mv=self.__mv or {}
    self.__mv.dscaleY = d
    self:__addUpd__(move)
    return self

end


function Disp:setDxDy(dx,dy)

    self.__mv=self.__mv or {}
    self.__mv.dx, self.__mv.dy = dx, dy
    self:__addUpd__(move)
    return self

end

--------------------------------------------------------------------------------
-- 2020/02/25 : add getD() methods
--------------------------------------------------------------------------------
function Disp:getDx() if self.__mv==nil then return 0 else return self.__mv.dx or 0 end end
function Disp:getDy() if self.__mv==nil then return 0 else return self.__mv.dy or 0 end end
function Disp:getDrot() if self.__mv==nil then return 0 else return self.__mv.drot or 0 end end
function Disp:getDscale() if self.__mv==nil then return 0 else return self.__mv.dscale or 0 end end
function Disp:getDalpha() if self.__mv==nil then return 0 else return self.__mv.dalpha or 0 end end
function Disp:getDscaleX() if self.__mv==nil then return 0 else return self.__mv.dscaleX or 0 end end
function Disp:getDscaleY() if self.__mv==nil then return 0 else return self.__mv.dscaleY or 0 end end

function Disp:getDxDy()
    if self.__mv==nil then return 0, 0
    else return (self.__mv.dx or 0), (self.__mv.dy or 0) end
end