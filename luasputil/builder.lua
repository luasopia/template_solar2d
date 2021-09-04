local luasp = _luasopia


local toolbarfillc = Color(4,85,138)
local toolbarheight = 140
local ps=getpixels('0GG00GG0:0GGGGGG0:0G0GG0G0:0GGGGGG0:00GGGG00:00G00G00')
--local hm=getpixels('000G:00GGG:0GGGGG:GGGGGGG:GGGGGGG:0GGGGG:0GG0GG:0GG0GG')
local hm=getpixels('00GG:0GGGG:GGGGGG:0GGGG:0G00G:0G00G')

local toolbar = Group():setxy(0,0)
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width, toolbarheight):setanchor(0,0):addto(toolbar)
toolbar.bg:fill(toolbarfillc)

-- button pixel sprite
toolbar.btnpxs = Button('',{width=100,height=100}):setanchor(0,0):addto(toolbar)
toolbar.btnpxs:setxy(screen.endx-60,70)
toolbar.btnpxs:add(Pixels(ps):setscale(11))
function toolbar.btnpxs:onpush()
    Scene.__goto0('luasputil.builderpxs')
end

-- button home
toolbar.btnhome = Button('',{width=100,height=100}):setanchor(0,0):addto(toolbar)
toolbar.btnhome:setxy(60,70)
toolbar.btnhome:add( Pixels(hm):setscale(11) )
function toolbar.btnhome:onpush()
    Scene.__goto0('luasputil.builderhome')
end

--------------------------------------------------------------------------------
luasp.btoolbar = toolbar

Scene.__goto0('luasputil.builderhome')