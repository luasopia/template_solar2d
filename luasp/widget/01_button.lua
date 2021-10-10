--------------------------------------------------------------------------------
-- 2020/08/27: created
-- modified : 2021/06/07, 2021/10/10
--------------------------------------------------------------------------------
--[[
    local btn = Button('string' [ ,func [,opt]  ])
    
    1st and 2nd parameters of func() is button object itself(btn)
        and tap event argument (table)

    opt = {

        fontSize = n,       -- default:50
        textColor = color,  -- default: Color.WHITE
        margin = n,         -- in pixel, default:fontzise*0.5
        fill = color,       -- default: Color.GREEN
        strokeWidth = n,    -- in pixel, default:fontzise*0.15
        strokeColor = color,-- default: Color.LIGHT_GREEN
        effect = string,    -- 'invertColor'(:default) / 'shrink' / 'expand'
        
        shape =             -- 'roundRect'(:default) / 'rect' / 'circle'
        width = n,
        height = n,
        radius = n,

    }

    Note: The sizes of the frame are not exactly the same.
    If the sizes are cirtical, set opt.width/opt.height or opt.radius as designed values.
--]]
--------------------------------------------------------------------------------
-- default values
local marginratio = 0.5 -- side margin == fontSize*marginratio0
local strokewidthratio0 = 0.15 -- strokeWidth == fontSize*strokewidthratio0

local strokecolor0 = Color(1,130,176) --Color.LIGHT_GREEN
local fillcolor0 = Color(4,85,138) --Color.GREEN

local fontsize0 = 50 -- the same as Text class default value
local textcolor0 = Color.WHITE
local nilfunc = _luasopia.nilfunc
local shape0 = 'roundRect'
local max = math.max

local effectTime = 70 -- ms
--------------------------------------------------------------------------------
Button = class(Group)
--------------------------------------------------------------------------------

