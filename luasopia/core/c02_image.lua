-- if not_required then return end -- This prevents auto-loading in Gideros

local Disp = Display
local rooturl = _luasopia.root .. '/' -- 2021/05/12
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
    -- print('core.Image(gid)')
    local Tnew = _Gideros.Texture.new
    local Bnew = _Gideros.Bitmap.new
    --------------------------------------------------------------------------------
    -- texture를 외부에서 따로 만들어서 여러 객체에서 공유하는 거나
    -- 아래와 같이 개별 객체에서 별도로 만드는 경우나 textureMemory의 차이가 없다.
    --------------------------------------------------------------------------------
    function Image:init(url)
      local texture = Tnew(rooturl..url)
      self.__bd = Bnew(texture)
      self.__bd:setAnchorPoint(0.5, 0.5)

      --------------------------
      --2021/05/09 : add info for collision box
      local w, h = self.__bd:getWidth(true), self.__bd:getHeight(true)
      local hw, hh = w/2, h/2
      self.__cpg = {-hw,-hh,1/h,  hw,-hh,1/w,  hw,hh,1/h,  -hw,hh,1/w}
      self.__wdt, self.__hgt = w, h
      --------------------------

      return Disp.init(self) --return self:superInit()
    end

    -- 2020/06/20 arguement ture means 'do not consider transformation'
    function Image:getwidth() return self.__wdt end
    function Image:getheight() return self.__hgt end

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
    Image.anchor = Image.setanchor

  
elseif _Corona then
  -- print('core.Image(cor)')
  local newImg = _Corona.display.newImage
  --------------------------------------------------------------------------------
  function Image:init(url)
    self.__bd = newImg(rooturl..url)
    self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5

    --------------------------
    --2021/05/09 : add info for collision box
    -- Solar2D는 getglobalxy()메서드가 anchor와 scale을 자동으로 고려해주므로
    -- anchor/scale이 변경될 때 self.__cpts__를 조정해줄 필요가 없다
    local w, h = self.__bd.width, self.__bd.height
    local hw, hh = w/2, h/2
    self.__cpg = {-hw,-hh,1/h,  hw,-hh,1/w,  hw,hh,1/h,  -hw,hh,1/w}
    self.__wdt, self.__hgt = w, h
    --------------------------

    return Disp.init(self) --return self:superInit()
  end  
  
  -- 2020/06/20
  function Image:getwidth() return self.__wdt end
  function Image:getheight() return self.__hgt end

end