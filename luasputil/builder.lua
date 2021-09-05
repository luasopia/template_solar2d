local luasp = _luasopia


local toolbarfillc = Color(4,85,138)
local toolbarheight = 140
-- local ps=getpixels('0GG00GG0:0GGGGGG0:0G0GG0G0:0GGGGGG0:00GGGG00:00G00G00')
local ps=luasp._getpxs0{
    {
        {0,12,12,0,0,12,12,0},
        {0,12,12,12,12,12,12,0},
        {0,12,0,12,12,0,12,0},
        {0,12,12,12,12,12,12,0},
        {0,0,12,12,12,12,0,0},
        {0,0,12,0,0,12,0,0},
    }
}

-- local hm=getpixels('00GG:0GGGG:GGGGGG:0GGGG:0G00G:0G00G')
local hm = luasp._getpxs0{
    {
        {0,0,12,12},
        {0,12,12,12,12},
        {12,12,12,12,12,12},
        {0,12,12,12,12},
        {0,12,0,0,12},
        {0,12,0,0,12},
    }
}

local toolbar = Group():setxy(0,0)
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width, toolbarheight):setanchor(0,0):addto(toolbar)
toolbar.bg:fill(toolbarfillc)

-- button pixel sprite
toolbar.btnpxs = Button('',{width=100,height=100}):setanchor(0,0):addto(toolbar)
toolbar.btnpxs:setxy(screen.endx-120,20)
Pixels(ps):addto(toolbar.btnpxs):setanchor(0,0):setscale(11):setxy(7,14)
function toolbar.btnpxs:onpush()
    Scene.__goto0('luasputil.builderpxs.scene')
end

-- button home
toolbar.btnhome = Button('',{width=100,height=100}):setanchor(0,0):addto(toolbar)
toolbar.btnhome:setxy(20,20)
Pixels(hm):addto(toolbar.btnhome):setanchor(0,0):setscale(11):setxy(15,15)
function toolbar.btnhome:onpush()
    Scene.__goto0('luasputil.builderhome.scene')
end

--------------------------------------------------------------------------------
luasp.btoolbar = toolbar

Scene.__goto0('luasputil.builderhome.scene')