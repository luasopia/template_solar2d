-- 2022/09/06 created

local x0, y0, endX, endY = screen.x0, screen.y0, screen.endX, screen.endY
local cx, cy = screen.centerX, screen.centerY
local int = math.floor
local halfWdt, halfHgt = 0.5*(endX-x0),0.5*(endY-y0)
local Group, Image = Group, Image


Tile = class(Group)


function Tile:init(url)

    Group.init(self) -- self:setXY(cx,cy)
    
    local img = Image(url)
    local w, h = img:getWidth(), img:getHeight()

    local nX = int(halfWdt/w) + 1
    local nY = int(halfHgt/h) + 1
    puts(numY)

    local cnt = 0

    for yk = -nY*h, nY*h, h do

        for xk = -nX*w, nX*w, w do

            if cnt==0 then
                img:addTo(self):setXY(xk,yk)
            else
                Image(url):addTo(self):setXY(xk,yk)
            end

            cnt = cnt + 1

        end

    end
    
    self.__tlCnt = cnt -- total number of images
    self.__tlWdt, self.__tlHgt = w, h
    puts(nX,nY,cnt)

end


local function updY(self)

    self:setY(self.__bdy + self.__tlDy)

    if self.__bdy-cy >= self.__tlHgt then
        self:setY(self.__bdy - self.__tlHgt)
    elseif self.__bdy-cy <= -self.__tlHgt then
        self:setY(self.__bdy + self.__tlHgt)
    end

end


function Tile:scrollY(dy)

    self.__tlDy = dy
    return self:__addUpd__(updY)

end

local function updX(self)
    
    self:setX(self.__bdx + self.__tlDx)

    if self.__bdx-cx >= self.__tlWdt then
        self:setX(self.__bdx - self.__tlWdt)
    elseif self.__bdx-cx <= -self.__tlWdt then
        self:setX(self.__bdx + self.__tlWdt)
    end

end


function Tile:scrollX(dx)

    self.__tlDx = dx
    return self:__addUpd__(updX)

end


function Tile:scrollXY(dx,dy)
    
    self:scrollX(dx)
    self:scrollY(dy)

end