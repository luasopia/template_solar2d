--------------------------------------------------------------------------------
-- 2020/08/27: created
--------------------------------------------------------------------------------
-- default values
local marginratio = 0.5 -- side margin == fontsize*marginratio0
local strokewidthratio0 = 0.15 -- strokewidth == fontsize*strokewidthratio0
local fillcolor0 = Color.GREEN
local strokecolor0 = Color.LIGHT_GREEN
local fontsize0 = 50 -- the same as Text class default value
local fontcolor0 = Color.WHITE
local nilfunc = function() end
--------------------------------------------------------------------------------
Button = class(Group)
--[[
    local btn = Button('string', func [, opt])
    
    1st parameters of func() is button object
    2nd paramter of func() is event argument (table)

    opt = {
        fontsize = n, -- default:50
        textcolor = color, -- default: Color.WHITE
        margin = n, -- in pixel, default:fontzise*0.5
        fill = color, -- default: Color.GREEN
        strokecolor = color, -- default: Color.LIGHT_GREEN
        strokewidth = n,  -- in pixel, default:fontzise*0.15
        effect = bool, -- default:true  'shrink', 'expand', 'invertcolor'
        
        width = n,
        height = n,
    }
--]]
--------------------------------------------------------------------------------
function Button:init(str, func, opt)

    Group.init(self)
    
    func = func or nilfunc
    opt = opt or {}

    local fillcolor = opt.fill or fillcolor0
    local fontcolor = opt.textcolor or fontcolor0
    local fontsize = opt.fontsize or fontsize0
    local margin = opt.margin or fontsize*marginratio
    local strokecolor = opt.strokecolor or strokecolor0
    local strokewidth = opt.strokewidth or fontsize*strokewidthratio0
    self.__wdt0, self.__hgt0 = opt.width, opt.height
    local effect = true
    if opt.effect==false then effect = false end
    
    -- (1) background rect must be firsly generated
    self.__rct = Rect(3,3,{
        fill = fillcolor,
        strokecolor = strokecolor,
        strokewidth = strokewidth
    }):addto(self)
    self.__rct.__btn = self

    -- (2) then, text object
    self.__txt = Text(str,{
        fontsize=fontsize,
        color=fontcolor}
    ):addto(self)
    
    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    local wdt = self.__txt:getwidth()  + 2*margin
    local hgt = self.__txt:getheight() + 2*margin
    self.__wdt, self.__hgt = self.__wdt0 or wdt, self.__hgt0 or hgt

    self.__rct:width(self.__wdt):height(self.__hgt)
    

    --(3) register tap() method
    self.__rct.__func = func -- **rect의 필드**로 저장해야한다

    function self.__rct:tap(e)

        if effect then
            self.__btn:scale(0.97) -- 0.97
            self.__btn:timer(100, function(self) self:scale(1) end)
        end

        --[[
        local ic1 = Color.invert(fillcolor)
        local ic2 = Color.invert(strokecolor)
        local ic3 = Color.invert(fontcolor)

        -- self:fill(ic1)
        -- self:strokecolor(ic2)
        -- self.__btn.__txt:color(ic3)
        
        self:timer(100, function(self)
            self:fill(fillcolor)
            self:strokecolor(strokecolor)
            self.__btn.__txt:color(fontcolor)
        end)
        --]]
        
        -- 등록된 함수가 없을 수도(nil일 수도) 있다.
        if self.__btn ~= nil then
            self.__func(self.__btn, e)
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
    self.__rct:width(self.__wdt)
    self.__rct:height(self.__hgt)
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

    self.__rct:strokewidth(n)
    return self

end


function Button:fill(fc)

    self.__rct:fill(fc)
    return self

end

function Button:setstrokecolor(sc)

    self.__rct:strokecolor(sc)
    return self

end

function Button:settextcolor(tc)

    self.__txt:color(tc)
    return self

end

function Button:setwidth(n)

    self.__wdt0, self.__wdt = n, n
    self.__rct:width(n)
    return self

end

function Button:setheight(n)

    self.__hgt0, self.__hgt = n, n
    self.__rct:height(n)
    return self

end


function Button:getstring() return self.__txt:getstring() end
function Button:getfontsize() return self.__txt:getfontsize() end


--2020/11/28: 콜백함수를 등록한다
function Button:onclick(func)

    self.__rct.__func = func
    return self

end

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