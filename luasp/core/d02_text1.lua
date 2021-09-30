--------------------------------------------------------------------------------
-- 2021/08/22:한줄짜리 콘솔출력을 위해서 별도로 만든 클래스 (entry, puts 등)
-- 정해진 폰트(consolas), 정해진 앵커포인트(0,1)를 사용한다.
-- gideros와 solar2d 모두에서 정확하게 같은 위치에 한 줄text가 표시된다.
--------------------------------------------------------------------------------
local Color = Color
local Disp = Display
local strf = string.format
local fonturl = 'luasp/ttf/consolas.ttf'
local fontsize0 = 45			-- default font size (50)
local fontcolor0 = Color.WHITE	--default font color
--------------------------------------------------------------------------------

Text1 = class(Disp)

--------------------------------------------------------------------------------

function Text1.getfontsize0()
    return fontsize0
end

--------------------------------------------------------------------------------
if _Gideros then -- for Gideros ###############################################
--------------------------------------------------------------------------------
	
	local ttfnew = _Gideros.TTFont.new
	local tfnew = _Gideros.TextField.new


    -- gideros의 Text객체는 anchor point가 좌하점(0,1)이다
	function Text1:init(str, opt)
        
		self.__str = str
        opt = opt or {}

		self.__fsz = opt.fontSize or fontsize0 -- font size (fsz)
		self.__fclr = opt.color or fontcolor0

        local font = ttfnew(fonturl, self.__fsz)
		local text = tfnew(font, str)
		text:setTextColor(self.__fclr.hex)

		self.__apx, self.__apy = 0, 1
		-- self.__wdt, self.__hgt = text:getWidth(), text:getHeight()

		self.__bd = text

		return Disp.init(self)

	end


	-- r, g, b는 0-255 범위의 정수
	function Text1:setColor(color)

		self.__fclr = color
		self.__bd:setTextColor(color.hex)
		return self

	end


	function Text1:setstr(str)

		self.__str = str
		self.__bd:setText(str)
		-- self.__wdt, self.__hgt = self.__bd:getWidth(), self.__bd:getHeight()
		return self

	end


    function Text1:setstrf(str,...)

		self.__str = strf(str,...)
		self.__bd:setText(self.__str)
		-- self.__wdt, self.__hgt = self.__bd:getWidth(), self.__bd:getHeight()
		return self

	end


-------------------------------------------------------------------------------
elseif _Corona then
-------------------------------------------------------------------------------

	local newText = _Corona.display.newText
	local newGroup =  _Corona.display.newGroup


	function Text1:__mktxt__()


		self.__bd:insert(text)
		self.__tbd = text

		text.x = 0.5*self:getWidth()*(1-2*self.__apx)
		text.y = 0.5*self:getHeight()*(1-2*self.__apy)


		return text

	end

	function Text1:init(str, opt)

		self.__str = str
        opt = opt or {}

        self.__fsz = opt.fontSize or fontsize0 -- font size (fsz)
		self.__fclr = opt.color or fontcolor0

        local text = newText{ -- font options
            font = fonturl,
            text = self.__str,
            fontSize = self.__fsz
        }
        local fc = self.__fclr
        text:setFillColor(fc.r, fc.g, fc.b)
    
        self.__apx, self.__apy = 0, 1
        -- anchorY를 Gideros와 위치를 정확히 일치시키기 위해서 보정
        text.anchorX, text.anchorY = 0.001, 0.78 -- 0.002, 0.78

		self.__bd = text
		
		return Disp.init(self)

	end

	
	function Text1:setFontSize(v)

		self.__fsz = v
		self.__bd.size = v
		return self

	end
	
	
	function Text1:setstr(str)

		self.__str = str
		self.__bd.text = str  --<<== C stack overflow
		return self

	end

	function Text1:setstrf(str,...)

		self.__str = strf(str,...)
		self.__bd.text = self.__str  --<<== C stack overflow
		return self

	end

	
	-- r, g, b는 0-255 범위의 정수, (r이 color객체일 수도 있음)
	function Text1:setColor(fc)

		self.__tbd:setFillColor(fc.r, fc.g, fc.b)
		self.__fclr = fc -- {r/255,g/255,b/255}
		return self

	end
	

	
end


function Text1:getFontSize()

    return self.__fsz

end

--2020/11/06 added
function Text1:getString()

	return self.__str

end