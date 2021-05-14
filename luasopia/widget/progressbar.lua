--------------------------------------------------------------------------------
-- 2020/08/27: created
--------------------------------------------------------------------------------
-- default values
local heightratio0 = 0.12 -- side margin == fontsize*marginratio0
local framecolor0 = Color.WHITE
local barcolor0 = Color.RED
local strokecolor0 = Color.LIGHT_GREEN
local fontsize0 = 50 -- the same as Text class default value
local fontcolor0 = Color.WHITE
--------------------------------------------------------------------------------
ProgressBar = class(Group)
--[[
    local btn = ProgressBar(width [, opt])
    opt = {
        height = n, -- in pixel, default:width*0.12
        framecolor = color, -- default: Color.LIGHT_GREEN
        framewidth = n,  -- in pixel, width/50
        
        text = {fontsize, color}, -- default: Color.GREEN
        barcolor = color, -- default:true  'shrink', 'expand', 'invertcolor'

        min = n, -- default:0
        max = n, -- defulat:100
    }
--]]
--------------------------------------------------------------------------------
function ProgressBar:init(width, opt)
    Group.init(self)
    
    opt = opt or {}
    local height = opt.height or width*heightratio0
    local framecolor = opt.framecolor or framecolor0
    local framewidth = opt.framewidth or math.floor(width/50)
    local barcolor = opt.barcolor or barcolor0
    
    self._fillrect = Rect(width,height):fillcolor(barcolor):addto(self)
    self._fillrect:anchor(0,0.5):x(-width/2)
    
    self._frame = Rect(width,height):empty():addto(self) -- framerect
    self._frame:strokecolor(framecolor):strokewidth(framewidth)

    -- self._fillrect = Rect(width-framewidth,height-framewidth):fillcolor(barcolor):addto(self)
    -- self._fillrect:anchor(0,0.5):x(-width/2 + framewidth/2)
end

function ProgressBar:value(n)
    self._fillrect:xs(n/100)
end