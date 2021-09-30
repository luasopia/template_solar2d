local luasp = _luasopia

local palette = luasp.palette0
local xmargin, ymargin = 10, luasp.btoolbar.height+10


-- local pxp = luasp.pxpalette
local paletgrid = Group():setXY(xmargin, luasp.btoolbar.height+700)

local x,y=0,0

for numkey,color in ipairs(palette) do

    local colorbox=Button(tostring(numkey),{width=100,height=100,fill=color})
    colorbox:addTo(paletgrid):setAnchor(0,0):setXY(x*100,y*100)
    x=x+1
    if x==10 then x,y=0,1 end
    colorbox.numkey, colorbox.color = numkey, color
    

    function colorbox:onPush(e)
        luasp.pxidcolor = self.numkey
    end

end

luasp.pxidcolor = 8

luasp.paletgrid = paletgrid
