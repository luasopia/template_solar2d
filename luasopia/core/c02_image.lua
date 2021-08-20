--------------------------------------------------------------------------------
-- 2021/08/13:group안에 img를 넣고 anchor를 img의 위치(x,y)를 조절하게 변경
-- 내부img는 anchor를 (0,0)으로 고정해놓아야 사용자앵커값에서 x,y를 계산하기 쉽다
-- 그리고 x,y는 int()로 변환하여 설정해야 pixel모드에서도 위치가 정확해진다
-- 2020/08/23: Image클래스의 인수를 url 한 개만으로
--------------------------------------------------------------------------------
local Disp = Display
local rooturl = _luasopia.root .. '/' -- 2021/05/12
local int = math.floor
--------------------------------------------------------------------------------
Image = class(Disp)
--------------------------------------------------------------------------------
local newImage
--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------

    -- print('core.Image(gid)')
    local newTxt = _Gideros.Texture.new
    local newBmp = _Gideros.Bitmap.new
    local newGroup = _Gideros.Sprite.new
    
    newImage = function(self, url)

        self.__bd = newGroup()
        local img = newBmp(newTxt(url))
        self.__bd:addChild(img)

        -- 2020/06/20 arguement true means 'do not consider transformation'
        local w, h = img:getWidth(true), img:getHeight(true)

        -- 앵커점을 고려하여 child의 xy좌표 설정. 초기앵커는 (0.5,0.5)
        -- pxmode에서 정확히 ap(1,1)가 우하점이 되려면 w-11, h-1를 사용해야 한다.
        img:setPosition( -int((w-1)*0.5), -int((h-1)*0.5) )
        self.__wdt, self.__hgt = w, h
        self.__img = img

    end

    
    --------------------------------------------------------------------------------
    -- texture를 외부에서 따로 만들어서 여러 객체에서 공유하는 거나
    -- 아래(init())와 같이 개별 객체에서 별도로 만드는 경우나 textureMemory의 차이가 없다.
    --------------------------------------------------------------------------------
    -- function Image:init(url) -- 2021/08/20:공통메서드로 밖으로 뺐다.


    function Image:__setimgxy__(x,y)

        self.__img:setPosition(x,y)
        return self

    end


    function Image:remove()

        self.__bd:removeChildAt(1)
        Disp.remove(self)

    end

    

--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------
    -- print('core.Image(cor)')
    local newImg = _Corona.display.newImage
    local newGroup = _Corona.display.newGroup
    --------------------------------------------------------------------------------
    newImage = function(self, url)

        self.__bd = newGroup()
        local img = newImg(self.__bd, url) -- newImage(parent, url)
        
        local w, h = img.width, img.height
        -- 앵커점을 고려하여 child의 xy좌표 설정. 초기앵커는 (0.5,0.5)
        -- pxmode에서 정확히 ap(1,1)가 우하점이 되려면 w-11, h-1를 사용해야 한다.
        img.x, img.y = -int((w-1)*0.5), -int((h-1)*0.5)
        self.__wdt, self.__hgt = w, h
        self.__img = img

    end
    

    function Image:__setimgxy__(x,y)

        self.__img.x, self.__img.y = x, y
        return self

    end
    

    --2021/08/13
    function Image:tint(r,g,b)

        self.__img:setFillColor(r,g,b)
        return self
        
    end


    function Image:remove()

        self.__bd[1]:removeSelf()
        Disp.remove(self)
    
    end


end -- if _Gideros elseif _Corona
--------------------------------------------------------------------------------

function Image:init(url)

    newImage(self, rooturl..url) -- newImage(parent, url)
    ------------------------------------------------------------
    --2021/05/09 : add info for collision box
    local w, h = self.__wdt, self.__hgt
    local hw, hh = w*0.5, h*0.5
    local invw, invh = 1/w, 1/h
    self.__cpg = {-hw,-hh,invh,  hw,-hh,invw,  hw,hh,invh,  -hw,hh,invw}
    ------------------------------------------------------------
    self.__apx, self.__apy = 0.5, 0.5

    return Disp.init(self)

end 


-- 호출되는 빈도가 낮다(객체 생성 후 한 번 정도)는 점을 고려한다
-- 계산 효율에 크게 신경 쓸 필요가 없다
function Image:setanchor(ax, ay)

    self.__apx, self.__apy = ax, ay

    local w,h = self.__wdt, self.__hgt
    local w_1, h_1 = w-1, h-1
    
    if self.__cpg then
        

        if self.__cpg0 == nil then self.__cpg0 = self.__cpg end
        local cpg, cpg0 = {}, self.__cpg0

        local x0, y0 = int((0.5-ax)*w_1), int((0.5-ay)*h_1)
        --local invw, invh = 1/w, 1/h
        --local hw, hh = w*0.5, h*0.5

        -- self.__cpg = {
        --     -hw +x0,-hh +y0, invh,
        --      hw +x0,-hh +y0, invw,
        --      hw +x0, hh +y0, invh,
        --     -hw +x0, hh +y0, invw
        -- }
        for k=1,#self.__cpg0,3 do
            print(k)
            cpg[k] = cpg0[k]+x0
            cpg[k+1] = cpg0[k+1]+y0
            cpg[k+2] = cpg0[k+2]
        end

        self.__cpg = cpg


    elseif self.__ccc then

        if self.__ccc0 == nil then self.__ccc0 = self.__ccc end
        local ccc0 = self.__ccc0
        local x0, y0 = int((0.5-ax)*w_1), int((0.5-ay)*h_1)

        local ccc = {x=ccc0.x+x0, y=ccc0.y+y0, r=ccc0.r, r2=ccc0.r2}
        self.__ccc = ccc
        
    elseif self.__cpt then
        
    end
    
    return self:__setimgxy__(-int(ax*w_1), -int(ay*h_1))

end



Image.anchor = Image.setanchor

--2021/08/20
