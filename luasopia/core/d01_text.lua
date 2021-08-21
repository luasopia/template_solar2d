local Color = Color
--------------------------------------------------------------------------------
-- 2020/02/15:아래테이블은 !luasophia/ttf 폴더의 public domain ttf 리스트
-- 첫 번째 폰트가 defualt 폰트로 지정됨
local ttfs = {'opensans', 'typed', 'cabin', 'cruft',}
local ttfurl = 'luasopia/ttf/%s.ttf'
local fontname0 = ttfs[1] 		-- default font 
local fontsize0 = 40			-- default font size (50)
local fontcolor0 = Color.WHITE	--default font color
--------------------------------------------------------------------------------
local Disp = Display
local strf = string.format


-- 지정한 ttf이름이 valid한지 체크하는 함수
local function isvalid(name)

	for _, v in ipairs(ttfs) do
		if v==name then return true end
	end

end


-- 2020/02/15:font name이 잘못 지정되었을 때의 에러메세지를 생성
local function errmsg()

	local msg = 'Invalid font name. It must be one of '
	for k, v in ipairs(ttfs) do 
		if k==#ttfs then msg = msg .. strf("and '%s'.",v)
		else msg = msg .. strf("'%s', ",v) end
	end
	return msg

end
--------------------------------------------------------------------------------
Text = class(Disp)
--------------------------------------------------------------------------------


function Text.setDefaultFont(fontname)

	if assert(isvalid(fontname), errmsg()) then
		fontname0 = fontname
	end

end


function Text.setDefaultFontSize(size)

	fontsize0 = size

end

