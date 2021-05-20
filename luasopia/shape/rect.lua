-- 2020/06/23 refactoring Rect class 
--------------------------------------------------------------------------------
-- local r = Rect(width, height [, opt])
--------------------------------------------------------------------------------
Rect = class(Shape)
--------------------------------------------------------------------------------

-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
function Rect:__mkpts__()

    local w,h,apx,apy = self.__wdt, self.__hgt, self.__apx, self.__apy
    local x1, y1 = w*-apx, h*-apy -- (x,y) of left-top
    local x2, y2 = w*(1-apx), h*(1-apy) -- (x,y) of right-bottom

    -- 2021/05/08 : 충돌판정에 필요한 점의 정보 저장
    -- x,y,1/변의길이(단위벡터를 계산하는 데 필요함)
    self.__cpg = {x1,y1,1/h,  x2, y1,1/w,  x2, y2,1/h,   x1,y2,1/w }

    return {x1, y1,  x2, y1,  x2, y2,  x1, y2 }
end

function Rect:init(width, height, opt)

    self.__wdt, self.__hgt = width, height or width
    self.__apx, self.__apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    return Shape.init(self, self:__mkpts__(), opt)

end

-- 2020/02/23 : Gideros의 경우 anchor()함수는 오버라이딩해야 한다.
function Rect:anchor(ax, ay)
    self.__apx, self.__apy = ax, ay
    self:_re_pts1(self:__mkpts__())
    return self
end

function Rect:getanchor()
    return self.__apx, self.__apy
end

--2020/06/23
function Rect:setwidth(w)
    self.__wdt = w
    return self:_re_pts1(self:__mkpts__())
end

function Rect:setheight(h)
    self.__hgt = h
    return self:_re_pts1( self:__mkpts__() )
end

function Rect:getwidth() return self.__wdt end
function Rect:getheight() return self.__hgt end

-- 2021/05/04: add aliases of set methods 
Rect.width = Rect.setwidth
Rect.height = Rect.setheight

--##############################################################################
--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- _baselayer에 등록
-- 2020/06/23 : Rect클래스를 리팩토링한 후 여기로 옮김
--------------------------------------------------------------------------------
local ls = _luasopia
local x0, y0, endx, endy = ls.x0, ls.y0, ls.endx, ls.endy
--2020/05/06 Rect(screen)가 safe영역 전체를 덮도록 수정
--2020/05/29 baselayer에 생성되어야 한다. xy는 센터로
--screen = Rect(endx-x0+1, endy-y0+1,{fillcolor=Color.BLACK}, _luasopia.baselayer)
screen = Rect(endx-x0+1, endy-y0+1, {fillcolor=Color.BLACK})

screen:xy(ls.centerx, ls.centery)
screen.width = ls.width
screen.height = ls.height
screen.centerx = ls.centerx
screen.centery = ls.centery
screen.fps = ls.fps
-- added 2020/05/05
screen.devicewidth = ls.devicewidth
screen.deviceheight = ls.deviceheight
-- orientations: 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
screen.orientation = ls.orientation 
-- added 2020/05/06
screen.x0, screen.y0, screen.endx, screen.endy = x0, y0, endx, endy
--##############################################################################