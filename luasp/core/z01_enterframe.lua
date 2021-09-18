
local Disp = Display
local Tmr = Timer
local luasp = _luasopia


--[[ 2021/09/16 update(e) 함수의 파라메터
	e.deltaTime: (number) time(sec) passed from previous frame 
	e.time: (number) time(sec) passed from app start
	e.frameCount: (number) frame count from app start
--]]


if _Gideros then

	local isoddfrm = true
	local upd = function(e) 
		
		-- _print0(e.time, e.deltaTime, e.frameCount)

		isoddfrm = not isoddfrm -- 2021/08/23
		Tmr.updateAll(e)
		Disp.updateAll(isoddfrm, e)
		
	end

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, upd)


elseif _Corona then


    local systimer = system.getTimer
	local updarg = {deltaTime = 0, time=0, frameCount=1}
	local isoddfrm = true


	local upd = function() 

		local sec = systimer()*0.001
		local e = updarg
		e.deltaTime = sec - e.time
		e.time = sec
		e.frameCount  = e.frameCount  + 1
	
		isoddfrm = not isoddfrm -- 2021/08/23
		Tmr.updateAll(e)
		Disp.updateAll(isoddfrm, e)
		
	end


	Runtime:addEventListener( "enterFrame", upd)
	
elseif love then
	
end

--2021/08/28: pixel모드에서 30fps로 변경하는 것은 포기.
-- gid, s2d 모두 문제가 있다.