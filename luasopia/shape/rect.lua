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
    -- x,y,1/변의길이(단위벡터를 계산하는 데 필요함)
    self.__cpg = {x1,y1,0.5/hh,  x2,y2,0.5/hw,  x3,y3,0.5/hh,   x4,y4,0.5/hw }
    self.__sctx, self.__scty = 0, 0
    self.__hwdt, self.__hhgt = hw, hh

    return {x1,y1,  x2,y2,  x3,y3,  x4,y4 }
end

function Rect:init(width, height, opt)

    self.__wdt, self.__hgt = width, height or width
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
-------------------------------------------------------------------------------
--2021/06/05 added
--[[
screen.console = {

    clear = function() 

    end,


    function setlines(n)

    end,


    function hide()

    end,


    function show()

    end,
}
--]]