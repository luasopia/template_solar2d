local luasp=_luasopia

local palette = luasp.palette0



local xmargin, ymargin = 10, luasp.btoolbar.height+10

local pxscale = 10

local Pxart = class(Group)

function Pxart:init(pxsht)

    self.pxs = pxsht
    Group.init(self)

    -- self.pxg에는 pxgrid의 현재 내용을 실시간으로 표시한다.
    self.pxg = Group():addto(self):setscale(pxscale) -- pixel group
    for y = 1, pxsht.height do
        for x = 1, pxsht.width do
            local idcolor = pxsht[y][x]
            local color = palette[ idcolor  ]
            if idcolor ~=0 and idcolor~=nil then
                Dot(color):addto(self.pxg):setxy(x-1,y-1)
            end
        end
    end


    -- 외곽테두리
    self.rect = Rect(86,86,{strokecolor=Color.RED,strokewidth=3}):addto(self)
    self.rect:setanchor(0,0):empty()

end





function Pxart:redraw()

    self.pxg:clear()
    -- self.pxinfo = nil

    for y = 0, luasp.pxgrid.ymax-1 do

        -- self.pxinfo[1]
        for x = 0, luasp.pxgrid.xmax-1 do

            local pxb = luasp.pxgrid[y][x]
            if pxb.pxcolor ~=nil then
                Dot(pxb.pxcolor.color):addto(self.pxg):setxy(pxb.x, pxb.y)
            end

        end
    end
    return self
end

--------------------------------------------------------------------------------

local pxartset = Group():setxy(xmargin+200, luasp.btoolbar.height+1300)

local pxart1 = Pxart(luasp.pxshts[1]):addto(pxartset)
pxartset[1] = pxart1

local pxart2 = Pxart(luasp.pxshts[2]):addto(pxartset):setx(150)
pxartset[2] = pxart2

luasp.pxartset = pxartset