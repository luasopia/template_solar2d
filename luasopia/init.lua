--------------------------------------------------------------------------------
-- 2019/12/27: 작성 시작 : 60프레임, 화면 1080x1920 기준으로
-- 2020/02/16: init.lua를 luasopia/init.lua로 옮김
-- 2021/05/13: main 폴더를 기본폴더로 구조를 변경(require 'luasopia.init'를 없앰)
--------------------------------------------------------------------------------
-- Lua 고유의 전역변수들만 남기고 특정SDK의 전역변수들을 tbl로 이동
--------------------------------------------------------------------------------
local function moveg()
    local tbl = {}

    local luag = { -- 39 -- lua global variables
    '_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'dofile',
    'error', 'gcinfo', 'getfenv', 'getmetatable', 'io', 'ipairs', 'load', 'loadfile',
    'loadstring', 'math', 'module', 'newproxy', 'next', 'os', 'package', 'pairs',
    'pcall', 'print', 'rawequal', 'rawget', 'rawset', 'require', 'select', 'setfenv',
    'setmetatable', 'string', 'table', 'tostring', 'tonumber', 'type', 'unpack', 'xpcall',
    -- CoronaSDK의 경우 아래 세 개는 전역변수로 남아있어야 정상동작한다.
    'system', 'Runtime', 'cloneArray',
    }
    
    local function notin(str)
        for _, v in ipairs(luag) do
            if v==str then return false end
        end
        return true
    end

    for k, v in pairs(_G) do
        if notin(k) then
            tbl[k] = v
            _G[k] = nil
        end
    end

    return tbl
end


if gideros then -- in the case of using Gideros

    -- 2020/05/27 아래는 (screen Rect객체 때문에)궂이 필요없음
    --application:setBackgroundColor(0x000000)
    
    _Gideros = moveg()

    local contentwidth = _Gideros.application:getContentWidth()
    local contentheight = _Gideros.application:getContentHeight()
    local x0, y0, endx, endy = _Gideros.application:getDeviceSafeArea(true)
    local fps = _Gideros.application:getFps()

    _luasopia = {
        width = contentwidth,
        height = contentheight,

        centerx = contentwidth/2,
        centery = contentheight/2,

        devicewidth = _Gideros.application:getDeviceWidth(),
        deviceheight = _Gideros.application:getDeviceHeight(),
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
        orientation = _Gideros.application:getOrientation(),
        -- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endx,endy) 좌표값들을 구한다.
        x0 = x0,
        y0 = y0,
        endx = endx-1,
        endy = endy-1,

        fps = fps,
    }

    _luasopia.baselayer = {
        __bd = _Gideros.Sprite.new(),
        add = function(self, child) return self.__bd:addChild(child.__bd) end,
    }
    -- _Gideros.stage:addChild(screen.__bd)
    _Gideros.stage:addChild(_luasopia.baselayer.__bd)

    _luasopia.loglayer = {
        __bd = _Gideros.Sprite.new(),
        add = function(self, child) return self.__bd:addChild(child.__bd) end,
        --2020/03/15 isobj(_loglayer, Group)==true 이려면 아래 두 개 필요
        --__clsid = Group.__id__,

        isvisible = function(self) return self.__bd:isVisible() end,
        hide = function(self) self.__bd:setVisible(false); return self end,
        show = function(self) self.__bd:setVisible(true); return self end,
    }
    _luasopia.loglayer:hide() -- 처음에는 숨겨놓는다.
    _Gideros.stage:addChild(_luasopia.loglayer.__bd)




