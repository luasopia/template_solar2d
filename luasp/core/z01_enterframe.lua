
local luasp = _luasopia
local Disp = luasp.Display
local Tmr = Timer


--[[ 2021/09/16 update(e) 함수의 파라메터
	e.deltaTime: (number) time(sec) passed from previous frame 
	e.time: (number) time(sec) passed from app start
	e.frameCount: (number) frame count from app start
--]]


if _Gideros then

	local upd = function(e) 
		
		-- print(e.time, e.deltaTime, e.frameCount)

		--2022/08/31 추가. update()함수 안에서 골라쓰면 된다.
		local frmCnt = e.frameCount
		e.isNotFrm2 = frmCnt%2~=0
		e.isNotFrm5 = frmCnt%5~=0
		e.isNotFrm10 = frmCnt%10~=0
		

		Tmr.updateAll(e)
		Disp.updateAll(e)
		
	end

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, upd)


elseif _Corona then


    local systimer = system.getTimer
	local updarg = {deltaTime = 0, time=0, frameCount=1}


	local upd = function() 

		local sec = systimer()*0.001
		local e = updarg
		e.deltaTime = sec - e.time
		e.time = sec
		e.frameCount  = e.frameCount  + 1
	
		--2022/08/31 추가. update()함수 안에서 골라쓰면 된다.
		local frmCnt = e.frameCount
		e.isNotFrm2 = frmCnt%2~=0
		e.isNotFrm5 = frmCnt%5~=0
		e.isNotFrm10 = frmCnt%10~=0

		Tmr.updateAll(e)
		Disp.updateAll(e)
		
	end


	Runtime:addEventListener( "enterFrame", upd)
	
elseif love then
	
end

--2021/08/28: pixel모드에서 30fps로 변경하는 것은 포기.
-- gid, s2d 모두 문제가 있다.