-- 2020/06/23 refactoring Arrow class 
--------------------------------------------------------------------------------
-- local r = Arrow(width, height [, opt])
--------------------------------------------------------------------------------
Arrow = class(Shape)
--------------------------------------------------------------------------------

-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
function Arrow:__mkpts__()

    local w, h = self.__wdt, self.__hgt
    local x1, y1 = 0, -0.5*h 
    local x2, y2 = 0.5*w, 0 
    local x3, y3 = 0.25*w, 0 
    local x4, y4 = 0.25*w, 0.5*h
    local x5, y5 = -0.25*w, 0.5*h
    local x6, y6 = -0.25*w, 0
    local x7, y7 = -0.5*w, 0
    -- local x1, y1 = 0, -0.5*h 
    -- local x2, y2 = 0.5*w, 0 
    -- local x3, y3 = 0.25*w, 0 
    -- local x4, y4 = 0.25*w, 0.5*h
    -- local x5, y5 = -0.25*w, 0.5*h
    -- local x6, y6 = -0.25*w, 0
    -- local x7, y7 = -0.5*w, 0

    -- 2021/05/08 : 충돌판정에 필요한 점의 정보 저장
    -- x,y,1/변의길이(단위벡터를 계산하는 데 필요함)
    self.__cpg = {x1,y1,1/h,  x2, y1,1/w,  x2, y2,1/h,   x1,y2,1/w }

    return {x1,y1,  x2,y2,  x3,y3,  x4,y4, x5,y5, x6,y6, x7,y7 }
end

function Arrow:init(width, height, opt)

    self.__wdt, self.__hgt = width, height or 2*width
    self.__apx, self.__apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    return Shape.init(self, self:__mkpts__(), opt)

end

-- 2020/02/23 : Gideros의 경우 anchor()함수는 오버라이딩해야 한다.
function Arrow:anchor(ax, ay)
    self.__apx, self.__apy = ax, ay
    self:_re_pts1(self:__mkpts__())
    return self
end

function Arrow:getanchor()
    return self.__apx, self.__apy
end

--2020/06/23
function Arrow:setwidth(w)
    self.__wdt = w
    return self:_re_pts1(self:__mkpts__())
end

function Arrow:setheight(h)
    self.__hgt = h
    return self:_re_pts1( self:__mkpts__() )
end

function Arrow:getwidth() return self.__wdt end
function Arrow:getheight() return self.__hgt end

-- 2021/05/04: add aliases of set methods 
Arrow.width = Arrow.setwidth
Arrow.height = Arrow.setheight