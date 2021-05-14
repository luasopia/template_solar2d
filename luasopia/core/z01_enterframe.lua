
local Disp = Display
local Tmr = Timer
local lsp = _luasopia

local update = function()

	Tmr.updateAll()
	Disp.updateAll()
	
end

if _Gideros then

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, update)

elseif _Corona then

	Runtime:addEventListener( "enterFrame", update)

elseif _Love then

end


--  local noupd = false; Timer(500, function() noupd=true end)
local function setdebug() -- 디버그모드일 경우 호출됨

	local int = math.floor
	local mtxts = {}
	
	local getTxtMem
	local TCOLOR = Color.LIGHT_PINK
	
	mtxts[1] = Text(""):addto(lsp.loglayer):xy(screen.centerx, 30):color(TCOLOR)
	mtxts[2] = Text(""):addto(lsp.loglayer):xy(screen.centerx, 90):color(TCOLOR)
	-- mtxts[1] = Text("", _luasopia.loglayer):xy(screen.centerx, 30)--:color(255,182,193)
	-- mtxts[2] = Text("", _luasopia.loglayer):xy(screen.centerx, 90)--:color(255,182,193)
	_luasopia.dcdobj = _luasopia.dcdobj + 2

	local dbgupd = function()
		-- if noupd then return end
		Tmr.updateAll()
		Disp.updateAll()

		local txtmem = getTxtMem()
		local mem = int(collectgarbage('count'))
		mtxts[1]:string('mem: %d kb, texture mem: %d kb', mem, txtmem)
		local ndisp = Disp.__getNumObjs() -- - logf.__getNumObjs() - 2
		mtxts[2]:string('Disp:%d, Timer:%d', ndisp, Timer.__getNumObjs())

	end

	if _Gideros then
		
		_Gideros.stage:removeEventListener(_Gideros.Event.ENTER_FRAME, update)

		getTxtMem = function() return _Gideros.application:getTextureMemoryUsage() end
		_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, dbgupd)

	elseif _Corona then
		
		Runtime:removeEventListener( "enterFrame", update)

		getTxtMem = function() return system.getInfo("textureMemoryUsed") / 1000 end
		Runtime:addEventListener( "enterFrame", dbgupd)

	elseif _Love then

	end

end
	
return setdebug