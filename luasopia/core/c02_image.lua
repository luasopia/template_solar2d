--------------------------------------------------------------------------------
-- 2021/08/13:group안에 img를 넣고 anchor를 img의 위치(x,y)를 조절하게 변경
-- 내부img는 anchor를 (0,0)으로 고정해놓아야 사용자앵커값에서 x,y를 계산하기 쉽다
-- 그리고 x,y는 int()로 변환하여 설정해야 pixel모드에서도 위치가 정확해진다
--------------------------------------------------------------------------------

local Disp = Display
local rooturl = _luasopia.root .. '/' -- 2021/05/12
local int = math.floor
--------------------------------------------------------------------------------
-- 2020/08/23: Image클래스의 인수를 url 한 개만으로
-- local p = Image(url)
-- p:set{x=0, y=0, xscale=1, yscale=1, scale=1, alpha=1}
-- p:getx()), p:gety(), p:getxscale(), p:getyscale(), p:getscale(), p:getalpha() 
-- p:x(v), p:y(v), p:xscale(v), p:yscale(v), p:scale(v), p:alpha(v) 
-- function p:update() ... end
-- p:remove() -- 즉시 삭제
-- p:removeafter(ms) -- ms 이후에 삭제
-- p:move{dx=n, dy=n, dxscale=n, dyscale=n, dscale=n, dalpha=n}
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
Image = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------

    -- print('core.Image(gid)')
    local newTxt = _Gideros.Texture.new
    local newBmp = _Gideros.Bitmap.new
    local newSprt = _Gideros.Sprite.new
    --------------------------------------------------------------------------------
    -- texture를 외부에서 따로 만들어서 여러 객체에서 공유하는 거나
    -- 아래와 같이 개별 객체에서 별도로 만드는 경우나 textureMemory의 차이가 없다.
    --------------------------------------------------------------------------------
    function Image:init(url)

        self.__bd = newSprt()
        local img = newBmp(newTxt(rooturl..url))
        
        self.__apx, self.apy = 0.5, 0.5
        
        -- self.__bd:setAnchorPoint(0.5, 0.5)

        --------------------------
        --2021/05/09 : add info for collision box
        local w, h = img:getWidth(true), img:getHeight(true)
        local hw, hh = w/2, h/2
        self.__cpg = {-hw,-hh,1/h,  hw,-hh,1/w,  hw,hh,1/h,  -hw,hh,1/w}
        self.__wdt, self.__hgt = w, h
        --------------------------
        self.__wdt1, self.__hgt1 = w-1, h-1

        img:setPosition(-int(self.__wdt1*0.5), -int(self.__hgt1*0.5))

        self.__bd:addChild(img)
        self.__img = img

        return Disp.init(self) --return self:superInit()

    end


    -- 2020/06/20 arguement ture means 'do not consider transformation'
    function Image:getwidth() return self.__wdt end
    function Image:getheight() return self.__hgt end

    --[[
    -- 2021/05/09: Gideros는 anchor를 조절하면 __cpts__도 조정해야
    -- getglobalxy()메서드가 제대로된 좌표값을 계산한다. 
    -- 그래서 setanchor()를 overide해야 한다
    -- (Solar2D는 getglobalxy()메서드가 anchor도 고려하야 자동으로 계산해줌)
    -- scale은 getglobalxy()메서드가 자동으로 고려된다
    function Display:setanchor(ax,ay)

      self.__bd:setAnchorPoint(ax,ay)

      local w,h = self.__wdt, self.__hgt
      self.__cpts__ = {
        -w*ax,-h*ay, 1/h,
        w*(1-ax),-h*ay, 1/w,
        w*(1-ax),h*(1-ay), 1/h,
        -w*ax,h*(1-ay), 1/w
      }
      return self

    end
--]]

    function Display:setanchor(ax,ay)

        local w,h = self.__wdt, self.__hgt

        self.__apx, self.__apy = ax, ay
        self.__img:setPosition(-int(ax*self.__wdt1), -int(ay*self.__hgt1))

        self.__cpts__ = {
          -w*ax,-h*ay, 1/h,
          w*(1-ax),-h*ay, 1/w,
          w*(1-ax),h*(1-ay), 1/h,
          -w*ax,h*(1-ay), 1/w
        }

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
    local newGrp = _Corona.display.newGroup
    --------------------------------------------------------------------------------
    function Image:init(url)

        self.__bd = newGrp()
        local img = newImg(rooturl..url)

        self.__apx, self.__apy = 0.5, 0.5
        -- self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5

        --------------------------
        --2021/05/09 : add info for collision box
        -- Solar2D는 getglobalxy()메서드가 anchor와 scale을 자동으로 고려해주므로
        -- anchor/scale이 변경될 때 self.__cpts__를 조정해줄 필요가 없다
        local w, h = img.width, img.height
        local hw, hh = w*0.5, h*0.5
        self.__cpg = {-hw,-hh,1/h,  hw,-hh,1/w,  hw,hh,1/h,  -hw,hh,1/w}
        --------------------------

        -- 앵커점을 고려하여 child의 xy좌표 설정
        self.__wdt1, self.__hgt1 = w-1, h-1
        img.x, img.y = -int(self.__wdt1*0.5), -int(self.__hgt1*0.5)

        self.__bd:insert(img)
        self.__img = img

        return Disp.init(self) --return self:superInit()
    end 


    function Image:setanchor(ax, ay)

        self.__apx, self.__apy = ax, ay
        self.__img.x, self.__img.y = -int(ax*self.__wdt1), -int(ay*self.__hgt1)

    end

    
    -- 2020/06/20
    function Image:getwidth() return self.__wdt end
    function Image:getheight() return self.__hgt end

    
    --2021/08/13
    function Display:tint(r,g,b)

        self.__bd[1]:setFillColor(r,g,b)
        return self
        
    end


end

Image.anchor = Image.setanchor