--------------------------------------------------------------------------------
if _Gideros then -- for Gideros ###############################################
--------------------------------------------------------------------------------
	
	local ttfnew = _Gideros.TTFont.new
	local tfnew = _Gideros.TextField.new


	-- gideros는 문자열이 여러 줄일 경우에도 anchor point가 첫줄의 좌하점이 된다
	-- 아래는 여러 줄일 경우에 y축의 중점을 잡기 위한 setAnchorPoint(x,y)
	-- 에서 y값(보정값)을 구하는 함수 (corona에서는 자동으로 중점이 잡힌다.)
	-- local apys = {[0] = -0.35, 0.15, 0.27, 0.34, 0.36, 0.4, 0.41}
	-- 2021/06/08일 apys값들 다시 보정
	-- local apys = {[0] = -0.52, 0.132, 0.28, 0.34, 0.36, 0.4, 0.41}
	local apys = {[0] = -0.35, 0.132, 0.28, 0.34, 0.36, 0.4, 0.41}

	local function getya(str) -- 보정할 anchorY값을 구한다.

		local nn = select(2, str:gsub('\n', '\n')) -- number of '\n' character
		if nn>6 then return 0.41 end
		return apys[nn] -- 1:-0.35,  2:0.15, 3:0.27, 4:0.34

	end


	function Text:__mktxt__()

		local fonturl
		if assert(isvalid(self.__fnm), errmsg()) then
			fonturl = strf(ttfurl, self.__fnm)
		end

		local font = ttfnew(fonturl, self.__fsz)
		local text = tfnew(font, self.__str)
		text:setTextColor(self.__fclr.hex)

		self.__wdt, self.__hgt = text:getWidth(), text:getHeight()
		self.__hwdt, self.__hhgt = self.__wdt*0.5, self.__hgt*0.5
		
		self.__bd:addChild(text)
		
		-- 보정을 해서 anchor point가 문자열의 중심점이 되도록 한다.
		text:setAnchorPoint(0.5, getya(self.__str)) -- 1:-0.35,  2:0.15, 3:0.27, 4:0.34
		
		-- anchor point는 group내에서의 xy좌표를 조절해서 설정
		text:setX( self.__hwdt*(1-2*self.__apx) )
		text:setY( self.__hhgt*(1-2*self.__apy) )
		
		self.__tbd = text
		return self
		
	end


	-- 2020/02/15: text의 size를 조절하기 위해 sprite안에 text를 삽입
	function Text:init(str, opt)

		self.__str = str
        opt = opt or {}

		self.__fnm = opt.font or fontname0 -- font name(fnm)
		self.__fsz = opt.fontsize or fontsize0 -- font size (fsz)
		self.__fclr = opt.color or fontcolor0

		self.__apx, self.__apy = 0.5, 0.5

		self.__bd = _Gideros.Sprite.new()
		self:__mktxt__()

		return Disp.init(self)

	end


	function Text:setfont(fontname, size)

		self.__fnm = fontname -- fontname은 필수요소임
		self.__fsz = size or self.__fsz -- size가 nil이면 기존크기로
		
		self.__bd:removeChildAt(1)
		return self:__mktxt__()

	end


	-- r, g, b는 0-255 범위의 정수
	function Text:setcolor(color)

		self.__fclr = color
		self.__tbd:setTextColor(color.hex)
		return self

	end


	-- 2020/01/28 text가 변경되면 중심점도 다시 잡아야 한다.
	function Text:setstring(str,...)

		local text = self.__tbd

		self.__str = strf(str,...)
		text:setText(self.__str)

		self.__wdt, self.__hgt = text:getWidth(), text:getHeight()
		self.__hwdt, self.__hhgt = self.__wdt*0.5, self.__hgt*0.5
		
		-- 보정을 해서 anchor point가 문자열의 중심점이 되도록 한다.
		text:setAnchorPoint(0.5, getya(self.__str)) -- 1:-0.35,  2:0.15, 3:0.27, 4:0.34
		
		-- anchor point는 group내에서의 xy좌표를 조절해서 설정
		text:setX( self.__hwdt*(1-2*self.__apx) )
		text:setY( self.__hhgt*(1-2*self.__apy) )

		return self

	end


	--2021/08/21:str 내용 그대로 문자열로. entry위젯에서 사용된다.
	--왜냐면 문자열에 '%'문자가 포함되면 string.format에서 오류가 나기 때문이다.
	function Text:settext(str)

		local text = self.__tbd

		self.__str = str
		text:setText(self.__str)

		self.__wdt, self.__hgt = text:getWidth(), text:getHeight()
		
		--entry에서 문자를 입력할때마다 위치가 변경되는것을 막기위해서
		--아래를 블락처리했다.
		--[[
		self.__hwdt, self.__hhgt = self.__wdt*0.5, self.__hgt*0.5
		
		-- 보정을 해서 anchor point가 문자열의 중심점이 되도록 한다.
		text:setAnchorPoint(0.5, getya(self.__str)) -- 1:-0.35,  2:0.15, 3:0.27, 4:0.34
		
		-- anchor point는 group내에서의 xy좌표를 조절해서 설정
		text:setX( self.__hwdt*(1-2*self.__apx) )
		text:setY( self.__hhgt*(1-2*self.__apy) )
		--]]
		return self

	end



	function Text:setfontsize(v)

		self.__fsz = v
		self.__bd:removeChildAt(1)
		return self:__mktxt__()

	end

	--[[ -- 소멸자를 오버로딩하나 안하나 textmem은 차이가 없음
	function Text:remove()
		self.__tbd:removeFromParent()
		Disp.remove(self)
	end
--]]

	function Text:getfontsize() return self.__fsz end


	-- 2021/06/05 group내에서의 xy좌표를 이동하여 anchor point를 설정한다.
	function Text:setanchor(apx, apy)

		self.__apx, self.__apy = apx, apy
		self.__tbd:setX( self.__hwdt*(1-2*apx) )
		self.__tbd:setY( self.__hhgt*(1-2*apy) )
		return self

	end

	
