-- 2020/08/26 created
--------------------------------------------------------------------------------
-- local r = Square(sidelength [, opt])
--------------------------------------------------------------------------------
Square = class(Shape)
--------------------------------------------------------------------------------
-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
local function mkpts(sidelen, apx, apy)
    local x1, y1 = sidelen * -apx, sidelen * -apy -- (x,y) of left-top
    local x2, y2 = sidelen * (1-apx), sidelen * (1-apy) -- (x,y) of right-bottom
    return {
        x1, y1,
        x2, y1,
        x2, y2,
        x1, y2,
    }
end

function Square:init(sidelen, opt)
    self._slen = sidelen
    self._apx, self._apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    return Shape.init(self, mkpts(sidelen, 0.5, 0.5), opt)
end

--2020/06/23
function Square:sidelen(len)
    self._slen = len
    self:_re_pts1( mkpts(len,self._apx, self._apy) )
    return self
end

function Square:getwidth() return self._slen end
function Square:getheight() return self._slen end