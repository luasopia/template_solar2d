local luasp=_luasopia

local xmargin, ymargin = 10, luasp.btoolbar.height+10
local xmax0, ymax0 = 8,8
local cellsize=60

local pxgrid = Group():setxy(xmargin, ymargin) 

pxgrid.xmax, pxgrid.ymax = xmax0, ymax0

luasp.pxcolor=Color.WHITE

for y=0,ymax0-1 do

    pxgrid[y]={}
    
    for x=0,xmax0-1 do

        local pxbox = Rect(cellsize, cellsize,{
            strokewidth=3,
            strokecolor=Color.GRAY,
            fill=Color.BLACK,
        }):setanchor(0,0):addto(pxgrid)
        -- pxbox:setanchor(0,0):empty()
        pxbox.x, pxbox.y, pxbox.color = x, y, nil
        pxbox:setxy(x*cellsize, y*cellsize)

        -- --[[
        function pxbox:ontap(e)

            -- print('tap')
            self:fill(luasp.pxcolor.color)
            self:setstrokecolor(luasp.pxcolor.color)
            self.pxcolor = luasp.pxcolor
            luasp.artgrid[1]:redraw()

        end
        --]]

        pxgrid[y][x] = pxbox

    end
end

luasp.pxgrid = pxgrid
