--------------------------------------------------------------------------------
-- 2021/05/31 created
--------------------------------------------------------------------------------
local int = math.floor
--------------------------------------------------------------------------------
Arrow = class(Shape)
--------------------------------------------------------------------------------

function Arrow:__mkpts__()

    local w, hhgt, thgt, twdt = self.__wdt, self.__hhgt, self.__thgt, self.__twdt

    local x1, y1 = 0, -hhgt
    local x2, y2 = 0.5*w, 0 
    local x3, y3 = 0.5*twdt, 0 
    local x4, y4 = 0.5*twdt, thgt
    local x5, y5 = -0.5*twdt, thgt
    local x6, y6 = -0.5*twdt, 0
    local x7, y7 = -0.5*w, 0

    -- x,y,1/변의길이(단위벡터를 계산하는 데 필요함)
    -- self.__cpg = {x1,y1,1/h,  x2, y1,1/w,  x2, y2,1/h,   x1,y2,1/w }

    self.__xmn, self.__xmx = -0.5*w, 0.5*w
    self.__ymn, self.__ymx = -hhgt, thgt

    return {x1,y1,  x2,y2,  x3,y3,  x4,y4,  x5,y5,  x6,y6,  x7,y7}

end


function Arrow:init(width, opt)
    
    self.__wdt = width --width of the head
    
    opt = opt or {}
    self.__hhgt = opt.headheight or width
    self.__twdt = opt.tailwidth or int(width*0.5)
    self.__thgt = opt.tailheight or width

    return Shape.init(self, self:__mkpts__(), opt)

end


--2020/06/23
function Arrow:setwidth(w)

    self.__wdt = w
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end

function Arrow:setheight(h)

    self.__hgt = h
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end

function Arrow:getwidth() return self.__wdt end
function Arrow:getheight() return self.__hgt end

-- 2021/05/04: add aliases of set methods 
Arrow.width = Arrow.setwidth
Arrow.height = Arrow.setheight