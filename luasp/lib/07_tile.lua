--------------------------------------------------------------------------------
-- 2022/09/06 created : scroll할 때 (매번 이미지를 이동시키는 게 아니고)
-- Tile group객체의 좌표를 조절하는 방식으로 작성
--------------------------------------------------------------------------------

local Group, Image = Group, Image
local x0, y0, endX, endY = screen.x0, screen.y0, screen.endX, screen.endY
local int = math.floor
local halfWdt, halfHgt = 0.5*(endX-x0), 0.5*(endY-y0)


Tile = class(Group)


function Tile:init(url)

    Group.init(self) -- self:setXY(cx,cy)
    local img = Image(url)
    local w, h = img:getWidth(), img:getHeight()
    local nX, nY = int(halfWdt/w) + 1, int(halfHgt/h) + 1
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

end


local function updY(self, e)

    if self.__tlDy == nil then return end

    self:setY(self.__bdy + self.__tlDy)

    if self.__bdy-self.__ty0 >= self.__tlHgt then
        self:setY(self.__bdy - self.__tlHgt)
    elseif self.__bdy-self.__ty0 <= -self.__tlHgt then
        self:setY(self.__bdy + self.__tlHgt)
    end

    -- if e.frameCount<300 then
    --     puts(e.frameCount, self.__tlDy)
    -- end
end


function Tile:scrollY(dy)

    self:stopScrollY()

    -- Tile객체를 생성한 후 x/y가 조절되었을 수도 있으므로 현재 y를 저장
    -- 단, scroll -> stop 이후 다시 scroll할 때는 맨처음 저장된 좌표를 사용한다.
    if self.__ty0==nil then
        self.__ty0 = self.__bdy -- tile y original (before scroll)
    end
    self.__tlDy = dy
    return self:__addUpd__(updY)

end


function Tile:stopScrollY()

    self.__tlDy = nil, nil
    return self:__rmUpd__(updY)

end


local function updX(self)
    
    if self.__tlDx == nil then return end

    self:setX(self.__bdx + self.__tlDx)
    if self.__bdx - self.__tx0 >= self.__tlWdt then
        self:setX(self.__bdx - self.__tlWdt)
    elseif self.__bdx - self.__tx0 <= -self.__tlWdt then
        self:setX(self.__bdx + self.__tlWdt)
    end

end


function Tile:scrollX(dx)

    self:stopScrollX()

    -- Tile객체를 생성한 후 x/y가 조절되었을 수도 있으므로 현재 x를 저장
    if self.__tx0 == nil then
        self.__tx0 = self.__bdx  -- tile y original (before scroll)
    end
    self.__tlDx = dx
    return self:__addUpd__(updX)

end


function Tile:scrollXY(dx,dy)
    
    self:scrollX(dx)
    return self:scrollY(dy)

end


function Tile:stopScrollX()

    self.__tlDx = nil
    return self:__rmUpd__(updX)

end




function Tile:stopScroll()

    self:stopScrollX()
    return self:stopScrollY()

end