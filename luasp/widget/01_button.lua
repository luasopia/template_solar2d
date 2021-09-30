--[[
    local btn = Button('string' [ ,func [,opt]  ])
    
    1st and 2nd parameters of func() is button object itself(btn)
        and event argument (table)

    opt = {
        fontSize = n,       -- default:50
        textColor = color,  -- default: Color.WHITE
        margin = n,         -- in pixel, default:fontzise*0.5
        fill = color,       -- default: Color.GREEN
        strokeWidth = n,    -- in pixel, default:fontzise*0.15
        strokeColor = color,-- default: Color.LIGHT_GREEN
        effect = bool,      -- default:true  'shrink', 'expand', 'invertcolor'
        
        width = n,
        height = n,

        shape = 'rect' or 'circle'
        radius = n,
    }
--]]
--------------------------------------------------------------------------------
-- 2020/08/27: created
-- modified : 2021/06/07
--------------------------------------------------------------------------------
-- default values
local marginratio = 0.5 -- side margin == fontSize*marginratio0
local strokewidthratio0 = 0.15 -- strokeWidth == fontSize*strokewidthratio0

local strokecolor0 = Color(1,130,176) --Color.LIGHT_GREEN
local fillcolor0 = Color(4,85,138) --Color.GREEN

local fontsize0 = 50 -- the same as Text class default value
local textcolor0 = Color.WHITE
local nilfunc = function() end
local shape0 = 'rect'
local max = math.max
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
    local effect = true
    local strokeWidth = opt.strokeWidth or fontSize*strokewidthratio0
    if opt.effect==false then effect = false end
    
    self.__shp = opt.shape or shape0
    self.__wdt0, self.__hgt0 = opt.width, opt.height
    self.__rds0 = opt.radius
    
    -- (1) background rect must be firsly generated
    if self.__shp == 'rect' then

        self.__shpbd = Rect(3,3,{
            fill = fillcolor,
            strokeColor = strokeColor,
            strokeWidth = strokeWidth
        }):addTo(self)

    elseif self.__shp == 'circle' then

        self.__shpbd = Circle(3,{
            fill = fillcolor,
            strokeColor = strokeColor,
            strokeWidth = strokeWidth
        }):addTo(self)

    end
    -- self.__shpbd.__btn = self

    -- (2) then, text object
    self.__txtbd = Text(str,{
        fontSize=fontSize,
        color=textColor}
    ):addTo(self)
    
    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    local wdt = self.__txtbd:getWidth()  + 2*margin
    local hgt = self.__txtbd:getHeight() + 2*margin
    self.__wdt, self.__hgt = self.__wdt0 or wdt, self.__hgt0 or hgt
    self.__rds = self.__rds0 or max(self.__wdt, self.__hgt)*0.5

    if self.__shp == 'rect' then
        self.__shpbd:setWidth(self.__wdt):setHeight(self.__hgt)
    elseif self.__shp == 'circle' then
        self.__shpbd:setRadius(self.__rds)
    end
    
    --(3) register tap() method
    self.__shpbd.onPush = func -- **rect의 필드**로 저장해야한다


    local parent = self

    function self.__shpbd:onTap(e)

        if effect then

            -- self.__btn:setScale(0.97) -- 0.97
            -- self.__btn:addTimer(100, function(self)
            --     self:setScale(1)
            -- end)

            local scale0 = parent.__bds
            parent:setScale(0.97*scale0) -- 0.97
            parent:addTimer(100, function(self)
                self:setScale(scale0)
            end)

        end

        -- btn:onPush(e) 가 정의되어 있을 경우
        if parent.onPush then
            parent.onPush(parent, e)
        end

    end


    self.__apx, self.__apy=0.5, 0.5

end


-- 2020/11/14: (text)string, fontsize가 변경되면 rect사이즈도 조절한다.
local function resizerect(self)

    local margin = self.__txtbd:getFontSize()*marginratio

    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    -- 사용자에게서 주어진 width/height는 self.__wdt0, self.__hgt0에 저장되어 있다.
    local wdt = self.__txtbd:getWidth()  + 2*margin
    local hgt = self.__txtbd:getHeight() + 2*margin
    self.__wdt, self.__hgt = self.__wdt0 or wdt, self.__hgt0 or hgt

    --print(self.__wdt, self.__hgt)
    self.__shpbd:width(self.__wdt)
    self.__shpbd:height(self.__hgt)
    return self

end


function Button:setFontSize(n)

    self.__txtbd:setFontSize(n)
    return resizerect(self)

end


function Button:setString(...)

    self.__txtbd:string(...)
    return resizerect(self)

end


function Button:setStrokeWidth(n)

    self.__shpbd:strokeWidth(n)
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
    self.__shpbd:width(n)
    return self

end

function Button:setHeight(n)

    if self.__shp == 'circle' then return end

    self.__hgt0, self.__hgt = n, n
    self.__shpbd:height(n)
    return self

end

function Button:setRadius(r)

    if self.__shp == 'rect' then return end

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