--------------------------------------------------------------------------------
-- 2021/08/20: Image클래스와 ImageRegion을 재구성
--------------------------------------------------------------------------------
local Disp = Display
local rooturl = _luasopia.root .. '/' -- 2021/05/12
local int = math.floor
--------------------------------------------------------------------------------
ImageRegion = class(Disp)
--------------------------------------------------------------------------------
local newImage
--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------

    -- print('core.Image(gid)')
    local newTxt = _Gideros.Texture.new
	local newTxtRgn = _Gideros.TextureRegion.new
    local newBmp = _Gideros.Bitmap.new
    
    local newGroup = _Gideros.Sprite.new
    
    newImage = function(self, url, rect)

		self.__bd = newGroup()
        local w,h=rect.width, rect.height
        local txtr = newTxtRgn(newTxt(url), rect.x, rect.y, w, h)
		local img = newBmp(txtr)
        self.__bd:addChild(img)

		img:setPosition(-int((w-1)*0.5), -int((w-1)*0.5))
        self.__wdt, self.__hgt = w, h
        self.__img = img

    end

    --------------------------------------------------------------------------------
    -- texture를 외부에서 따로 만들어서 여러 객체에서 공유하는 거나
    -- 아래(init())와 같이 개별 객체에서 별도로 만드는 경우나 textureMemory의 차이가 없다.
    --------------------------------------------------------------------------------
    -- function Image:init(url) -- 2021/08/20:공통메서드로 밖으로 뺐다.


--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------
    -- print('core.Image(cor)')
    local newGroup = _Corona.display.newGroup

	local newImgSht = _Corona.graphics.newImageSheet
    local newImg = _Corona.display.newImage
    --------------------------------------------------------------------------------

	newImage = function(self, url, rect)

        self.__bd = newGroup()
		local opt = {frames={[1]=rect}}
		-- {
		-- 	{x=sht.x, y=sht.y, width=sht.width, height=sht.height} -- frame 1
		-- }
		local img = newImg( newImgSht(url, opt), 1)
		
        local w,h = rect.width, rect.height
		img.x, img.y = -int((w-1)*0.5), -int((h-1)*0.5)
        
		self.__bd:insert(img)
        self.__wdt, self.__hgt = w, h
        self.__img = img

    end

    
    ImageRegion.tint = Image.tint

end -- if _Gideros elseif _Corona
--------------------------------------------------------------------------------

function ImageRegion:init(url, rectinfo)

	newImage(self, rooturl..url, rectinfo)

	------------------------------------------------------------
	--2021/05/09 : add info for collision box
	local w, h = rectinfo.width, rectinfo.height
	local hw, hh = w*0.5, h*0.5
	local invw, invh = 1/w, 1/h
	self.__cpg = {-hw,-hh,invh,  hw,-hh,invw,  hw,hh,invh,  -hw,hh,invw}
	------------------------------------------------------------
	self.__apx, self.__apy = 0.5, 0.5

	return Disp.init(self)

end 

ImageRegion.__setimgxy__ = Image.__setimgxy__
ImageRegion.remove = Image.remove


ImageRegion.setanchor = Image.setanchor
-- ImageRegion.anchor = ImageRegion.setanchor