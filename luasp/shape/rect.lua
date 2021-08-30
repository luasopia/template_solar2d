-- 2020/06/23 refactoring Rect class 
--------------------------------------------------------------------------------
-- local r = Rect(width, height [, opt])
--------------------------------------------------------------------------------
Rect = class(Shape)
--------------------------------------------------------------------------------

-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
-- 2021/05/31 : 중심점이 원점인 사각형의 네 꼭지점 좌표 생성
function Rect:__mkpts__()

    local hw, hh = self.__wdt*0.5, self.__hgt*0.5
    local x1, y1 = -hw, -hh -- left-top
    local x2, y2 = hw, -hh -- right-top
    local x3, y3 = hw, hh -- right-bottom
    local x4, y4 = -hw, hh -- left-bottom

    -- 2021/05/08 : 충돌판정에 필요한 점의 정보 저장
    self.__cpg = {x1,y1,  x2,y2,  x3,y3,  x4,y4}
    self.__sctx, self.__scty = 0, 0
    self.__hwdt, self.__hhgt = hw, hh

    return {x1,y1,  x2,y2,  x3,y3,  x4,y4 }

end



function Rect:init(width, height, opt)

    self.__wdt, self.__hgt = width, height or width
    if type(height)=='table' then opt=height end
    return Shape.init(self, self:__mkpts__(), opt)

end


--2020/06/23
function Rect:setwidth(w)

    self.__wdt = w

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


function Rect:setheight(h)

    self.__hgt = h

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


-- 2021/05/04: add aliases of set methods 
Rect.width = Rect.setwidth
Rect.height = Rect.setheight