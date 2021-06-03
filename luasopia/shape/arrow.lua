--------------------------------------------------------------------------------
-- 2021/05/31 created
--------------------------------------------------------------------------------
local int, sqrt = math.floor, math.sqrt
--------------------------------------------------------------------------------
Arrow = class(Shape)
--------------------------------------------------------------------------------

function Arrow:__mkpts__()

    local w, hhgt, thgt, twdt = self.__wdt, self.__hhgt, self.__thgt, self.__twdt

    local x1, y1 = 0,           -hhgt
    local x2, y2 = 0.5*w,       0 
    local x3, y3 = 0.5*twdt,    0 
    local x4, y4 = 0.5*twdt,    thgt
    local x5, y5 = -0.5*twdt,   thgt
    local x6, y6 = -0.5*twdt,   0
    local x7, y7 = -0.5*w,      0

    -- x,y,1/변의길이(단위벡터를 계산하는 데 필요함)
    local _1_len1 = 1/sqrt(hhgt*hhgt+w*w*0.25)
    local _1_len2 = 1/sqrt(thgt*thgt+(w-twdt)*(w-twdt)*0.25)
    self.__cpg = {x1,y1,_1_len1,  x2,y2,_1_len1,  x4,y4,_1_len2,  x5,y5,1/twdt,  x7,y7,_1_len2}

    self.__sctx, self.__scty = 0, (thgt-hhgt)*0.5
    self.__hwdt, self.__hhgt = w*0.5, (hhgt+thgt)*0.5

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

function Arrow:setheadheight(h)

    self.__hhgt = h
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


-- tailwidth < (head)width 가 되도록 강제함
function Arrow:settailwidth(w)

    if w<self.__wdt then
        self.__twdt = w
        self.__pts = self:__mkpts__()
        return self:__redraw__()
    else
        return self
    end

end

function Arrow:settailheight(h)

    self.__thgt = h
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end

function Arrow:getwidth() return self.__wdt end
function Arrow:getheadheight() return self.__hhgt end
function Arrow:gettailwidth() return self.__twdt end
function Arrow:gettailheight() return self.__thgt end

function Arrow:getwidth() return self.__wdt end
function Arrow:getheight() return self.__hgt end

-- 2021/05/04: add aliases of set methods 
Arrow.width = Arrow.setwidth
Arrow.headheight = Arrow.setheadheight
Arrow.tailheight = Arrow.settailheight
Arrow.tailwidth = Arrow.settailwidth