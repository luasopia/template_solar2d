
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
	Disp.updateAll(luasp.isoddfrm)
	
end


if _Gideros then

	_Gideros.stage:addEventListener(_Gideros.Event.ENTER_FRAME, upd)

elseif _Corona then

	Runtime:addEventListener( "enterFrame", upd)
	nxtupd = upd30
	
elseif _Love then
	
end

luasp.enterfrm = upd -- gid/solard2d 둘 다에서 사용된다.

--2021/08/28: pixel모드에서 30fps로 변경하는 것은 포기.
-- gid, s2d 모두 문제가 있다.