--------------------------------------------------------------------------------
-- 2020/08/27: created
--------------------------------------------------------------------------------
-- default values
local hgtratio0 = 0.12 -- side margin == fontSize*marginratio0
local strokecolor0 = Color.WHITE
local bgcolor0 = Color.BLACK
local gaugecolor0 = Color.RED
local fontsize0 = 50 -- the same as Text class default value
local fontcolor0 = Color.WHITE
local int, max = math.floor, math.max
--------------------------------------------------------------------------------
ProgressBar = class(Group)
--------------------------------------------------------------------------------
--[[
    local btn = ProgressBar(width [, opt])
    opt = {
        height = n, -- in pixel, default:width*0.12
        strokeColor = color, -- default: Color.WHITE
        strokeWidth = n, -- default: width/50
        bgColor = color, -- default: transparent color(Color(0,0,0,0))
        gaugeColor = color, -- default: Color.RED
        min = n, -- default:0
        max = n, -- defulat:100
        
        textLocation = 'left'/'right'/'top'/'bottom'
        fontSize = n, -- default: height*1.35
        textMargin = n, -- default: fontSize*0.5
        fontColor = color, -- default: Color.WHITE
    }
--]]
--------------------------------------------------------------------------------
function ProgressBar:init(width, opt)
    Group.init(self)
    
    opt = opt or {}
    local height = opt.height or width*hgtratio0
    local strokeColor = opt.bordercolor or strokecolor0
    local strokeWidth = max(2, opt.borderwidth or int(width/50) )
    local gaugeColor = opt.gaugeColor or gaugecolor0
    local bgColor = opt.bgColor or bgcolor0

    self.__minv = opt.min or 0
    self.__maxv = opt.max or 100
    
    self.__frame = Rect(width,height,{fill=bgColor}):addTo(self) -- framerect
    self.__frame:setStrokeColor(strokeColor):setStrokeWidth(strokeWidth)
    
    self.__gage = Rect(width-strokeWidth,height-strokeWidth):fill(gaugeColor):addTo(self)
    self.__gage:anchor(0,0.5):x((strokeWidth-width)*0.5)
    
    if opt.textLocation then

        self.__txtloc = opt.textLocation -- 'right' 'left', 'top', 'bottom'
        self.__fontsize = opt.fontSize or height*1.35
        self.__txtmrgn = opt.textMargin or self.__fontsize*0.5

        self.__txt = Text("0"):addTo(self)
        self.__txt:fontSize(self.__fontsize)
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
    return self:setValue(self.__minv)

end


function ProgressBar:setValue(val, txtformat)

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


function ProgressBar:setMinMax(minv, maxv)

    self.__minv, self.__maxv = minv, maxv
    return self

end


function ProgressBar:setGaugeColor(gc)

    self.__gage:fill(gc)
    return self

end


function ProgressBar:setStrokeColor(gc)

    self.__frame:setStrokeColor(gc)
    return self

end


function ProgressBar:setBgColor(gc)

    self.__frame:fill(gc)
    return self

end


function ProgressBar:setStrokeWidth(w)

    self.__frame:setStrokeWidth(w)
    return self

end

function ProgressBar:getValue()

    return self.__val

end