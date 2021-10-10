-- 2021/10/10 RoundRect class created
--------------------------------------------------------------------------------
local Shape = _luasopia.Shape
local tins = table.insert
local cos, sin, _2PI, floor = math.cos, math.sin, 2*math.pi, math.floor
local min = math.min
--------------------------------------------------------------------------------
RoundRect = class(Shape)
--------------------------------------------------------------------------------
function RoundRect:__mkpts__(radius)

    local hw, hh = self.__wdt*0.5, self.__hgt*0.5
    local r = radius or min(hw,hh)*0.4
    self.__rds = r

    -- 2020/07/02 점갯수를 구하는 더 간단한 알고리듬 
    local m = floor(r/10) --floor(r/12.5)
    local np = (12+(m-m%4))/4
    local rgap = _2PI/(np*4)

    -- (원 둘레) 점들의 좌표를 계산한다.
    local pts = {-hw+r,-hh, hw-r,-hh}
    
    for k=1, np-1 do
        local rot = 0 + k*rgap
        --print(rot)
        local xr, yr = (hw-r) +sin(rot)*r, (-hh+r) -cos(rot)*r
        tins(pts, xr) -- x
        tins(pts, yr) -- y
    end

    tins(pts, hw); tins(pts, -hh+r)
    tins(pts, hw); tins(pts, hh-r)

    for k=1, np-1 do
        local rot = math.pi*0.5 + k*rgap
        local xr, yr = (hw-r) +sin(rot)*r, (hh-r) -cos(rot)*r
        tins(pts, xr) -- x
        tins(pts, yr) -- y
    end

    tins(pts, hw-r); tins(pts, hh)
    tins(pts, -hw+r); tins(pts, hh)

    for k=1, np-1 do
        local rot = math.pi + k*rgap
        local xr, yr = (-hw+r) +sin(rot)*r, (hh-r) -cos(rot)*r
        tins(pts, xr) -- x
        tins(pts, yr) -- y
    end

    tins(pts, -hw); tins(pts, hh-r)
    tins(pts, -hw); tins(pts, -hh+r)

    for k=1, np-1 do
        local rot = math.pi*1.5 + k*rgap
        local xr, yr = (-hw+r) +sin(rot)*r, (-hh+r) -cos(rot)*r
        tins(pts, xr) -- x
        tins(pts, yr) -- y
    end


    -- 2021/09/24: 화면밖으로 나갔는지를 판정하는 점 정보들
    self.__orct = {-hh,-hw,  hh,-hw,  hh,hw,  -hh,-hw}
    -- 2021/05/08 : 충돌판정에 필요한 점의 정보 저장
    self.__cpg = {-hh,-hw,  hh,-hw,  hh,hw,  -hh,-hw}
    self.__sctx, self.__scty = 0, 0
    self.__hwdt, self.__hhgt = hw, hh
    
    return pts

end

--------------------------------------------------------------------------------

function RoundRect:init(width, height, opt)

    local th = type(height)

    if th == 'nil' then

        self.__wdt, self.__hgt = width, width

    elseif th == 'table' then

        self.__wdt, self.__hgt = width, width
        opt = height

    else -- if th=='number'

        self.__wdt, self.__hgt = width, height

    end
        
    return Shape.init(self, self:__mkpts__(), opt)
    
end


--2020/06/23
function RoundRect:setWidth(w)

    self.__wdt = w

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


function RoundRect:setHeight(h)

    self.__hgt = h

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end