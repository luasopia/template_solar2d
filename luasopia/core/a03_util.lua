--------------------------------------------------------------------------------
-- utility functions for debug
--------------------------------------------------------------------------------


--[[
-- this loads main.lua in 'luasopialib' folder
function importlib(libname)
    local url = string.format('luasopiaLib.%s.%s',libname, libname)
    global.u = function(str) return string.format('luasopiaLib/%s/%s',libname,str) end
    local lib = require(url)
    global.u = nil
    return lib
end
--]]

--[[
function runutil(utilname) -- runutil
    local url = string.format('luasopiaUtil.%s.main',utilname, utilname)
    global.u = function(str) return string.format('luasopiaUtil/%s/%s', utilname, str) end
    local util = require(url)
    global.u = nil
    return util
end
--]]

function _luasopia.copytable(t)
    local clone = {}
    for k, v in next, t do  clone[k] = v end
    return clone
end

_luasopia.puts = function(...) print(string.format(...)) end

_luasopia.showt = function(node)
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
_luasopia.showg = function()


    ----[[ print global variables that are added by user
    local luag = { -- 39
    '_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'dofile',
    'error', 'gcinfo', 'getfenv', 'getmetatable', 'io', 'ipairs', 'load', 'loadfile',
    'loadstring', 'math', 'module', 'newproxy', 'next', 'os', 'package', 'pairs',
    'pcall', 'print', 'rawequal', 'rawget', 'rawset', 'require', 'select', 'setfenv',
    'setmetatable', 'string', 'table', 'tostring', 'tonumber', 'type', 'unpack', 'xpcall',
    -- extra keys --
    '_Gideros',
    -- CoronaSDK는 아래 세 개는 전역변수로 있어야 정상동작한다.
    'system', 'Runtime', 'cloneArray',
    }
    local function notin(str)
        for _, v in ipairs(luag) do
            if v==str then return false end
        end
        return true
    end

    print('----------')
    for k,v in pairs(_G) do if notin(k) then print(k) end end
    print('----------')
    --]]
end

-- 2021/05/13 : file url로부터 현재폴더(문자열)을 구하는 함수
-- 파일의 첫 줄에 local here = gethere(...) 라고 호출하면
-- 현재폴더의 url을 구할 수 있다.(ex: 'root.lib.mod' -> 'lib/')
local gmatch = string.gmatch
function getdir(url)
    local k, here, folder_1 = 1, ''
    for folder in gmatch(url, "[^%.]+") do -- dot('.')을 기준으로 분리
        if k>2 then here = here .. folder_1 ..'/'  end
        k = k+1
        folder_1 = folder
    end
    --return here
    return function(url) return here..url end
end

--2021/05/14 : library를 쉽게 불러오는 import()함수. 가정들:
-- (1) library는 main/lib 폴더에 개별 폴더로 존재한다.
-- (2) library폴더와 그 안의 lua파일의 이름이 같다.
-- 예를 드렁 main/lib/blink/blink.lua 파일이 있다고 가정하면
-- import 'blink' 라고 하면 된다
local liburl = _luasopia.root .. '.lib.'
function import(libname)
    return _req(liburl..libname..'.'..libname)
end

----[[
-- 2021/08/09 table(t)이 empty일 경우 true를 반환
local _nxt = next
function isempty(t)
    if _nxt(t) == nil then
        return true
    end
    return false
end
--]]

--2021/08/13: pixel모드(저해상도)를 실시간으로 구현하고자 하는 아이디어
--2021/08/14: pixelmode를 추가
--저해상도에서 pixel(이미지내의 점)의 위치가 정확하게 잡히려면 지정된 xy좌표가
--정수가 되어야 한다. 실수가 되면 정확한 위치에 점이 놓이지 않는다.
local int = math.floor
function setpixelmode(scale)
    
    scale = scale or 8

    if _Corona then

        _luasopia.baselayer.__bd:scale(scale,scale)


    elseif _Gideros then

        -- clipping 된 영역도 흑색으로 채우려면 아래함수에0을 주면 된다.
        _Gideros.application:setBackgroundColor(0x303030)

        _luasopia.baselayer.__bd:setScale(scale,scale)

        -- 궂이 clipping할 필요가 있을까 싶은데 실행속도에 영향이 있으려나
        -- _luasopia.baselayer.__bd:setClip(0,0,50,50)
        

    end

    screen.width = int(screen.width0/scale)
    screen.height = int(screen.height0/scale)

    screen.centerx = int(screen.width*0.5)
    screen.centery = int(screen.height*0.5)

    -- 아래는 Display.init() 안에서 사용된다
    _luasopia.centerx = screen.centerx
    _luasopia.centery = screen.centery

end
