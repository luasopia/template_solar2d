-- 2021/10/10 RoundRect class created
--------------------------------------------------------------------------------
local Shape = _luasopia.Shape
local tins = table.insert
local cos, sin, _2PI, floor = math.cos, math.sin, 2*math.pi, math.floor
local min, PI = math.min, math.pi
--------------------------------------------------------------------------------
RoundRect = class(Shape)
--------------------------------------------------------------------------------

-- private method
-- local function rotate(rotStart, offsetX, offsetY)
-- end


-- function RoundRect:__mkpts__(cornerRadius)
function RoundRect:__mkpts__()

    local hw, hh = self.__wdt*0.5, self.__hgt*0.5
    -- local r = radius or min(hw,hh)*0.4 -- 결과적으로 반경은 min(w,h)*0.2 다
    -- self.__rds = r
    --local r = cornerRadius or self.__crds -- 결과적으로 반경은 min(w,h)*0.2 다
    local r = self.__crds -- 결과적으로 반경은 min(w,h)*0.2 다

    -- 2020/07/02 점갯수를 구하는 더 간단한 알고리듬 
    local m = floor(r/10) --floor(r/12.5)
    local np = (12+(m-m%4))/4
    local rgap = _2PI/(np*4)

    -- (둘레) 점들의 좌표를 계산한다.
    local pts = {-hw+r,-hh, hw-r,-hh}
    
    for k=1, np-1 do
        local rot = k*rgap --print(rot)
        tins(pts, (hw-r)+sin(rot)*r) -- offsetX + rotX
        tins(pts, (-hh+r)-cos(rot)*r) -- offsetY + rotY
    end

    tins(pts, hw); tins(pts, -hh+r)
    tins(pts, hw); tins(pts, hh-r)

    local rotStart = PI*0.5
    for k=1, np-1 do
        local rot = rotStart + k*rgap
        tins(pts, (hw-r)+sin(rot)*r) -- offsetX + rotX
        tins(pts, (hh-r)-cos(rot)*r) -- offsetY + rotY
    end

    tins(pts, hw-r); tins(pts, hh)
    tins(pts, -hw+r); tins(pts, hh)

    rotStart = PI
    for k=1, np-1 do
        local rot = rotStart + k*rgap
        tins(pts, (-hw+r)+sin(rot)*r) -- offsetX + rotX
        tins(pts, (hh-r)-cos(rot)*r) -- offsetY + rotY
    end

    tins(pts, -hw); tins(pts, hh-r)
    tins(pts, -hw); tins(pts, -hh+r)

    rotStart = PI*1.5
    for k=1, np-1 do
        local rot = rotStart + k*rgap
        tins(pts, (-hw+r)+sin(rot)*r) -- offsetX + rotX
        tins(pts, (-hh+r)-cos(rot)*r) -- offsetY + rotY
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

    -- cornerRadius
    self.__crds = (opt and opt.cornerRadius) or min(self.__wdt, self.__hgt)*0.2
        
    return Shape.init(self, self:__mkpts__(), opt)
    
end


--2020/06/23
function RoundRect:setWidth(w)

    self.__wdt = w
    self.__crds = min(w,self.__hgt)*0.2

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


function RoundRect:setHeight(h)

    self.__hgt = h
    self.__crds = min(self.__wdt,h)*0.2

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


function RoundRect:setCornerRadius(r)

    local maxCornerRadius = min(self.__wdt, self.__hgt)*0.49
    if r>maxCornerRadius then r = maxCornerRadius end

    self.__crds = r

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end