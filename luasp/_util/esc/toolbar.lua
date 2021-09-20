local luasp = _luasopia
local esclayer = luasp.esclayer


local toolbarfillc = Color(4,85,138)
local toolbarheight = 80



local toolbar = Group():addto(esclayer):setxy(0,0)
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width, toolbarheight):setanchor(0,0):addto(toolbar)
toolbar.bg:fill(toolbarfillc)

-- button pixel sprite
toolbar.btnpxs = Button('',{width=55,height=55,strokewidth=5}):addto(toolbar)
toolbar.btnpxs:setanchor(0,0):setxy(screen.endx-100,12)
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
Pixels(ps):addto(toolbar.btnpxs):setanchor(0,0):setscale(7):setxy(1,7)


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

-- button pixel sprite
toolbar.btnInfo = Button('',{width=55,height=55,strokewidth=5}):addto(toolbar)
toolbar.btnInfo:setanchor(0,0):setxy(30,12)
local P, p = 15, 10 -- 10,15
local pxt = luasp._getpxs0{
    {
        {0,P,P,P,P,P,P,0},
        {0,p,p,P,p,p,P,0},
        {0,0,0,P,p,0,0,0},
        {0,0,0,P,p,0,0,0},
        {0,0,0,P,p,0,0,0},
        {0,0,0,P,p,0,0,0},
    }
}
Pixels(pxt):addto(toolbar.btnInfo):setanchor(0,0):setscale(7):setxy(0,6)
function toolbar.btnInfo:onpush()
    luasp.console.infotxts:setvisible(not luasp.console.infotxts:isvisible())
end


-- button pixel sprite
toolbar.btngrid = Button('',{width=55,height=55,strokewidth=5}):addto(toolbar)
toolbar.btngrid:setanchor(0,0):setxy(105,12)
local P=10
local pxg = luasp._getpxs0{
    {
        {0,P,0,P,0,P,0,P,0},
        {0,P,0,P,0,P,0,P,0},
        {0,P,0,P,0,P,0,P,0},
        {P,P,P,P,P,P,P,P,P},
        {0,P,0,P,0,P,0,P,0},
        {0,P,0,P,0,P,0,P,0},
        {P,P,P,P,P,P,P,P,P},
        {0,P,0,P,0,P,0,P,0},
        {0,P,0,P,0,P,0,P,0},
        {0,P,0,P,0,P,0,P,0},
    }
}
Pixels(pxg):addto(toolbar.btngrid):setanchor(0,0):setscale(5):setxy(5,2)
function toolbar.btngrid:onpush()
    luasp.console.gridlines:setvisible(not luasp.console.gridlines:isvisible())
end



toolbar.height = toolbarheight
return toolbar