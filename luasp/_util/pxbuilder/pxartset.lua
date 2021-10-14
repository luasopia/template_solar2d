local luasp=_luasopia

local palette = luasp.palette0



local xmargin, ymargin = 10, 400

local pxscale = 10


--------------------------------------------------------------------------------

local Pxart = class(LabelBox)

function Pxart:init(pxsht, id)

    self.pxsht = pxsht
    self.id = id
    
    local s = luasp._getpxs0{self.pxsht}
    local pxs = Pixels(s):setScale(pxscale):setAnchor(0,0)
    local w,h =pxsht.width, pxsht.height
    
    
    LabelBox.init(self, tostring(id),w*pxscale,h*pxscale)
    pxs:addTo(self)
    self.pxs = psx
    -- -- 외곽테두리
    -- self.rectborder = Rect(w*pxscale,h*pxscale,{strokeColor=Color.RED,strokeWidth=3}):addTo(self)
    -- self.rectborder:setAnchor(0,0):empty()

    --터치(영역)사각형
    self.taprect = Rect(w*pxscale,h*pxscale):addTo(self)
    self.taprect:setAnchor(0,0):setAlpha(0.01)
    -- if _Cornoa then self.taprect.__shp.isHitTestable = true end


    function self.taprect:onTap(e)

        luasp.pxgrid.redraw(self.__pr)

    end

end


function Pxart:redraw()

    self.pxs:remove()
    local s = luasp._getpxs0{self.pxsht}
    self.pxs = Pixels(s):addTo(self):setScale(pxscale):setAnchor(0,0)

end


--------------------------------------------------------------------------------

local pxartset = LabelBox('',1070,300):setXY(xmargin, ymargin)

function pxartset:setsheet(pxshts, showname)
    
    self:clear()
    self:setlabel(showname)

    self.arts = {}
    
    local x,y = 20, 50
    for id, sht in ipairs(pxshts) do

        self.arts[#self.arts+1] = Pxart(sht, id):addTo(self):setXY(x,y)
        x=x+200
    end

    -- luasp.pxgrid.redraw(pxart2)

end
--------------------------------------------------------------------------------

return pxartset