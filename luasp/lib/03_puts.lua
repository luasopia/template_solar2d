--------------------------------------------------------------------------------
--2021/08/31: Group객체 안에 Text1객체들을 넣는 것을 리팩토링함
--------------------------------------------------------------------------------
local tIn, tRm = table.insert, table.remove
local int = math.floor
local luasp = _luasopia
local strf = string.format
--------------------------------------------------------------------------------
local linespace = 1.15 -- 줄간격을 0.3으로 설정(너무 붙으면 가독성이 떨어짐)
local botmargin = 20 -- gap from bottom and last line
local leftmargin = 10 
--------------------------------------------------------------------------------
local cli
local txtobjs = {}
local lineHeight =  Text1.getfontsize0()*linespace
local maxlines = int(screen.height0/lineHeight)-3 -- -1
local numlines = 0
-- print('maxlines=',maxlines)


local function initcheck()

    if not _luasopia.loglayer:isvisible() then

        _luasopia.loglayer:show()

    end

    if cli==nil then

        cli = Group():addto(luasp.loglayer)
        cli:setxy(leftmargin, screen.height0-botmargin)
        cli.__nocnt = true -- debugmode에서 display obj의 개수로 카운트하지 않는다

    end

end


-- print()함수의 출력과 유사한 문자열을 얻는 함수
-- 콤마로 구분된 인자들을 \t 효과를 유사하게 구현했다.
local spaces={[0]='     ', '    ', '   ', '  ', ' '}
local function get_print(...)
	local args = {...}
	local str = ''
    local tab

	for k=1,#args do
		local arg = args[k]
		if k==1 then
			str = tostring(arg)
            tab = spaces[(#str)%5]
		else
			-- str = string.format('%s\t%s',str,tostring(arg))
            local strThis = tostring(arg)
			str = string.format('%s%s%s', str, tab, strThis)
			tab = spaces[(#strThis)%5]
		end
	end

	return str

end


local function puts(str)

    --(1) 최대 줄 수를 넘었다면 맨 첫 줄을 제거한다.
    if numlines >= maxlines then
        txtobjs[1]:remove()
        tRm(txtobjs, 1)
        numlines = numlines -1
    end

    --(1) 기존의 줄들을 모두 위로 올린다.
    for k=#txtobjs,1,-1 do

        local v = txtobjs[k]
        v:sety(v:gety()-lineHeight)

    end

    --(3) 새로운 줄을 추가한다.
    local txtobj = Text1(str):addto(cli) -- (0,0)에 자동으로 맞춰진다
    txtobj.__nocnt = true
    tIn(txtobjs, txtobj)
    numlines = numlines + 1


end


__print = print
-- local logf = setmetatable({},{__call=function(_, str,...)
function print(...)

    initcheck()
    local str = get_print(...)
    puts(str)
    __print(str)

end


function printf(str,...)

    initcheck()
    local str = strf(str,...)
    puts(str)
    __print(str)

end


--[[
logf.clear = function()

    for k=#txtobjs,1,-1 do local v = txtobjs[k]

        tRm(txtobjs,k)
        v:remove()

    end


end


logf.setnumlines = function(n)

    if n == INF then numlines = maxlines
    else numlines = n end

end
--]]

-- logf.__getNumObjs = function() return #txtobjs end


-- return logf