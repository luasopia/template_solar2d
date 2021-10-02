-- 2021/09/07: 생성된 후 변경되지 않는 선
-- 사용자가 사용하는 것이 아니라 내부적으로 사용하는 (단순선)객체
-- 그룹에 넣어서도 안된다
--------------------------------------------------------------------------------
local luasp = _luasopia
local Disp = luasp.Display
local Line1 = class(Disp)
luasp.Line1 = Line1
--------------------------------------------------------------------------------
local RED = Color.RED
local width0 = 3

if _Gideros then

    local Shape = _Gideros.Shape


    function Line1:init(x1,y1,x2,y2,opt)

        opt = opt or {}
        self.__strkw = opt.width or 1
        self.__strkc = opt.color or RED -- stroke color

        local s = Shape.new()
        s:beginPath()
        s:setLineStyle(self.__strkw, self.__strkc.hex) -- width, color, alpha
        s:moveTo(x1, y1)
        s:lineTo(x2, y2)
        s:endPath()

        self.__bd = s

        Disp.init(self)
        -- 2020/02/20: xy를 다시 정해진 위치로 맞추어야 한다
        self.__bd:setPosition(0,0)

    end


--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    local newLine = _Corona.display.newLine

    function Line1:init(x1,y1,x2,y2,opt)

        opt = opt or {}

        self.__strkw = opt.width or width0
        local c = opt.color or RED -- line color

        local ln = newLine(x1,y1,x2,y2)
        ln.strokeWidth = self.__strkw
        ln:setStrokeColor(c.r, c.g, c.b)
        self.__bd = ln
        self.__strkc = c

        Disp.init(self) -- 이 안에서 시작점이 (화면의)중심점으로 바뀌니까
        self:setXY(x1,y1) -- 위치를 다시 맞춰준다

    end

end

--2021/05/24 : added
function Line1:getWidth() return self.__strkw end
function Line1:getColor() return self.__strkc end