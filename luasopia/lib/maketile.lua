local Group, Image = Group, Image
local x0, y0, endx, endy = screen.x0, screen.y0, screen.endx, screen.endy
local cx, cy = screen.centerx, screen.centery
local tblin = table.insert
--------------------------------------------------------------------------------
local function update(self)

    if self._xspd ~= 0 then
        local w = self._imgw

        local xmin, xmax, mincol, maxcol = cx, cx

        for k, col in ipairs(self._cols) do
            col.x = col.x + self._xspd
            for _, img in ipairs(col) do img:x(col.x) end
            if col.x < xmin then
                xmin = col.x
                mincol = col
            elseif col.x > xmax then
                xmax = col.x
                maxcol = col
            end
        end 

        -- 가장 끝쪽의 열(column)만 맨 처음으로 옮긴다
        if self._xspd > 0 then 
            if xmax > endx + w/2 then
                maxcol.x = xmin - w
                for _, img in ipairs(maxcol) do img:x(maxcol.x) end
            end
        else -- if self._xspd < 0 then
            if xmin<x0-w/2 then
                mincol.x = xmax + w
                for _, img in ipairs(mincol) do img:x(maxcol.x) end

            end
        end
    end

    if self._yspd ~= 0 then
        local h = self._imgh
        local ymin, ymax, minrow, maxrow = cy, cy

        for k, row in ipairs(self._rows) do
            row.y = row.y + self._yspd
            for _, img in ipairs(row) do img:y(row.y) end
            if row.y < ymin then
                ymin = row.y
                minrow = row
            elseif row.y > ymax then
                ymax = row.y
                maxrow = row
            end
        end 

        if self._yspd > 0 then
            if ymax > endy + h/2 then
                maxrow.y = ymin - h
                for _, img in ipairs(maxrow) do img:y(maxrow.y) end
            end
        else -- if self._yspd < 0 then
            if ymin<y0-h/2 then
                minrow.y = ymax + h
                for _, img in ipairs(minrow) do img:y(maxrow.y) end
            end
        end
    end

end

local function scrollx(self, dx)
    self._xspd = dx
    self._yspd = 0
    return self
end

local function scrolly(self, dy)
    self._yspd = dy
    self._xspd = 0
    return self
end

local function scrollxy(self, dx, dy)
    self._xspd = dx
    self._yspd = dy
    return self
end

--------------------------------------------------------------------------------
lib.Tile = class(Group)
local Tile = lib.Tile

function lib.maketile(url)
    local tile = Group()
    tile:xy(0,0)
    
    tile._rows={}
    tile._cols={}

    local img = Image(url)
    local w, h = img:getwidth(), img:getheight()
    img:remove()
    
    local imgs = {}
    local rowk, colk = 0, 0
    for yk = y0-h, endy+h, h do
        rowk = rowk + 1
        tile._rows[rowk] = {y=yk}
        colk = 0
        for xk = x0-w, endx+w, w do
            colk = colk + 1
            local img = Image(url):addto(tile):xy(xk,yk)
            img.rowk, img.colk = rowk, colk
            
            table.insert(tile._rows[rowk], img)
            
            tile._cols[colk] = tile._cols[colk] or {x=xk}
            tblin(tile._cols[colk], img)
        end
    end

    tile._xspd, tile._yspd = 0, 0
    tile._imgw, tile._imgh = w, h

    tile.update = update

    -- public method
    tile.scrollx = scrollx
    tile.scrolly = scrolly
    tile.scrollxy = scrollxy

    return tile
end

--[[
function Tile:update()
    if self._xspd == 0 and self._yspd == 0 then return end
    -- print('tile update')

    local cxmin, cxmax = cx, cx
    local cymin, cymax = cy, cy
    local w, h = self._imgw, self._imgh

    for _, img in ipairs(self._imgs) do    
        local x, y = img:getxy()

        img:xy(x + self._xspd, y + self._yspd)

        if x<cxmin then cxmin = x end
        if x>cxmax then cxmax = x end
        if y<cymin then cymin = y end
        if y>cymax then cymax = y end
    end 

    for _, img in ipairs(self._imgs) do    
        local x, y = img:getxy()

        if x>endx+w/2 and self._xspd>0 then
            img:x(cxmin-w)
        elseif x<x0-w/2 and self._xspd<0 then
            img:x(cxmax+w)
        end

        if y>endy+h/2 and self._yspd>0 then
            img:y(cymin-h)
        elseif y<y0-h/2 and self._yspd<0 then
            img:y(cymax+h)
        end

    end
end
--]]

