local luasp = _luasopia
local esclayer = luasp.esclayer


local toolbarfillc = Color(4,85,138)
local toolbarheight = 80



local toolbar = Group():addTo(esclayer):setXY(0,0)
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width, toolbarheight):setAnchor(0,0):addTo(toolbar)
toolbar.bg:fill(toolbarfillc)

-- button pixel sprite
toolbar.btnpxs = Button('',{width=55,height=55,strokeWidth=5}):addTo(toolbar)
toolbar.btnpxs:setAnchor(0,0):setXY(screen.endX-100,12)
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
Pixels(ps):addTo(toolbar.btnpxs):setAnchor(0,0):setScale(7):setXY(1,7)


function toolbar.btnpxs:onPush()

    luasp.esclayer:hide()
    Scene.__goto0('luasp._util.pxbuilder.scene')

end

--[[
-- button home
toolbar.btnhome = Button('',{width=60,height=60,strokeWidth=4}):setAnchor(0,0):addTo(toolbar)
toolbar.btnhome:setXY(10,10)
Pixels(hm):addTo(toolbar.btnhome):setAnchor(0,0):setScale(7):setXY(7,10)
function toolbar.btnhome:onPush()
    Scene.__goto0('luasp._util.builderhome.scene')
end
--]]

-- button pixel sprite
toolbar.btnInfo = Button('',{width=55,height=55,strokeWidth=5}):addTo(toolbar)
toolbar.btnInfo:setAnchor(0,0):setXY(30,12)
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
Pixels(pxt):addTo(toolbar.btnInfo):setAnchor(0,0):setScale(7):setXY(0,6)
function toolbar.btnInfo:onPush()
    luasp.console.infotxts:setVisible(not luasp.console.infotxts:isVisible())
end


-- button pixel sprite
toolbar.btngrid = Button('',{width=55,height=55,strokeWidth=5}):addTo(toolbar)
toolbar.btngrid:setAnchor(0,0):setXY(105,12)
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
Pixels(pxg):addTo(toolbar.btngrid):setAnchor(0,0):setScale(5):setXY(5,2)
function toolbar.btngrid:onPush()
    luasp.console.gridlines:setVisible(not luasp.console.gridlines:isVisible())
end



toolbar.height = toolbarheight
return toolbar