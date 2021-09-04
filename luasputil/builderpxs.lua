local luasp = _luasopia
local toolbar = luasp.btoolbar


local pxgrid, plgrid -- pixel grid & palette grid
local pxgridsize=70
local pxcolor= Color.WHITE
local xmax0, ymax0 = 8,8


local palette ={
    --'0' means transparent (or empty)
    ['a'] = Color.BLACK,
    ['b'] = Color(29,43,83),                        --dark blue
    ['c'] = Color(126,37,83),                       -- dark purple
    ['d'] = Color(0,135,81),                          -- dark green
    ['e'] = Color(171,82,54),                         -- brown
    ['f'] = Color(95,87,79),                          -- dark gray
    ['g'] = Color(194,195,199),
    ['h'] = Color(255,241,232),
    ['i'] = Color(255,0,77),
    ['j'] = Color(255,163,0),
    ['k'] = Color(255,236,39),
    ['l'] = Color(0,228,54),
    ['m'] = Color(41,173,255),
    ['n'] = Color(131,118,156),
    ['o'] = Color(255,119,168),
    ['p'] = Color(255,204,170),
}

--------------------------------------------------------------------------------
local scene = Scene()
--------------------------------------------------------------------------------

local function mkpxgrid()

    pxgrid = Group():setxy(0,toolbar.height)
    for y=0,ymax0-1 do

        pxgrid[y]={}
        
        for x=0,xmax0-1 do

            local pxbox = Rect(pxgridsize,pxgridsize,{
                strokewidth=3,
                strokecolor=Color.GRAY,
                fill=Color.BLACK,
            }):setanchor(0,0):addto(pxgrid)
            -- pxbox:setanchor(0,0):empty()
            pxbox.x, pxbox.y, pxbox.color = x, y, '0'
            pxbox:setxy((x-1)*pxgridsize,(y-1)*pxgridsize)

            -- --[[
            function pxbox:ontap(e)
                print('tap')
                self:fill(pxcolor)
                self:setstrokecolor(pxcolor)
                self.color = '1'
            end
            --]]

            pxgrid[y][x] = pxbox

        end
    end


end

local function mk_palette_grid()

    -- local pxp = luasp.pxpalette
    plgrid = Group():setxy(0, toolbar.height+700)
    
    local x,y=0,0
    for key,color in pairs(palette) do
        -- local colorbox=Rect(100,100,{fill=color}):addto(plgrid)
        local colorbox=Button(key,{fill=color}):addto(plgrid)
        colorbox:setanchor(0,0):setxy(100+x*100,y*100)
        x=x+1
        if x==8 then x,y=0,1 end
        colorbox.color=color
        function colorbox:ontap(e)
            pxcolor = self.color
        end
    end

end


function scene:create(stage)

    Text('builder pixel sprite')
    mkpxgrid()
    mk_palette_grid()


end

function scene:aftershow(stage)

    stage:add(toolbar) -- 툴바를 이 scene에 표시

end


function scene:afterhide(stage) end

return scene