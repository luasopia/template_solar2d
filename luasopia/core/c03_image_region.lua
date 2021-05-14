-- if not_required then return end -- This prevents auto-loading in Gideros
local Display = Display
local rooturl = _luasopia.root .. '/' -- 2021/05/12

ImageRegion = class(Display)

if _Gideros then
	-- print('core.imageRegion(Gid)')

	local Texture_new = _Gideros.Texture.new
	local Bitmap_new = _Gideros.Bitmap.new
	local TextureRegion_new = _Gideros.TextureRegion.new
	--============================================================================== 
	-- sht = {x=n, y=n, width=n, height=n,
	--	__textureRegion -- 첫 번째 호출에서 생성됨
	-- }
	-- __textureRegion은 첫 호출에서 저장한다.
	-- 두 번째 이후에는 Texture.new()를 호출할 필요없이 저장된 것을 사용
	--============================================================================== 

	--------------------------------------------------------------------------------
	function ImageRegion:init(url, sht)
		local tr = TextureRegion_new(Texture_new(rooturl..url), sht.x, sht.y, sht.width, sht.height)
		self.__bd = Bitmap_new(tr)
		self.__bd:setAnchorPoint(0.5, 0.5)
		self.__sht = sht
		return Display.init(self)
	end

elseif _Corona then

	-- print('core.imageRegion(Cor)')
	local newImgSht = _Corona.graphics.newImageSheet
	local newImg =  _Corona.display.newImage

	function ImageRegion:init(url, sht)
		local opt = {frames={[1]=sht}}
		-- {
		-- 	{x=sht.x, y=sht.y, width=sht.width, height=sht.height} -- frame 1
		-- }
		local imgsht = newImgSht(rooturl..url, opt)
		self.__bd = newImg(imgsht, 1)
		self.__bd.anchorX, self.__bd.anchorY = 0.5, 0.5
		self.__sht = sht
		return Display.init(self)
	end

end

--2020/08/26:added
function ImageRegion:getwidth() return __sht.width end
function ImageRegion:getheight() return __sht.height end