--------------------------------------------------------------------------------
-- utility functions for debug
--------------------------------------------------------------------------------
local luasp=_luasopia
luasp.util = {}
local util = luasp.util


--[[
function runutil(utilname) -- runutil
    local url = string.format('luasopiaUtil.%s.main',utilname, utilname)
    global.u = function(str) return string.format('luasopiaUtil/%s/%s', utilname, str) end
    local util = require(url)
    global.u = nil
    return util
end
--]]

function util.copytable(t)
    local clone = {}
    for k, v in next, t do  clone[k] = v end
    return clone
end

-- _luasopia.putsf = function(...) print(string.format(...)) end

function util.showt(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function util.showg()


    ----[[ print global variables that are added by user
    local luag = { -- 39
    '_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'dofile',
    'error', 'gcinfo', 'getfenv', 'getmetatable', 'io', 'ipairs', 'load', 'loadfile',
    'loadstring', 'math', 'module', 'newproxy', 'next', 'os', 'package', 'pairs',
    'pcall', 'print', 'rawequal', 'rawget', 'rawset', 'require', 'select', 'setfenv',
    'setmetatable', 'string', 'table', 'tostring', 'tonumber', 'type', 'unpack', 'xpcall',
    -- extra keys --
    '_Gideros', '_Corona',
    -- CoronaSDK는 아래 세 개는 전역변수로 있어야 정상동작한다.
    'system', 'Runtime', 'cloneArray',
    }
    local function notin(str)
        for _, v in ipairs(luag) do
            if v==str then return false end
        end
        return true
    end

    io.write('----------\n')
    for k,v in pairs(_G) do
        if notin(k) then
            io.write(k..', ')
        end
    end
    io.write('\n----------')
    --]]
end

----[[
-- 2021/08/09 table(t)이 empty일 경우 true를 반환
local _nxt = next
function util.isempty(t)

    if _nxt(t) == nil then return true end
    return false
end
--]]

--------------------------------------------------------------------------------
-- global functions
--------------------------------------------------------------------------------

-- 2021/05/13 : file url로부터 현재폴더(문자열)을 구하는 함수
-- 파일의 첫 줄에 local here = gethere(...) 라고 호출하면
-- 현재폴더의 url을 구할 수 있다.(ex: 'root.lib.mod' -> 'lib/')
local gmatch = string.gmatch
function getDir(url)
    local k, here, folder_1 = 1, ''
    for folder in gmatch(url, "[^%.]+") do -- dot('.')을 기준으로 분리
        if k>2 then here = here .. folder_1 ..'/'  end
        k = k+1
        folder_1 = folder
    end
    -- 아래와 같이 함수를 반환하여 u'image.png' 같이 문자열의 접두어처럼 사용 가능
    return function(url) return here..url end
end

--2021/05/14 : library를 쉽게 불러오는 import()함수. 가정들:
-- (1) library는 root/lib 폴더에 개별 폴더로 존재한다.
-- (2) lib폴더와 그 안의 lua파일의 이름이 같다.
-- 예를 들어 root/lib/blink/blink.lua 파일이 있다고 가정하면
-- import 'blink' 라고 하면 된다
local liburl = _luasopia.root .. '.lib.'
local require0 = luasp.require0
function import(libname)
    return require0(liburl..libname..'.'..libname)
end


--2021/10/02: refactoring rand so that rand(a,b, c,d) is possible
math.randomseed(os.time())
local rnd = math.random
-- 함수 내에서 arg와 ...가 혼용되면 뭔가 안되는 것 같다.
-- 용례: rand(), rand(n1), rand(n1,n2), rand(n1,n2,m1,m2) 
function rand(...)

    local args = {...}

    if args[3]==nil then
        return rnd(...)
    elseif rnd(2)==1 then
        return rnd(args[1],args[2])
    else
        return rnd(args[3],args[4])
    end

end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 2021/09/19에 작성. 아래 함수들은 scene에서 사용된다.
local tcover
function luasp.bantouch()

    --print('bantouch')

    tcover = Rect(screen.width,screen.height,{fill=Color(0,0,0,0.1)})
    tcover:setAlpha(0.1):addTo(luasp.stdoutlayer)

    -- solar2d는 alpha가 0이면 기본적으로 touch 이벤트가 불능이 된다.
    -- alpha가 0임에도 터치이벤트가 발생토록 하려면 아래와 같이 한다.
    -- cover.__bd(==Group)가 아니라 cover.__shp에 적용해야 한다
    -- if _Corona then tcover.__shp.isHitTestable = true end
    -- 위는 solar2d에서만 필요하고, gideros는 alpha==0이어도 터치이벤트가 발생한다.

    -- 2021/09/19:solar2d에서 alpha를 0.1로 설정하면 터치이벤트가 발생한다.
    -- shp의 fill도 0.1, rect의 alpha도 0.1로 해서 거의 투명해보인다.
    tcover.onTouch = luasp.nilfunc

end


function luasp.allowtouch()

    if tcover and not tcover:isRemoved() then
        --print('rmcover ')
        tcover:remove()
    end

end