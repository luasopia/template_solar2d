--------------------------------------------------------------------------------
--2021/08/13:created for pixel mode
--------------------------------------------------------------------------------

local Disp = Display
local WHITE = Color.WHITE

Dot = class(Disp)

if _Corona then

    local newPoly = _Corona.display.newPolygon
    local pts={0,0, 1,0, 1,1, 0,1}

    function Dot:init(fc)

        fc = fc or WHITE
        self.__bd = newPoly(0,0,pts)
        self.__bd:setFillColor(fc.r, fc.g, fc.b, fc.a)
        self.__fc = fc
        return Disp.init(self)

    end


    function Dot:setColor(fc)

        self.__bd:setFillColor(fc.r, fc.g, fc.b, fc.a)
        self.__fc = fc
        return self

    end


elseif _Gideros then

    local pixelNew = _Gideros.Pixel.new


    function Dot:init(fc)

        fc = fc or WHITE
        self.__bd = pixelNew(fc.hex,1, 1,1) -- color, alpha, width, height
        self.__fc = fc
        return Disp.init(self)

    end


    function Dot:setColor(fc)

        self.__bd:setColor(fc.hex, fc.alpha)
        self.__fc = fc
        return self

    end

end

-- 점의 회전은 금지된다.(필요없다)
Dot.setRot = nil
Dot.drot = nil
