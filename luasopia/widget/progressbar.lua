--------------------------------------------------------------------------------
-- 2020/08/27: created
--------------------------------------------------------------------------------
-- default values
local hgtratio0 = 0.12 -- side margin == fontsize*marginratio0
local strokecolor0 = Color.WHITE
local bgcolor0 = Color.BLACK
local gaugecolor0 = Color.RED
local fontsize0 = 50 -- the same as Text class default value
local fontcolor0 = Color.WHITE
local int, max = math.floor, math.max
--------------------------------------------------------------------------------
Progressbar = class(Group)
--------------------------------------------------------------------------------
--[[
    local btn = Progressbar(width [, opt])
    opt = {
        height = n, -- in pixel, default:width*0.12
        strokecolor = color, -- default: Color.WHITE
        strokewidth = n, -- default: width/50
        bgcolor = color, -- default: transparent color(Color(0,0,0,0))
        gaugecolor = color, -- default: Color.RED
        min = n, -- default:0
        max = n, -- defulat:100
        
        textlocation = 'left'/'right'/'top'/'bottom'
        fontsize = n, -- default: height*1.35
        textmargin = n, -- default: fontsize*0.5
        fontcolor = color, -- default: Color.WHITE
    }
--]]
--------------------------------------------------------------------------------
function Progressbar:init(width, opt)
    Group.init(self)
    
    opt = opt or {}
    local height = opt.height or width*hgtratio0
    local strokecolor = opt.bordercolor or strokecolor0
    local strokewidth = max(2, opt.borderwidth or int(width/50) )
    local gaugecolor = opt.gaugecolor or gaugecolor0
    local bgcolor = opt.bgcolor or bgcolor0

    self.__minv = opt.min or 0
    self.__maxv = opt.max or 100
    
    self.__frame = Rect(width,height,{fill=bgcolor}):addto(self) -- framerect
    self.__frame:strokecolor(strokecolor):strokewidth(strokewidth)
    
    self.__gage = Rect(width-strokewidth,height-strokewidth):fill(gaugecolor):addto(self)
    self.__gage:anchor(0,0.5):x((strokewidth-width)*0.5)
    
    if opt.textlocation then

        self.__txtloc = opt.textlocation -- 'right' 'left', 'top', 'bottom'
        self.__fontsize = opt.fontsize or height*1.35
        self.__txtmrgn = opt.textmargin or self.__fontsize*0.5

        self.__txt = Text("0"):addto(self)
        self.__txt:fontsize(self.__fontsize)
        if self.__txtloc == 'right' then
            self.__txt:anchor(0,0.5)
            self.__txt:x(width*0.5 + self.__txtmrgn)
        elseif self.__txtloc == 'left' then
            self.__txt:anchor(1,0.5)
            self.__txt:x(-width*0.5 - self.__txtmrgn)
        elseif self.__txtloc == 'bottom' then
            self.__txt:anchor(0.5,0)
            self.__txt:y(height*0.5 + self.__txtmrgn)
        elseif self.__txtloc == 'top' then
            self.__txt:anchor(0.5,1)
            self.__txt:y(-height*0.5 - self.__txtmrgn)
        end

    end

    self.__val = self.__minv
    return self:value(self.__minv)

end


function Progressbar:setvalue(val, txtformat)

    -- 설정된 최대/최소값을 제한
    if val>self.__maxv then val = self.__maxv
    elseif val<self.__minv then val = self.__minv end

    self.__val = val

    local ratio = (val-self.__minv)/(self.__maxv-self.__minv)
    if ratio == 0 then ratio = 0.000001 end -- for solar2d
    self.__gage:xscale(ratio)

    if self.__txt then
        self.__txt:string(textformat or "%d", val)
    end

    return self

end


function Progressbar:setminmax(minv, maxv)

    self.__minv, self.__maxv = minv, maxv
    return self

end


function Progressbar:setgaugecolor(gc)

    self.__gage:fill(gc)
    return self

end


function Progressbar:setstrokecolor(gc)

    self.__frame:strokecolor(gc)
    return self

end


function Progressbar:setbgcolor(gc)

    self.__frame:fill(gc)
    return self

end


function Progressbar:setstrokewidth(w)

    self.__frame:strokewidth(w)
    return self

end

function Progressbar:getvalue()

    return self.__val

end

-- 2021/06/07
Progressbar.value = Progressbar.setvalue
Progressbar.minmax = Progressbar.setminmax
Progressbar.gaugecolor = Progressbar.setgaugecolor
Progressbar.strokecolor = Progressbar.setstrokecolor
Progressbar.strokewidth = Progressbar.setstrokewidth
Progressbar.bgcolor = Progressbar.setbgcolor