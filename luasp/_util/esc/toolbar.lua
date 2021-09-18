local luasp = _luasopia
local esclayer = luasp.esclayer


local toolbarfillc = Color(4,85,138)
local toolbarheight = 80

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

local toolbar = Group():addto(esclayer):setxy(0,0)
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width, toolbarheight):setanchor(0,0):addto(toolbar)
toolbar.bg:fill(toolbarfillc)

-- button pixel sprite
toolbar.btnpxs = Button('',{width=60,height=60,strokewidth=4}):setanchor(0,0):addto(toolbar)
toolbar.btnpxs:setxy(screen.endx-100,10)
local pxsps = Pixels(ps):addto(toolbar.btnpxs):setanchor(0,0):setscale(7):setxy(3,10)


function toolbar.btnpxs:onpush()

    luasp.esclayer:hide()
    Scene.__goto0('luasp._util.pxbuilder.scene')

end

--[[
-- button home
toolbar.btnhome = Button('',{width=60,height=60,strokewidth=4}):setanchor(0,0):addto(toolbar)
toolbar.btnhome:setxy(10,10)
Pixels(hm):addto(toolbar.btnhome):setanchor(0,0):setscale(7):setxy(7,10)
function toolbar.btnhome:onpush()
    Scene.__goto0('luasp._util.builderhome.scene')
end
--]]

toolbar.height = toolbarheight
return toolbar