--------------------------------------------------------------------------------
--2021/08/31: Group객체 안에 Text1객체들을 넣는 것을 리팩토링함
--2021/09/08: luasp.stdoutlayer를 추가해서 여기에 출력결과를 표시
--------------------------------------------------------------------------------
local linespace = 1.15 -- 줄간격을 0.3으로 설정(너무 붙으면 가독성이 떨어짐)
local botmargin = 20 -- gap from bottom and last line
local leftmargin = 10 
local color0 = Color.LIGHT_GREEN --DARK_GRAY
--------------------------------------------------------------------------------
local luasp = _luasopia
local esclayer = luasp.esclayer

local tIn, tRm = table.insert, table.remove
local int = math.floor
local strf = string.format
local nilfunc = luasp.nilfunc
local stdoutlayer = luasp.stdoutlayer
--------------------------------------------------------------------------------
local cli = Group():addto(esclayer)
cli:setxy(leftmargin, screen.height0-botmargin)
cli.__nocnt = true -- debugmode에서 display obj의 개수로 카운트하지 않는다
local lineHeight =  Text1.getfontsize0()*linespace
local maxlines = int(screen.height0/lineHeight)-3 -- -1
local txtobjs = {}
local numlines = 0

-- print()함수의 출력과 유사한 문자열을 얻는 함수
-- 콤마로 구분된 인자들을 \t 효과를 유사하게 구현했다.
-- 2021/09/07:(발견!) arg 는 함수 내에서 이미 {...}로 정의되어 있고
-- arg.n에는 실제로 넘어온 인수의 개수가 이미 저장되어 있다.
-- 따라서 print(nil)은 arg.n==1이고 print()은 arg.n==0이어서 구분할 수 있음
local spaces={[0]='     ', '    ', '   ', '  ', ' '}

local function get_print(...)
	local str = ''
    local tab
    -- _print0('#args:',#args)
    
	for k=1,arg.n do

        local v = arg[k]
        
		if k==1 then

			str = tostring(v)
            tab = spaces[(#str)%5]

		else

			-- str = string.format('%s\t%s',str,tostring(arg))
            local strThis = tostring(v)
			str = strf('%s%s%s', str, tab, strThis)
			tab = spaces[(#strThis)%5]

		end

	end

	return str

end


--2021/09/02: make new line
local function newline()

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

end


local function puts(str, no_new_line)

    if not no_new_line then
        newline()
    end

    --(3) 새로운 줄을 추가한다.
    local txtobj = Text1(str,{color=color0}):addto(cli) -- (0,0)에 자동으로 맞춰진다
    txtobj.__nocnt = true
    tIn(txtobjs, txtobj)
    numlines = numlines + 1

end

local function print(...)
    
    local str = get_print(...)
    puts(str)
    _print0(str)
    
    return cli
    
end

--[[

function printf(...)

    initcheck()
    local str = strf(...)
    puts(str)
    _print0(str)

    return cli

end
--]]

local function onend_input(entry)

    local str_in = entry:getstring()
    local str_hdr = entry.__hdr
    entry:remove()
    puts(str_hdr .. str_in, true)
    cli.__endin(str_in)

end


function input(header, onenter)

    newline()
    cli.__endin = onenter or nilfunc
    local entry = Entry(header, onend_input):addto(cli)

end


--------------------------------------------------------------------------------
-- 2021/09/02:cli added
--------------------------------------------------------------------------------
local env = setmetatable({},{__index=_G})

-- 첫번째 인수가 entry이다.
local function execstr(entry)

    local str_in = entry:getstring()
    local str_hdr = entry.__hdr
    entry:remove()
    puts(str_hdr .. str_in, true)

    local f = loadstring(str_in)
    if f==nil then
        puts('syntax error!')
    else
        setfenv(f, env)()
    end

    -- cli.newcommand()

end


function cli.newcommand()

    newline()
    cli.entry = Entry('> ', execstr, {fontcolor=color0}):addto(cli)

end


cli.newcommand()

function cli.print(...)

    if cli.entry and not cli.entry:isremoved() then
        cli.entry:remove()
    end

    local str = get_print(...)
    puts(str)
    _print0(str)

    cli.newcommand()

end


luasp.cli = cli