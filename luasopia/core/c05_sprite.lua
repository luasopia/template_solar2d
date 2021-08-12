--------------------------------------------------------------------------------
-- 2021/08/11: refactored Sprite class (and getsheet() function)
--------------------------------------------------------------------------------
local Disp = Display
--------------------------------------------------------------------------------

Sprite = class(Disp)

--------------------------------------------------------------------------------
if _Corona then
--------------------------------------------------------------------------------

    local newGrp = _Corona.display.newGroup
    local newImg = _Corona.display.newImage
    
    function Sprite:init(sht, seq)
  
        self.__bd = newGrp()
        self.__sht = sht
        self.__seq = seq
        self.__apx, self.__apy = 0.5, 0.5

        local img = newImg(sht.__txts,1)
        self.__bd:insert(img)
        self.__img = img

        return Disp.init(self) --return self:superInit()
  
    end


    -- 현재 그룹내 Img를 제거하고 새로운 Img를 넣는다
    function Sprite:__setfrm__(idframe)

        self.__bd[1]:removeSelf()


        local img = newImg(self.__sht.__txts, idframe)
        img.anchorX, img.anchorY = self.__apx, self.__apy
        self.__bd:insert(img)

        self.__img = img
        -- return self

    end


    -- Disp 베이스클래스의 remove()를 오버로딩
    function Sprite:remove()

        self.__bd[1]:removeSelf() -- 차일드 각각의 소멸자 호출(즉시 삭제)
        return Disp.remove(self) -- 부모의 소멸자 호출

    end
      

    function Sprite:setanchor(apx, apy)

        self.__apx, self.__apy = apx, apy
        self.__img.anchorX, self.__img.anchorY = apx, apy
        return self

    end
  

--------------------------------------------------------------------------------
elseif _Gideros then
--------------------------------------------------------------------------------

    local bmpNew = _Gideros.Bitmap.new
    local sprtNew = _Gideros.Sprite.new

    function Sprite:init(sht, seq)
    
        self.__bd = sprtNew()
        self.__sht = sht
        self.__seq = seq

        self.__apx, self.__apy = 0.5, 0.5

        local bmp = bmpNew(self.__sht.__txts[1])
        bmp:setAnchorPoint(0.5,0.5)
        self.__bd:addChild(bmp)
        self.__bmp = bmp

        return Disp.init(self) --return self:superInit()

    end

    -- 현재 그룹내 Img를 제거하고 새로운 Img를 넣는다
    function Sprite:__setfrm__(idfrm)

        -- print('idfrm '..idfrm)

        self.__bd:removeChildAt(1)

        local bmp = bmpNew(self.__sht.__txts[idfrm])
        bmp:setAnchorPoint(self.__apx,self.__apy)
        self.__bd:addChild(bmp)

        self.__bmp = bmp

        -- self.__bd:addChild( bmpNew(self.__sht.__txts[idfrm]) )
        -- return self

    end

    -- Disp 베이스클래스의 remove()를 오버로딩
    function Sprite:remove()

        self.__bd:removeChildAt(1) -- 차일드 각각의 소멸자 호출(즉시 삭제)
        return Disp.remove(self) -- 부모의 소멸자 호출

    end


    function Sprite:setanchor(apx, apy)
    
        self.__apx, self.__apy = apx, apy
        self.__bmp:setAnchorPoint(apx, apy)
        return self

    end
    

end -- if _Corono then ... elseif _Gideros then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function timerfunc(self)

    self.__idfrm = self.__idfrm + 1

    if self.__idfrm > self.__maxidfrm then

        self.__idfrm = 1
        self.__loopcnt = self.__loopcnt + 1

        if self.__loopcnt == self.__loops then
            return self.__tmrsprt:remove()
        end

    end

    return self:__setfrm__(self.__frms[self.__idfrm])

end


function Sprite:play(id)

    if self.__tmrsprt and not self.__tmrsprt:isremoved() then
        self.__tmrsprt:remove()
    end

    local seq
    if id == nil then
        if self.__seq.time then
            seq = self.__seq
        else
            seq= self.__seq[1]
        end
    else
        seq = self.__seq[id]
    end

    self.__frms = seq.frames or self.__sht.__allfrms
    self.__maxidfrm = #self.__frms
    self.__loops = seq.loops or INF
    
    local tmgap = seq.time/self.__maxidfrm
    
    self.__idfrm, self.__loopcnt = 1, 0
    self:__setfrm__(self.__frms[1])
    
    self.__tmrsprt = self:addtimer(tmgap, timerfunc, INF)

    return self

end


function Sprite:pause()

    if self.__tmrsprt then
        self.__tmrsprt:pause()
    end

    return self

end


function Sprite:resume()

    if self.__tmrsprt then
        self.__tmrsprt:resume()
    end

    return self
    
end


function Sprite:stop()

    if self.__tmrsprt and not self.__tmrsprt:isremoved() then
        self.__tmrsprt:remove()
    end

    return self

end


function Sprite:getanchor()

    return self.__apx, self.__apy

end


function Sprite:setframe(idfrm)

    self:stop()
    self.__setfrm__(idfrm)
    return self

end
