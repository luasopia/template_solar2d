local luasp=_luasopia

local palette = luasp.palette0

local xmargin, ymargin = 10, luasp.btoolbar.height+10
local xmax0, ymax0 = 8,8
local cellsize=60

local strokecolor0 = Color(80,80,80)

local pxgrid = Group():setXY(xmargin, ymargin) 
local pxsht
local pxboxes

function pxgrid.redraw(pxart)

    pxgrid:clear()
    
    pxgrid.pxart = pxart
    local pxsht = pxart.pxsht
    pxgrid.pxsht = pxsht
    
    pxboxes={}
    for y=1,pxsht.height do

        
        for x=1,pxsht.width do

            local idcolor = pxsht[y][x]
            local color = palette[idcolor]

            local pxbox = Rect(cellsize, cellsize,{
                strokeWidth=2,
                strokeColor=strokecolor0,
                fill=color
            }):setAnchor(0,0):addTo(pxgrid)
            -- pxbox:setAnchor(0,0):empty()
            pxbox.x, pxbox.y = x, y
            pxbox:setXY((x-1)*cellsize, (y-1)*cellsize)
            
            -- solar2d는 alpha가 0이면 기본적으로 touch 이벤트가 불능이 된다.
            -- alpha가 0임에도 터치이벤트가 발생토록 하려면 아래와 같이 한다.
            -- cover.__bd(Gruop)가 아니라 cover.__shp에 적용해야 한다
            if _Corona then pxbox.__shp.isHitTestable = true end -- solar2d에서만 필요

            -- --[[
            function pxbox:onTap(e)

                -- -- 직전에 마우스우클릭을 처리했다면 바로 발생하는 터치는 무시한다.
                -- -- (solar2d는 항상 ignoreTap == nil 이므로 상관없다.)
                -- if pxbox.ignoreTap then
                --     pxbox.ignoreTap = nil
                --     return
                -- end

                print('onTap x, y=',pxbox.x, pxbox.y)

                local color = palette[luasp.pxidcolor]
                self:fill(color)
                pxsht[self.y][self.x] = luasp.pxidcolor
                pxart:redraw()

            end
            --]]

            table.insert(pxboxes, pxbox)

        end
    end
end



local function onMouseRightClick(x,y)

    for k, pxbox in ipairs(pxboxes) do

        local bx1, by1 = pxbox:__getgxy__(-30,-30)
        local bx2, by2 = pxbox:__getgxy__(30,30)

        if bx1<x and x<bx2 and by1<y and y<by2 then
            local color = palette[0]
            pxbox:setStrokeColor(strokecolor0)
            pxbox:fill(color)
            pxgrid.pxsht[pxbox.y][pxbox.x] = 0
            pxgrid.pxart:redraw()
            
            -- pxbox.ignoreTap = true
            -- print('onclick x,y=',pxbox.x, pxbox.y)
        end

    end

end

if _Gideros then

    screen.__shp:addEventListener(_Gideros.Event.MOUSE_DOWN, function(e)
        
        --print('onclick() e.button==',e.button)
        if e.button==2 then
            onMouseRightClick(e.x, e.y)
            e:stopPropagation()
        end

    end)

elseif _Corona then

    local function onMouseEvent(e)

        if e.isSecondaryButtonDown and e.type == "down" then
            onMouseRightClick(e.x, e.y)
        end

    end

    Runtime:addEventListener( "mouse", onMouseEvent )

end

luasp.pxgrid = pxgrid