elseif coronabaselib then -- in the case of using CoronaSDK

    _Corona = moveg()

    local contentwidth = _Corona.display.contentWidth
    local contentheight = _Corona.display.contentHeight

	-- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endx,endy) 좌표값들을 구한다.
	local x0, y0 = _Corona.display.screenOriginX, _Corona.display.screenOriginY
	local endx = _Corona.display.actualContentWidth + x0 - 1
	local endy = _Corona.display.actualContentHeight + y0 - 1
    local fps = _Corona.display.fps

	_luasopia = {

        width = contentwidth,
        height = contentheight,

        centerx = contentwidth/2,
        centery = contentheight/2,

        devicewidth = _Corona.display.pixelWidth,
        deviceheight = _Corona.display.pixelHeight,
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'            
        orientation = system.orientation, 

        x0 = x0,
        y0 = y0,
        endx = endx,
        endy = endy,

        fps = fps,
    }

    -- screen = {
    _luasopia.baselayer = {
        __bd = _Corona.display.newGroup(),
        add = function(self, child) return self.__bd:insert(child.__bd) end,
    }

    _luasopia.loglayer = {
        __bd = _Corona.display.newGroup(),
        add = function(self, child) return self.__bd:insert(child.__bd) end,
        --2020/03/15 isobj(_loglayer, Group)가 true가 되려면 아래 두 개 필요
        --__clsid = Group.__id__
        isvisible = function(self) return self.__bd.isVisible end,
        hide = function(self) self.__bd.isVisible = false; return self end,
        show = function(self) self.__bd.isVisible = true; return self end
    }
    _luasopia.loglayer:hide()

elseif love then-- in the case of using LOVE2d

end

-- 2020/06/23 먼저 아래와 같이 저장한 후 나중에 scene0.__stg__로 교체
-- 이렇게 해야 scene0나 screen 객체를 맨 처음 생성할 때 오류가 발생하지 않음
_luasopia.stage = _luasopia.baselayer

--------------------------------------------------------------------------------
-- global constants -- 이 위치여야 한다.(위로 옮기면 안됨)
math.randomseed(os.time())
rand = math.random
INF = -math.huge -- infinity constant (일부러 -를 앞에 붙임)
_luasopia.debug = false
lib = {} -- 2020/03/07 added
ui = {} -- 2020/03/07 added
-- 2020/04/21 Disp.__getNumObjs 에서 빼야될  수
-- enterframe.lua에서 screen 객체(Rect)가 생성되기 때문에 초기값은 1
_luasopia.dcdobj = 1 

--------------------------------------------------------------------------------
-- 2021/05/12: luasopia 프로젝트를 root폴더 안에서 작성하기로 변경함
_luasopia.root = 'root'
--------------------------------------------------------------------------------
-- load luasopia core files

require 'luasopia.core.a01_class'
require 'luasopia.core.a02_timer'
require 'luasopia.core.a03_util'
require 'luasopia.core.a04_color'

require 'luasopia.core.b01_disp'
require 'luasopia.core.b04_disp_touch'
require 'luasopia.core.b05_disp_tap'

require 'luasopia.core.c01_group'
require 'luasopia.core.c02_image'
require 'luasopia.core.c03_image_region'
require 'luasopia.core.c04_getsheet'
require 'luasopia.core.c05_sprite'

require 'luasopia.core.d01_text'
require 'luasopia.core.e01_getshape'
require 'luasopia.core.e02_shape'
require 'luasopia.core.e30_line' -- required refactoring

require 'luasopia.core.f01_sound'

-------------------------------------------------------------------------------
-- shapes

require 'luasopia.shape.rect' -- screen 객체 생성
require 'luasopia.shape.polygon'
require 'luasopia.shape.circle'
require 'luasopia.shape.star'
require 'luasopia.shape.heart'
require 'luasopia.shape.square'

-------------------------------------------------------------------------------
-- standard library

require 'luasopia.lib.01_move'
require 'luasopia.lib.02_shift'

require 'luasopia.lib.04_blink' -- 2020/07/01, 2021/05/14 lib로 분리됨
require 'luasopia.lib.05_wavescale' -- 2020/07/01, 2021/05/14 lib로 분리됨
require 'luasopia.lib.06_ishit'
require 'luasopia.lib.path'
require 'luasopia.lib.track' -- 2021/05/14 lib로 분리됨

require 'luasopia.lib.tail' -- 2020/06/18 added
require 'luasopia.lib.maketile' -- 2020/06/24 added

-------------------------------------------------------------------------------
-- widget

require 'luasopia.widget.button'
require 'luasopia.widget.progressbar'

-------------------------------------------------------------------------------

require 'luasopia.core.g01_scene'-- scene0생성(이후 scene0.__stg__에 객체가 생성)
local enterframedbg = require 'luasopia.core.z01_enterframe' -- 맨 마지막에 로딩해야 한다



-- 2021/05/13 전역 printf()함수 정의
-- printf()함수를 한 번도 호출하지 않는다면 _luasopia.loglayer가 생성되지 않는다.

function printf(str, ...)

    if not _luasopia.loglayer:isvisible() then
        _luasopia.loglayer:show()
    end

    if not _luasopia.logf then
        _luasopia.logf = _req 'luasopia.lib.03_logf'
    end

    _luasopia.logf(str,...)
end



function setdebug(args)
    
    _luasopia.debug = true
    --if args.loglines then logf.setNumLines(args.loglines) end
    
    if not _luasopia.loglayer:isvisible() then
        _luasopia.loglayer:show()
    end

    -- 2020/05/30: added
    printf("(content)width:%d, height:%d", _luasopia.width, _luasopia.height)
    printf("(device)width:%d, height:%d", _luasopia.devicewidth, _luasopia.deviceheight)
    printf("orientation:'%s', fps:%d", _luasopia.orientation, _luasopia.fps)
    -- printf("endx:%d, endy:%d", screen.endx, screen.endy)
    
    enterframedbg()

    if args then 
        
        local linecolor = Color(100,100,100)

        if args.border then
            local border = args.border
            if type(border) ~= 'table' then border = {} end
            local color = border.color or linecolor
            local width = border.width or 3

            local br = Rect(screen.width, screen.height):empty()
            br:strokewidth(width):strokecolor(color)
            _luasopia.dcdobj = _luasopia.dcdobj + 1
        
        end 

        -- 2020/04/21 그리드선 추가
        if args.grid then
            local grid = args.grid
            if type(grid) ~= 'table' then grid = {} end

            local xgap = grid.xgap or 100
            local ygap = grid.ygap or 100
            local color = grid.color or linecolor
            local width = grid.width or 2

            for x = xgap, screen.width, xgap do
                Line(x, 0, x, screen.height, {width=width, color=color}):addto(_luasopia.loglayer)
                _luasopia.dcdobj = _luasopia.dcdobj + 1
            end

            for y = ygap, screen.height, ygap do
                Line(0, y, screen.width, y, {width=width, color=color}):addto(_luasopia.loglayer)
                _luasopia.dcdobj = _luasopia.dcdobj + 1
            end

        end

    end

end

--------------------------------------------------------------------------------
-- 2021/05/13: require함수를 치환 (__req__는 lua의 original require함수)
_req = require
local rooturl = _luasopia.root .. '.'
function require(url) return _req(rooturl..url) end
--------------------------------------------------------------------------------

-- 2020/04/12: 사용자가 _G에 변수를 생성하는 것을 막는다
-- 모든 사용자 전역변수는 global테이블에 만들어야 한다.
global = {} 
setmetatable(_G, {
    __newindex = function(_,n)
        error('ERROR: attempt to create GLOBAL variable/function '..n, 2)
    end,
--[[ -- 읽는 것까지 예외를 발생시킨다.
    __index = function(_,n)
        error('attempt to read undeclared variable '..n, 2)
    end
--]]
})

return init