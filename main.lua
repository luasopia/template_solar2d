-- WARNING!! : Don't edit this file.
-- Instead, start coding 'root/main.lua' since luasopia app starts from that file.

-------------------------------------------------------------------------------
-- 2021/05/13 created
-------------------------------------------------------------------------------


if gideros then

    function require(module)
		
		if package.loaded[module] then return package.loaded[module] end
			
		local m
		if package.preload[module] then
			
			assert(type(package.preload[module])=="function","Module loader isn't a function")
			m=package.preload[module](module) or true
			
		else
			
			if not m then
				local fullpath = string.gsub(module, '%.','/') .. '.lua'
				local luafile, _err = loadfile( fullpath )
				if luafile and type(luafile)=="function" then 
					m=luafile(module) or true
				end		
			end

		end
		assert(m,"Module "..module.." not found")
		package.loaded[module]=m or true
		
		return m
	end

end


require 'luasp.init'

-- in this point, the (relative) root foler is replaced by '/root'
-- require()함수는 \root폴더를 base로 하게끔 'luasp.init' 안에서 치환되었다.
-- The original 'require()' function has been changed its name into '_req()'

-- The '/root/main.lua' file is firstly executed.
return require 'main' -- root/main.lua 파일로 점프(goto)