--------------------------------------------------------------------------------
-- 2021/08/11: refactored Sprite class (and getsheet() function)
--------------------------------------------------------------------------------
local Disp = Display
local int = math.floor
local luasp = _luasopia
--------------------------------------------------------------------------------
Sprite = class(Disp)

--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------

    local bmpNew = _Gideros.Bitmap.new
    local sprtNew = _Gideros.Sprite.new

    function Sprite:init(sht, seq)
    
        self.__bd = sprtNew()
        local bmp = bmpNew(sht.__txts[1])
        self.__bd:addChild(bmp)
        
        local w, h = sht.__frmwdt, sht.__frmhgt
        local w_1, h_1 = w-1, h-1
        local hw1, hh1 = w_1*0.5, h_1*0.5
        bmp:setPosition(-int(hw1),-int(hh1))
        self.__hw1, self.__hh1 = hw1, hh1
        
        ---------

        self.__wdt, self.__hgt = w,h
        self.__wdt1, self.__hgt1 = w_1, h_1

        self.__sht, self.__seq = sht, seq
        self.__apx, self.__apy = 0.5, 0.5

        self.__img = bmp

        ------------------------------------------------------------
        --2021/08/23 : add info for collision box
        -- local hw, hh = w_1*0.5, h_1*0.5
        self.__orct = {-hw1,-hh1,  hw1,-hh1,  hw1,hh1,  -hw1,hh1}
        self.__cpg = {-hw1,-hh1,  hw1,-hh1,  hw1,hh1,  -hw1,hh1}
        ------------------------------------------------------------

        return Disp.init(self) --return self:superInit()

    end


    -- 현재 그룹내 Img를 제거하고 새로운 Img를 넣는다
    function Sprite:__setfrm__(idfrm)


        self.__bd:removeChildAt(1)

        local bmp = bmpNew(self.__sht.__txts[idfrm])
        bmp:setPosition(-int(self.__apx*self.__wdt1),-int(self.__apy*self.__hgt1))
        self.__bd:addChild(bmp)

        self.__img = bmp

        -- self.__bd:addChild( bmpNew(self.__sht.__txts[idfrm]) )
        -- return self

    end


    -- Disp 베이스클래스의 remove()를 오버로딩
    function Sprite:remove()

        self.__bd:removeChildAt(1) -- 차일드 각각의 소멸자 호출(즉시 삭제)
        return Disp.remove(self) -- 부모의 소멸자 호출

    end


    function Sprite:setAnchor(apx, apy)
    
        self.__apx, self.__apy = apx, apy
        -- self.__bmp:setAnchorPoint(apx, apy)
        self.__img:setPosition(-int(apx*self.__wdt1),-int(apy*self.__hgt1))
        return self

    end
    

    -- 2021/09/23: self.__img의 앵커점은 항상 (0,0)이다.
    function Sprite:__getgxy__(x,y)

        -- x,y는 꼭지점의 좌표가 들어오므로 nil은 확실히 아니다.
        x, y = x+self.__hw1, y+self.__hh1
        return self.__img:localToGlobal(x,y)

    end


--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------
    
    local newGrp = _Corona.display.newGroup
    local newImg = _Corona.display.newImage

    local function init(self, sht)

    end
    
    function Sprite:init(sht, seq)
    
        self.__bd = newGrp()
        local img = newImg(sht.__txts,1) -- default anchor : (0,0)
        self.__bd:insert(img)

        local w, h  = sht.__frmwdt, sht.__frmhgt
        local w_1, h_1 = w-1, h-1
        local hw1, hh1 = w_1*0.5, h_1*0.5
        img.x, img.y = -int(hw1), -int(hh1)
        
        
        ------

        

        self.__wdt, self.__hgt = w, h
        self.__wdt1, self.__hgt1 = w_1, h_1

        self.__sht, self.__seq = sht, seq
        self.__apx, self.__apy = 0.5, 0.5

        self.__img = img
        ------------------------------------------------------------
        --2021/08/23 : add info for collision box
        -- local hw, hh = w_1*0.5, h_1*0.5
        -- self.__orct = {-hw1,-hh1,  0,-hh1,  hw1,-hh1,  hw1,0,
        --                 hw1,hh1,  0,hh1,   -hw1,hh1,  -hw1,0}
        self.__orct = {-hw1,-hh1,  hw1,-hh1,  hw1,hh1,  -hw1,hh1}

        self.__cpg = {-hw1,-hh1,  hw1,-hh1,  hw1,hh1,  -hw1,hh1}

        ------------------------------------------------------------

        return Disp.init(self) --return self:superInit()
    
    end


    -- 현재 그룹내 Img를 제거하고 새로운 Img를 넣는다
    function Sprite:__setfrm__(idframe)

        if self.__idfrm == idframe then return end

        self.__bd[1]:removeSelf()
        local img = newImg(self.__sht.__txts, idframe)
        -- 앵커포인트를 고려한 xy좌표값 설정
        img.x, img.y = -int(self.__apx*self.__wdt1), -int(self.__apy*self.__hgt1)
        self.__bd:insert(img)
        self.__img = img

        self.__idfrm = idframe
        -- return self

    end


    -- Disp 베이스클래스의 remove()를 오버로딩
    function Sprite:remove()

        self.__bd[1]:removeSelf() -- 차일드 각각의 소멸자 호출(즉시 삭제)
        return Disp.remove(self) -- 부모의 소멸자 호출

    end
        

    function Sprite:setAnchor(apx, apy)

        self.__apx, self.__apy = apx, apy
        -- self.__img.anchorX, self.__img.anchorY = apx, apy
        self.__img.x, self.__img.y = -int(apx*self.__wdt1), -int(apy*self.__hgt1)
        return self

    end


    -- solar2d는 image의 앵커점과 상관 없이 localToContent()는
    -- 중심점을 원점으로 잡는다
    function Sprite:__getgxy__(x,y)

        return self.__img:localToContent(x,y)
        
    end

end -- if _Corono then ... elseif _Gideros then
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function timerfunc(self)

    self.__idsubfrm = self.__idsubfrm + 1

    if self.__idsubfrm > self.__maxidfrm then

        self.__idsubfrm = 1
        self.__loopcnt = self.__loopcnt + 1

        if self.__loopcnt == self.__loops then
            return self.__tmrsprt:remove()
        end

    end

    return self:__setfrm__(self.__frms[self.__idsubfrm])

end


function Sprite:play(id)

    if self.__tmrsprt and not self.__tmrsprt:isRemoved() then
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
    
    -- self.__idsubfrm은 self.__frms의 인덱스이다
    self.__idsubfrm, self.__loopcnt = 1, 0
    self:__setfrm__(self.__frms[1])
    
    self.__tmrsprt = self:addTimer(tmgap, timerfunc, INF)

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

    if self.__tmrsprt and not self.__tmrsprt:isRemoved() then
        self.__tmrsprt:remove()
    end

    return self

end


function Sprite:setFrame(idfrm)

    self:stop()
    self.__setfrm__(idfrm)
    return self

end

luasp.tmrfnsprt = timerfunc