function Button:init(str, func, opt)
    
    Group.init(self)

    -- 2021/06/07 Button(str,func), Button(str,func,opt)뿐만 아니라 
    -- local b = Button(str,opt) 이후에 function b:onPush(e) end 도 가능하다.
    if type(func) == 'table' then
        opt = func
        func = nilfunc
    end
    self.onPush = func or nilfunc
    opt = opt or {}

    local fillcolor = opt.fill or fillcolor0
    local textColor = opt.textColor or textcolor0
    local fontSize = opt.fontSize or fontsize0
    local margin = opt.margin or fontSize*marginratio
    local strokeColor = opt.strokeColor or strokecolor0
    local strokeWidth = opt.strokeWidth or fontSize*strokewidthratio0
    local effect = opt.effect or 'invertColor'
    
    self.__shp = opt.shape or shape0
    self.__wdt0, self.__hgt0 = opt.width, opt.height
    self.__rds0 = opt.radius

    self.__fc = fillcolor
    self.__sc = strokeColor
    self.__tc = textColor
    
    -- 2021/10/10:(1) txtbd를 먼저 생성하여 wdt,hgt,rds 정보를 계산한 이후
    -- (2) 그 값들로 배경도형(RoundRect/Rect/Circle)을 생성하여 self에 add한 하고
    -- (3) 그 이후에 txtbd를 self에 add한다.(**)
    -- self.__txtbd = Text(str,{
    self.__txtbd = Text(str,{
        fontSize=fontSize,
        color=textColor}
    )
    
    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    local wdt = self.__txtbd:getWidth()  + 2*margin
    local hgt = self.__txtbd:getHeight() + 2*margin
    self.__wdt, self.__hgt = self.__wdt0 or wdt, self.__hgt0 or hgt
    self.__rds = self.__rds0 or max(self.__wdt, self.__hgt)*0.5


    local shpOpt= {
        fill = fillcolor,
        strokeColor = strokeColor,
        strokeWidth = strokeWidth
    }
    if self.__shp == 'roundRect' then

        self.__shpbd = RoundRect(self.__wdt, self.__hgt, shpOpt)
        self.__shpbd:addTo(self)

    elseif self.__shp == 'rect' then

        self.__shpbd = Rect(self.__wdt, self.__hgt, shpOpt)
        self.__shpbd:addTo(self)
        
    elseif self.__shp == 'circle' then

        self.__shpbd = Circle(self.__rds, shpOpt)
        self.__shpbd:addTo(self)

    end

    self:add(self.__txtbd) --(**)
    
    --2021/10/10: gideros에서 text가 정중앙에 위치하도록 보정
    if _Gideros then
        local offs = fontSize*0.07
        self.__txtbd:setXY(-offs,offs)
    end
    
    --(3) register tap() method
    self.__shpbd.onPush = func -- **rect의 필드**로 저장해야한다

    local parent = self


    function self.__shpbd:onTap(e)

        if effect == 'invertColor' then

            parent.__shpbd:fill(parent.__sc)
            parent.__shpbd:setStrokeColor(parent.__fc)
            parent.__txtbd:setColor(Color.invert(parent.__tc))
            parent:addTimer(effectTime, function(self)
                parent.__shpbd:fill(parent.__fc)
                parent.__shpbd:setStrokeColor(parent.__sc)
                parent.__txtbd:setColor(parent.__tc)
            end)

        elseif effect == 'shrink' then

            local scale0 = parent.__bds
            parent:setScale(0.97*scale0) -- 0.97
            parent:addTimer(effectTime, function(self)
                self:setScale(scale0)
            end)

        elseif effect == 'expand' then
            
            local scale0 = parent.__bds
            parent:setScale(1.03*scale0) -- 0.97
            parent:addTimer(effectTime, function(self)
                self:setScale(scale0)
            end)

        end

        -- btn:onPush(e) 가 정의되어 있을 경우
        if parent.onPush then
            parent.onPush(parent, e)
        end

    end


    self.__apx, self.__apy = 0.5, 0.5

end


--[[
-- 2020/11/14: (text)string, fontsize가 변경되면 rect사이즈도 조절한다.
local function resizerect(self)

    local margin = self.__txtbd:getFontSize()*marginratio

    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    -- 사용자에게서 주어진 width/height는 self.__wdt0, self.__hgt0에 저장되어 있다.
    local wdt = self.__txtbd:getWidth()  + 2*margin
    local hgt = self.__txtbd:getHeight() + 2*margin
    self.__wdt, self.__hgt = self.__wdt0 or wdt, self.__hgt0 or hgt
    self.__rds = self.__rds0 or max(self.__wdt, self.__hgt)*0.5

    --print(self.__wdt, self.__hgt)
    self.__shpbd:setWidth(self.__wdt)
    self.__shpbd:setHeight(self.__hgt)
    return self

end
--]]


function Button:setFontSize(n)

    self.__txtbd:setFontSize(n)
    --return resizerect(self)
    return self

end


function Button:setString(...)

    self.__txtbd:setString(...)
    --return resizerect(self)
    return self

end


function Button:setStrokeWidth(n)

    self.__shpbd:setStrokeWidth(n)
    return self

end


function Button:fill(fc)

    self.__shpbd:fill(fc)
    return self

end

function Button:setStrokeColor(sc)

    self.__shpbd:setStrokeColor(sc)
    return self

end

function Button:setTextColor(tc)

    self.__txtbd:setColor(tc)
    return self

end

function Button:setWidth(n)

    if self.__shp == 'circle' then return end

    self.__wdt0, self.__wdt = n, n
    self.__shpbd:setWidth(n)
    return self

end

function Button:setHeight(n)

    if self.__shp == 'circle' then
        return
    end

    self.__hgt0, self.__hgt = n, n
    self.__shpbd:setHeight(n)
    return self

end

function Button:setRadius(r)

    if self.__shp == 'rect' or self.__shp=='roundRect' then
        return
    end

    self.__rds0, self.__rds = r, r
    self.__shpbd:setRadius(r)
    return self

end


function Button:getString() return self.__txtbd:getString() end
function Button:getFontSize() return self.__txtbd:getFontSize() end


--2021/09/04 added
function Button:setAnchor(apx, apy)

    self.__apx, self.__apy=apx, apy
    self.__shpbd:setAnchor(apx, apy)
    self.__txtbd:setAnchor(apx, apy)
    return self

end