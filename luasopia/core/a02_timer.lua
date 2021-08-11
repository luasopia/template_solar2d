-- 2020/06/24 리팩토링 : timers[tmr]=tmr 로 저장
--------------------------------------------------------------------------------
-- print('core.timer')

local tIn = table.insert
local tRm = table.remove
local tmgapf = 1000/_luasopia.fps -- 1frame에 소요되는시간[ms]
--------------------------------------------------------------------------------
-- 2020/01/15 times that is NOT use intrinsic (Gideros/Corona) Timer class
--
-- tmr = Timer(delay, fn [,loops [,onend]])
--
-- 	After delay (in milliseconds), fn (function) is called.
-- 	loops (default=1) designates the total number of calling fn
-- 	if loops is INF, then func is called infinitely with time gap of delay
--
-- 	arguments given to func call : event = {
--	   	count = n, 	-- count of executing callback function
--     	isfinal (bool) -- it is true if it is a final call
--     	time 		-- time elapsed
-- 	}
-- 	멤버변수 ------------------------------------------------------------------
--     	tmr.delay
-- 		tmr.count
-- 		tmr.loops
--------------------------------------------------------------------------------
Timer = class()
-- private static member variable
Timer.__tmrs = {}
local timers = Timer.__tmrs
-- local ntmrs = 0
--------------------------------------------------------------------------------
-- 타이머객체의 삭제는 이 함수안에서만 이루어지도록 해야 한다.(그래야 덜 꼬임)
-- 외부에서는 remove() 만 호출하면 된다 
-- public static method
--------------------------------------------------------------------------------
function Timer.updateAll()

	for _, tmr in pairs(timers) do

		if tmr.__alive then -- 2021/08/11

			tmr.__tm = tmr.__tm + tmgapf
			local count = tmr.__tm/tmr.delay - 1

			while  count > tmr.count do

				tmr.count = tmr.count + 1
				local isfinal = tmr.count == tmr.loops

				local event = { --callback 함수에 넘겨질 파라메터
					count = tmr.count,
					isfinal = isfinal,
					time = tmr.__tm, -- 2020/06/24 added
				}

				if tmr.__dobj then -- display object에 붙어있는 타이머의 경우

					local dobj = tmr.__dobj
					tmr.__fn(dobj, event) --dobj를 (self로) 먼저 넘김

					if isfinal and dobj.__bd ~=nil then

						if tmr.__onend then
							tmr.__onend(dobj, event) --dobj를 먼저 넘김
						end
											
						dobj.__tmrs[tmr] = nil -- dobj안의 tmr객체도 삭제
						timers[tmr] = nil
						break -- while count > tmr.count 를 빠져나간다

					end

				else -- 일반적인 타이머인 경우

					tmr.__fn(event)

					if isfinal then

						if tmr.__onend then
							tmr.__onend(event)
						end
						
						timers[tmr] = nil
						break -- while count > tmr.count 를 빠져나간다

					end

				end

			end -- while  count > tmr.count do

		end -- if tmr.__alive then

	end --for _, tmr in pairs(timers) do
end


------------------------------------------------------------------------------------------
function Timer.removeAll()

	for _, tmr in pairs(timers) do
		tmr:remove()
	end

end


-- debug 모드가 아니면 호출되지 않는다
function Timer.__getNumObjs()

	local cnt = 0
	for _, _ in pairs(timers) do
		cnt = cnt + 1
	end
	return cnt

end


------------------------------------------------------------------------------------------
-- 생성자
------------------------------------------------------------------------------------------
function Timer:init(delay, func, loops, onend)

	-- local args = args or {}
	self.delay = delay
	self.loops = loops or 1
	self.count = 0
	self.__fn = func
	self.__tm = 0
	self.__onend = onend
	self.__alive = true -- 2021/08/11
	timers[self]=self

end


function Timer:pause()

	self.__alive = false

end


function Timer:resume()

	self.__alive = true

end


function Timer:remove()

	if self.__dobj then -- display object에 붙어있는 타이머의 경우
		self.__dobj.__tmrs[self] = nil -- dobj안의 tmr객체도 삭제
	end
	timers[self] = nil

end


-- 2021/08/11:added
function Timer:isremoved()

	return timers[self] == nil

end