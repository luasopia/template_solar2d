--[[
    local btn = Button('string' [ ,func [,opt]  ])
    
    1st and 2nd parameters of func() is button object itself(btn)
        and event argument (table)

    opt = {
        fontsize = n,       -- default:50
        textcolor = color,  -- default: Color.WHITE
        margin = n,         -- in pixel, default:fontzise*0.5
        fill = color,       -- default: Color.GREEN
        strokecolor = color,-- default: Color.LIGHT_GREEN
        strokewidth = n,    -- in pixel, default:fontzise*0.15
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
local marginratio = 0.5 -- side margin == fontsize*marginratio0
local strokewidthratio0 = 0.15 -- strokewidth == fontsize*strokewidthratio0

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
    -- local b = Button(str,opt) 이후에 function b:onpush(e) end 도 가능하다.
    if type(func) == 'table' then
        opt = func
        func = nilfunc
    end
    self.onpush = func or nilfunc
    opt = opt or {}

    local fillcolor = opt.fill or fillcolor0
    local textcolor = opt.textcolor or textcolor0
    local fontsize = opt.fontsize or fontsize0
    local margin = opt.margin or fontsize*marginratio
    local strokecolor = opt.strokecolor or strokecolor0
    local effect = true
    local strokewidth = opt.strokewidth or fontsize*strokewidthratio0
    if opt.effect==false then effect = false end
    
    self.__shp = opt.shape or shape0
    self.__wdt0, self.__hgt0 = opt.width, opt.height
    self.__rds0 = opt.radius
    
    -- (1) background rect must be firsly generated
    if self.__shp == 'rect' then

        self.__shpbd = Rect(3,3,{
            fill = fillcolor,
            strokecolor = strokecolor,
            strokewidth = strokewidth
        }):addto(self)

    elseif self.__shp == 'circle' then

        self.__shpbd = Circle(3,{
            fill = fillcolor,
            strokecolor = strokecolor,
            strokewidth = strokewidth
        }):addto(self)

    end
    -- self.__shpbd.__btn = self

    -- (2) then, text object
    self.__txt = Text(str,{
        fontsize=fontsize,
        color=textcolor}
    ):addto(self)
    
    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    local wdt = self.__txt:getwidth()  + 2*margin
    local hgt = self.__txt:getheight() + 2*margin
    self.__wdt, self.__hgt = self.__wdt0 or wdt, self.__hgt0 or hgt
    self.__rds = self.__rds0 or max(self.__wdt, self.__hgt)*0.5

    if self.__shp == 'rect' then
        self.__shpbd:width(self.__wdt):height(self.__hgt)
    elseif self.__shp == 'circle' then
        self.__shpbd:radius(self.__rds)
    end
    
    --(3) register tap() method
    self.__shpbd.onpush = func -- **rect의 필드**로 저장해야한다


    local parent = self

    function self.__shpbd:ontap(e)

        if effect then

            -- self.__btn:setscale(0.97) -- 0.97
            -- self.__btn:addtimer(100, function(self)
            --     self:setscale(1)
            -- end)

            local scale0 = parent.__bds
            parent:setscale(0.97*scale0) -- 0.97
            parent:addtimer(100, function(self)
                self:setscale(scale0)
            end)

        end

        -- btn:onpush(e) 가 정의되어 있을 경우
        if parent.onpush then
            parent.onpush(parent, e)
        end

    end

end


-- 2020/11/14: (text)string, fontsize가 변경되면 rect사이즈도 조절한다.
local function resizerect(self)

    local margin = self.__txt:getfontsize()*marginratio

    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    -- 사용자에게서 주어진 width/height는 self.__wdt0, self.__hgt0에 저장되어 있다.
    local wdt = self.__txt:getwidth()  + 2*margin
    local hgt = self.__txt:getheight() + 2*margin
    self.__wdt, self.__hgt = self.__wdt0 or wdt, self.__hgt0 or hgt

    --print(self.__wdt, self.__hgt)
    self.__shpbd:width(self.__wdt)
    self.__shpbd:height(self.__hgt)
    return self

end


function Button:setfontsize(n)

    self.__txt:fontsize(n)
    return resizerect(self)

end


function Button:setstring(...)

    self.__txt:string(...)
    return resizerect(self)

end


function Button:setstrokewidth(n)

    self.__shpbd:strokewidth(n)
    return self

end


function Button:fill(fc)

    self.__shpbd:fill(fc)
    return self

end

function Button:setstrokecolor(sc)

    self.__shpbd:strokecolor(sc)
    return self

end

function Button:settextcolor(tc)

    self.__txt:color(tc)
    return self

end

function Button:setwidth(n)

    if self.__shp == 'circle' then return end

    self.__wdt0, self.__wdt = n, n
    self.__shpbd:width(n)
    return self

end

function Button:setheight(n)

    if self.__shp == 'circle' then return end

    self.__hgt0, self.__hgt = n, n
    self.__shpbd:height(n)
    return self

end

function Button:setradius(r)

    if self.__shp == 'rect' then return end

    self.__rds0, self.__rds = r, r
    self.__shpbd:radius(r)
    return self

end


function Button:getstring() return self.__txt:getstring() end
function Button:getfontsize() return self.__txt:getfontsize() end


--2021/06/04: method alaias
Button.string = Button.setstring
Button.fontsize = Button.setfontsize
Button.strokewidth = Button.setstrokewidth
Button.strokecolor = Button.setstrokecolor

Button.textcolor = Button.settextcolor
Button.strokecolor = Button.setstrokecolor
Button.strokewidth = Button.setstrokewidth

Button.width = Button.setwidth
Button.height = Button.setheight