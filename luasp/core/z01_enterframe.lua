
local Disp = Display
local Tmr = Timer
local luasp = _luasopia

local prvupd -- 직전에 등록되어 현재 사용되고 있는 update함수
local nxtupd -- solar2d에서 30frm으로 변경된 경우에 등록할 update함수


-- soler2d/gideros update function in fps=60
luasp.isoddfrm = true
local upd = function() 
	
	luasp.isoddfrm = not luasp.isoddfrm -- 2021/08/23
	Tmr.updateAll()
	Disp.updateAll()
	
end

--[[
-- soler2d update function in fps=30
-- gideros 같은 경우 application:serFps(30)을 하면 기존 함수를 유지한다
-- solar2d는 30fps로 보일 뿐이지 내부적으로는 60fps로 동작한다.
-- 즉, 화면을 1초에 60번 그린다. 따라서 완벽한 30fps는 아니다
local isoddfrm = true -- 2021/08/23
local upd30 = function()

	isoddfrm = not isoddfrm -- 2021/08/23
	if isoddfrm then return end
	
	Tmr.updateAll()
	Disp.updateAll()
	
end
--]]


if _Gideros then

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, upd)

elseif _Corona then

	Runtime:addEventListener( "enterFrame", upd)
	nxtupd = upd30
	
elseif _Love then
	
end

prvupd = upd -- gid/solard2d 둘 다에서 사용된다.

--  local noupd = false; Timer(500, function() noupd=true end)
local function setdebug() -- 디버그모드일 경우 호출됨

	-- local int = math.floor
	local mtxts = {}
	
	local getTxtMem
	local getFps
	local TCOLOR = Color.LIGHT_PINK
	
	mtxts[1] = Text1("",{color=TCOLOR}):addto(luasp.loglayer)
	mtxts[1]:setxy(10, 45)
	mtxts[1].__nocnt = true

	mtxts[2] = Text1("",{color=TCOLOR}):addto(luasp.loglayer)
	mtxts[2]:setxy(10, 90)
	mtxts[2].__nocnt = true

	mtxts[3] = Text1("",{color=TCOLOR}):addto(luasp.loglayer)
	mtxts[3]:setxy(10, 135)
	mtxts[3].__nocnt = true


	local dbgupd = function(e)

		-- if not luasp.isoddfrm then

			local txtmem = getTxtMem()
			local mem = collectgarbage('count')
			mtxts[1]:setstrf('memory:%d kb,texture memory:%d kb', mem, txtmem)
			local ndisp = Disp.__getNumObjs() -- - logf.__getNumObjs() - 2
			mtxts[2]:setstrf('Display objects:%d, Timer objects:%d', ndisp, Timer.__getNumObjs())
			mtxts[3]:setstrf('fps:%d', getFps(e))
			
		-- end

		return upd()
		
	end

	--[[
	local dbgupd30 = function(e)

		local txtmem = getTxtMem()
		local mem = int(collectgarbage('count'))
		mtxts[1]:setstrf('memory:%d kb,texture memory:%d kb', mem, txtmem)
		local ndisp = Disp.__getNumObjs() -- - logf.__getNumObjs() - 2
		mtxts[2]:setstrf('Display objects:%d, Timer objects:%d', ndisp, Timer.__getNumObjs())

		if _Gideros then mtxts[3]:setstrf('fps:%d', 1/e.deltaTime) end

		return upd30()

	end
	--]]


	if _Gideros then
		
		getTxtMem = function()
			return _Gideros.application:getTextureMemoryUsage()
		end

		_Gideros.stage:removeEventListener(_Gideros.Event.ENTER_FRAME, prvupd)
		_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, dbgupd)
		prvupd = dbgupd

		getFps = function(e)
			return 1/e.deltaTime
		end

	elseif _Corona then
		
		getTxtMem = function()
			return system.getInfo("textureMemoryUsed") / 1000
		end
		
		Runtime:removeEventListener( "enterFrame", prvupd)
		Runtime:addEventListener( "enterFrame", dbgupd)
		prvupd = dbgupd
		nxtupd = dbgupd30

		local prvms = 0
		getFps = function()
			local ms = system.getTimer()
			local fps = 1000/(ms - prvms)
			prvms = ms
			return fps
		end

		--[[
		if luasp.fps==60 then

			Runtime:addEventListener( "enterFrame", dbgupd)
			prvupd = dbgupd
			nxtupd = dbgupd30

		else -- if luasop.fps==30

			Runtime:addEventListener( "enterFrame", dbgupd30)
			prvupd = dbgupd30

		end
		--]]

	elseif _Love then

	end

end


--[[
--2021/08/28: pixel모드에서 30fps로 변경하는 것은 포기.
-- gid, s2d 모두 문제가 있다.

--2021/08/27:created
function luasp.fpsTo30()

	print('changefps:30')
	
	if _Corona then
		 
		Runtime:removeEventListener( "enterFrame", prvupd)
		Runtime:addEventListener( "enterFrame", nxtupd)
		prvupd = nxtupd
		screen.fps = 30

	elseif _Giderso then

		-- 현재의 update함수를 변경할 필요가 없다.
		_Gideros.application:setFps(30)
		-- 아래와 같이 한 번 더 add하면 update가 한 프레임데 두 번 실행된다.
		-- 따라서 아래를 실행하면 안된다.
		-- _Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, update)
		screen.fps = _Gideros.application:getFps()
	
	end

	luasp.fps = screen.fps
	luasp.dtmfrm = 1000/luasp.fps
	print('dtmfrm:'.. luasp.dtmfrm)

end
--]]

return setdebug