-------------------------------------------------------------------------------
elseif _Corona then
-------------------------------------------------------------------------------

	function Text.setDefaultColor(r,g,b)

		fontcolor0={r/255,g/255,b/255}
	
	end


	local newText = _Corona.display.newText
	local newGroup =  _Corona.display.newGroup


	function Text:__mktxt__()

		local fonturl
		if assert(isvalid(self.__fnm), errmsg()) then
			fonturl = strf(ttfurl, self.__fnm)
		end

		local text = newText({ -- font options
			text = self.__str,
			font = fonturl,
			fontSize = self.__fsz
		})

		text.anchorX, text.anchorY = 0.5,0.5 -- 2021/08/13

		local fc = self.__fclr
		text:setFillColor(fc.r, fc.g, fc.b)

		self.__bd:insert(text)
		self.__tbd = text

		text.x = 0.5*self:getwidth()*(1-2*self.__apx)
		text.y = 0.5*self:getheight()*(1-2*self.__apy)


		return text

	end

	function Text:init(str, opt)

		self.__str = str
        opt = opt or {}
        -------------------------------------------------------------------------
		self.__fnm = opt.font or fontname0 -- font name(fnm)
		self.__fsz = opt.fontsize or fontsize0 -- font size (fsz)
		self.__fclr = opt.color or fontcolor0

		self.__apx, self.__apy = 0.5, 0.5

		self.__bd = newGroup()
		self:__mktxt__()
		
		return Disp.init(self)

	end

	
	function Text:setfontsize(v)

		self.__fsz = v
		self.__tbd.size = v

		-- fontsize가 변경되었다면 anchor point도 다시 잡아줘야된다.
		self.__tbd.x = 0.5*self:getwidth()*(1-2*self.__apx)
		self.__tbd.y = 0.5*self:getheight()*(1-2*self.__apy)
		
		return self

	end
	
	
	function Text:setstring(str,...)

		self.__str = strf(str,...)
		self.__tbd.text = self.__str  --<<== C stack overflow

		-- string이 변경되었다면 anchor point도 다시 잡아줘야된다.
		self.__tbd.x = 0.5*self:getwidth()*(1-2*self.__apx)
		self.__tbd.y = 0.5*self:getheight()*(1-2*self.__apy)

		return self
	end


	--2021/08/21:str 내용 그대로 문자열로. entry위젯에서 사용된다.
	--왜냐면 문자열에 '%'문자가 포함되면 string.format에서 오류가 난다
	function Text:settext(str)

		self.__str = str
		self.__tbd.text = self.__str  --<<== C stack overflow

		-- string이 변경되었다면 anchor point도 다시 잡아줘야된다.
		self.__tbd.x = 0.5*self:getwidth()*(1-2*self.__apx)
		self.__tbd.y = 0.5*self:getheight()*(1-2*self.__apy)

		return self
	end

	
	-- r, g, b는 0-255 범위의 정수, (r이 color객체일 수도 있음)
	-- function Text:setcolor(r,g,b)
	function Text:setcolor(fc)

		self.__tbd:setFillColor(fc.r, fc.g, fc.b)
		self.__fclr = fc -- {r/255,g/255,b/255}
		return self

	end
	

	function Text:setfont(fontname, size)

		self.__fnm = fontname -- fontname은 필수요소임
		self.__fsz = size or self.__fsz -- size가 nil이면 기존크기로
		self.__tbd:removeSelf()
		self.__tbd = self:__mktxt__()
		self.__bd:insert(self.__tbd)
		return self

	end

	function Text:getfontsize() return self.__tbd.size end
	

	function Text:setanchor(apx, apy)

		self.__apx, self.__apy = apx, apy
		self.__tbd.x = 0.5*self:getwidth()*(1-2*apx)
		self.__tbd.y = 0.5*self:getheight()*(1-2*apy)

		return self

	end


	-- 2020/08/26 added
	function Text:getwidth()

		return self.__bd.width

	end
	
	-- 2020/08/26 Gideros와 같이 문자열 영역을 정확히 계산하기위해서
	-- 높이를 아래와 같이 보정 (solar2d는 실제 높이보다 더 큰수를 반환함)
	function Text:getheight() 

		return self.__bd.height - 0.45*self.__fsz -- 0.6

	end
	
end


--2020/11/06 added
function Text:getstring()

	return self.__str

end

--2021/05/24 added
Text.font = Text.setfont
Text.fontsize = Text.setfontsize
Text.color = Text.setcolor
Text.string = Text.setstring
Text.anchor = Text.setanchor