local luasp=_luasopia

local palette = luasp.palette0



local xmargin, ymargin = 10, luasp.btoolbar.height+10

local pxscale = 10

local Pxart = class(Group)

function Pxart:init(pxsht)

    self.pxsht = pxsht
    Group.init(self)

    if pxsht == nil then
        self.pxsht = { -- 새로운 테이블을 생성해야 한다
            {0,0,0,0,0,0,0,0,},
            {0,0,0,0,0,0,0,0,},
            {0,0,0,0,0,0,0,0,},
            {0,0,0,0,0,0,0,0,},
            {0,0,0,0,0,0,0,0,},
            {0,0,0,0,0,0,0,0,},
            {0,0,0,0,0,0,0,0,},
            {0,0,0,0,0,0,0,0,},
            width=8,
            height=8,
        }
    end

    local s = luasp._getpxs0{self.pxsht}
    self.pxs = Pixels(s):addto(self):setscale(pxscale):setanchor(0,0)


    -- 외곽테두리
    local w,h =pxsht.width, pxsht.height
    self.rectborder = Rect(w*pxscale,h*pxscale,{strokecolor=Color.RED,strokewidth=3}):addto(self)
    self.rectborder:setanchor(0,0):empty()

    --터치(영역)사각형
    self.taprect = Rect(w*pxscale,h*pxscale):addto(self)
    self.taprect:setanchor(0,0):setalpha(0.01)
    -- if _Cornoa then self.taprect.__shp.isHitTestable = true end


    function self.taprect:ontap(e)

        luasp.pxgrid.redraw(self.__pr)

    end

end


function Pxart:redraw()

    self.pxs:remove()
    local s = luasp._getpxs0{self.pxsht}
    self.pxs = Pixels(s):addto(self):setscale(pxscale):setanchor(0,0)

end


--------------------------------------------------------------------------------

local pxartset = Group():setxy(xmargin+400, luasp.btoolbar.height+1300)

local pxart1 = Pxart(luasp.pxshts[1]):addto(pxartset)
pxartset[1] = pxart1

local pxart2 = Pxart(luasp.pxshts[2]):addto(pxartset):setx(150)
pxartset[2] = pxart2

luasp.pxgrid.redraw(pxart2)

--------------------------------------------------------------------------------

luasp.pxartset = pxartset