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
--------------------------------------------------------------------------------
Button = class(Group)
--[[
    local btn = Button('string', func [, opt])
    
    1st parameters of func() is button object
    2nd paramter of func() is event argument (table)

    opt = {
        fontsize = n, -- default:50
        fontcolor = color, -- default: Color.WHITE
        margin = n, -- in pixel, default:fontzise*0.5
        fill = color, -- default: Color.GREEN
        strokecolor = color, -- default: Color.LIGHT_GREEN
        strokewidth = n,  -- in pixel, default:fontzise*0.15
        effect = bool, -- default:true  'shrink', 'expand', 'invertcolor'
    }
--]]
--------------------------------------------------------------------------------
function Button:init(str, func, opt)
    Group.init(self)
    
    opt = opt or {}
    local fillcolor = opt.fill or fillcolor0
    local fontcolor = opt.fontcolor or fontcolor0
    local fontsize = opt.fontsize or fontsize0
    local margin = opt.margin or fontsize*marginratio
    local strokecolor = opt.strokecolor or strokecolor0
    local strokewidth = opt.strokewidth or fontsize*strokewidthratio0
    local effect = true
    if opt.effect==false then effect = false end
    
    -- (1) background rect must be firsly generated
    self.rect = Rect(3,3):fill(fillcolor):addto(self) -- background rect
    self.rect:strokecolor(strokecolor)
    self.rect:strokewidth(strokewidth)
    self.rect.__btn = self

    -- (2) then, text object
    self.text = Text(str,{fontsize=fontsize, color=fontcolor}):addto(self)
    
    self.__wdth = self.text:getwidth()  + 2*margin
    self.__hght = self.text:getheight() + 2*margin

    self.rect:width(self.__wdth):height(self.__hght)
    

    --(3) register tap() method
    self.rect.__func = func -- **rect의 필드**로 저장해야한다

    function self.rect:tap(e)
        if effect then
            self.__btn:s(0.97) -- 0.97
            self.__btn:timer(100, function(self) self:s(1) end)
        end

        --[[
        local ic1 = Color.invert(fillcolor)
        local ic2 = Color.invert(strokecolor)
        local ic3 = Color.invert(fontcolor)

        -- self:fill(ic1)
        -- self:strokecolor(ic2)
        -- self.__btn.text:color(ic3)
        
        self:timer(100, function(self)
            self:fill(fillcolor)
            self:strokecolor(strokecolor)
            self.__btn.text:color(fontcolor)
        end)
        --]]
        
        -- 등록된 함수가 없을 수도(nil일 수도) 있다.
        if self.__btn ~= nil then
            self.__func(self.__btn, e)
        end
    end
end

function Button:getwidth() return self.__wdth end
function Button:getheight() return self.__hght end

-- 2020/11/14: (text)string, fontsize가 변경되면 rect사이즈도 조절한다.
local function resizerect(self)
    local margin = self.text:getfontsize()*marginratio
    self.__wdth = self.text:getwidth()  + 2*margin
    self.__hght = self.text:getheight() + 2*margin
    --print(self.__wdth, self.__hght)
    self.rect:width(self.__wdth)
    self.rect:height(self.__hght)
    return self
end

function Button:fontsize(n)
    self.text:fontsize(n)
    return resizerect(self)
end

function Button:string(...)
    self.text:string(...)
    return resizerect(self)
end

function Button:getstring() return self.text:getstring() end
function Button:getfontsize() return self.text:getfontsize() end

function Button:fontcolor(c) self.text:color(c); return self end
function Button:fill(c) self.rect:fill(c); return self end
function Button:strokecolor(c) self.rect:strokecolor(c); return self end
function Button:strokewidth(w) self.rect:strokewidth(w); return self end

--2020/11/28: 콜백함수를 등록한다
function Button:onclick(func) self.rect.__func = func; return self end