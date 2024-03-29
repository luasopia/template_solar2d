--------------------------------------------------------------------------------
-- 2020/08/23: Image클래스의 인수를 url 한 개만으로
-- x,y는 int()로 변환하여 설정해야 pixel모드에서도 위치가 정확해진다
-- 2021/09/26: ImageSheet객체도 사용할 수 있도록 변경
--------------------------------------------------------------------------------
local luasp = _luasopia
local Disp = luasp.Display
local rooturl = luasp.root .. '/' -- 2021/05/12
local int = math.floor
local type0 = luasp.type0
--------------------------------------------------------------------------------
local newImageFile, newImageFrame
--------------------------------------------------------------------------------
Image = class(Disp)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------

    -- print('core.Image(gid)')
    local newTxt = _Gideros.Texture.new
    local newBmp = _Gideros.Bitmap.new
    --local newGroup = _Gideros.Sprite.new

    ----------------------------------------------------------------------------
    -- texture를 외부에서 따로 만들어서 여러 객체에서 공유하는 거나
    -- 아래(init())와 같이 개별 객체에서 별도로 만드는 경우나
    --  textureMemory의 차이가 없다.
    ----------------------------------------------------------------------------
    newImageFile = function(self, url)

        local img = newBmp(newTxt(url))
        self.__bd = img

        -- 2020/06/20 arguement true means 'do not consider transformation'
        local w, h = img:getWidth(true), img:getHeight(true)
        img:setAnchorPoint(0.5, 0.5)
        return w, h

    end


    newImageFrame = function(self, isht, idfrm)

        local img = newBmp(isht.__txts[idfrm])
        self.__bd = img

        -- 2020/06/20 arguement true means 'do not consider transformation'
        local w, h = img:getWidth(true), img:getHeight(true)
        img:setAnchorPoint(0.5, 0.5)
        return w, h

    end


    -- gideros는 localtoGlobal(0,0)은 anchor점의 전역좌표를 반환한다
    -- 아래함수는 앵커점의 위치와 상관없이 img의 중심을 원점으로 한 좌표를 반환
    -- 즉 __getgxy__(0,0)은 image의 중심점의 전역좌표값을 반환한다.
    function Image:__getgxy__(x,y)

        -- x,y는 꼭지점의 좌표가 들어오므로 nil은 확실히 아니다.
        x, y = (x or 0)+self.__x0, (y or 0)+self.__y0
        return self.__bd:localToGlobal(x,y)

    end
    --]]

    
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    local newImg = _Corona.display.newImage
    --local newGroup = _Corona.display.newGroup

    
    newImageFile = function(self, url)

        local img = newImg(url) -- newImage(parent, url)
        self.__bd = img
        
        local w, h = img.width, img.height
        -- 앵커점을 고려하여 child의 xy좌표 설정. 초기앵커는 (0.5,0.5)
        -- pxmode에서 정확히 ap(1,1)가 우하점이 되려면 w-1, h-1를 사용해야 한다.
        img.anchorX, img.anchorY = 0.5, 0.5
        return w,h

    end
    
    
    newImageFrame = function(self, isht, idfrm)

        local img = newImg(isht.__txts, idfrm) -- newImage(parent, url)
        self.__bd = img
        
        local w, h = img.width, img.height
        -- 앵커점을 고려하여 child의 xy좌표 설정. 초기앵커는 (0.5,0.5)
        -- pxmode에서 정확히 ap(1,1)가 우하점이 되려면 w-1, h-1를 사용해야 한다.
        img.anchorX, img.anchorY = 0.5, 0.5
        return w,h

    end

    -- 2021/08/22: SOLAR2D 는 
    -- anchor point와 상관없이 localToContent()는 image의 중심점을 원점으로 한다.
    -- (반면 gideros는 앵커점이 원점이 된다. <-이게 정상임 )
    -- 따라서 getGlobalXY()를 아래와 같이 앵커점을 원점으로 삼도록 수정해야 한다.
    -- 즉, 아래에서 getGlobalXY(0,0)는 앵커점의 전역좌표를 반환한다.
    -- --[[
    function Image:getGlobalXY(x,y)
        puts('Image:ggxy')
        local x,y = (x or 0)-self.__x0, (y or 0)-self.__y0
        return self.__bd:localToContent(x,y)

    end
    --]]
    
    -- ishit()함수에서 사용하는 전역xy를 구하는 함수로서
    -- 앵커점의 위치와 상관없이 Image의 중심점을 원점으로 하는 전역좌표를 반환해야 한다
    -- 따라서 solar2d는 Disp.getglobalxy를 그대로 사용하면 된다.
    Image.__getgxy__ = Disp.getGlobalXY
    
--]]

    
end -- if _Gideros elseif _Corona
--------------------------------------------------------------------------------



function Image:init(url, idFrame)

    local w, h
    if type0(url) == 'string' then

        w, h = newImageFile(self, rooturl..url)

    else

        w, h = newImageFrame(self, url, idFrame)

    end
    ------------------------------------------------------------
    --2021/05/09 : add info for collision box
    local hw, hh = w*0.5, h*0.5
    self.__orct = {-hw,-hh,  hw,-hh,  hw,hh,  -hw,hh} -- outer rectangle
    self.__cpg = {-hw,-hh,  hw,-hh,  hw,hh,  -hw,hh} -- collision polygon
    ------------------------------------------------------------
    self.__apx, self.__apy = 0.5, 0.5
    self.__wdt, self.__hgt = w, h
    -- self.__x0, self.__y0 = 0,0 --> to Disp.init()

    return Disp.init(self)

end 


-- anchor를 변경시킬 때 중심점(x0,y0)도 갱신해야 한다.
function Image:setAnchor(ax, ay)
    
    -- (새로운)앵커점을 원점으로 했을 때의 image 중심의 좌표를 계산
    local w_1, h_1 = self.__wdt-1, self.__hgt-1
    self.__x0, self.__y0 = int((0.5-ax)*w_1), int((0.5-ay)*h_1)
    
    return Disp.setAnchor(self, ax,ay)

end