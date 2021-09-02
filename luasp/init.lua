--------------------------------------------------------------------------------
-- 2019/12/27: 작성 시작 : 해상도 1080x1920, 60프레임을 표준으로
-- 2020/02/16: init.lua를 luasp/init.lua로 옮김
-- 2021/05/13: main 폴더를 기본폴더로 구조를 변경(require 'luasp.init'를 없앰)
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
    -- gideros와 solar2d 공통적으로 _G에 남겨야 하는 것
    '_luasopia',
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

--------------------------------------------------------------------------------
if gideros then -- in the case of using Gideros
--------------------------------------------------------------------------------

    -- 2020/05/27 아래는 (screen Rect객체 때문에)궂이 필요없음
    --application:setBackgroundColor(0x000000)
    
    
    local contentwidth = application:getContentWidth()
    local contentheight = application:getContentHeight()
    local x0, y0, endx, endy = application:getDeviceSafeArea(true)
    local fps = application:getFps()
    
    
    _luasopia = {
        width = contentwidth,
        height = contentheight,
        
        centerx = contentwidth*0.5,
        centery = contentheight*0.5,
        
        devicewidth = application:getDeviceWidth(),
        deviceheight = application:getDeviceHeight(),
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
        orientation = application:getOrientation(),
        -- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endx,endy) 좌표값들을 구한다.
        x0 = x0,
        y0 = y0,
        endx = endx-1,
        endy = endy-1,
        
        fps = fps,
    }

    --2021/08/17:screen객체를 넣기 위한 레이어
    _luasopia.bglayer = {
        __bd = Sprite.new(),
        add = function(self, child) return self.__bd:addChild(child.__bd) end,
    }
    stage:addChild(_luasopia.bglayer.__bd)
    
    -- scene들을 놓기 위한 레이어
    -- pxmode로 진입할 때 scnlayer만 확대한다.
    _luasopia.scnlayer = {
        __bd = Sprite.new(),
        add = function(self, child) return self.__bd:addChild(child.__bd) end,
        --2021/08/17:setpixelmode()에서 사용할 setscale() 추가
        setscale = function(self, s) self.__bd:setScale(s) end

    }
    stage:addChild(_luasopia.scnlayer.__bd)

    
    _luasopia.loglayer = {
        __bd = Sprite.new(),
        add = function(self, child) return self.__bd:addChild(child.__bd) end,
        --2020/03/15 isobject(_loglayer, Group)==true 이려면 아래 두 개 필요
        --__clsid = Group.__id__,
        
        isvisible = function(self) return self.__bd:isVisible() end,
        hide = function(self) self.__bd:setVisible(false); return self end,
        show = function(self) self.__bd:setVisible(true); return self end,
    }
    _luasopia.loglayer:hide() -- 처음에는 숨겨놓는다.
    
    stage:addChild(_luasopia.loglayer.__bd)
    
    
    _Gideros = moveg()
    
--------------------------------------------------------------------------------
elseif coronabaselib then -- in the case of using solar2d
--------------------------------------------------------------------------------
    
    --2021/08/13:solar2d 의 디스플레이객체의 앵커포인트의 초기값을 (0,0)으로 설정
    -- pixel모드에서 정확한 점좌표를 획득하기 위해서이다
    --gideros는 default가 (0,0)이다
    display.setDefault('anchorX',0)
    display.setDefault('anchorY',0)
    -- 2021/08/13: 아래를 실행하면 (작은)이미지를 확대할 때 점이 뭉개지지 않는다
    -- 참조: https://docs.coronalabs.com/api/library/display/setDefault.html
    -- 만약 pixel모드라면 solar2d에서는 반드시 아래와 같이 먼저 실행해야 
    -- (점들로 이루어진) png파일이 왜곡없이 화면에 표시된다.
    -- (Gideros는 필요 없다)
    display.setDefault("magTextureFilter",'nearest') --default:'linear'

    local contentwidth = display.contentWidth
    local contentheight = display.contentHeight

	-- 디바이스에 실제로 표시되는 영역의 좌상점(x0,y0)과
    -- 우하점(endx,endy)의 좌표값들을 구한다.
	local x0, y0 = display.screenOriginX, display.screenOriginY
	local endx = display.actualContentWidth + x0 - 1
	local endy = display.actualContentHeight + y0 - 1


    _luasopia = {
        
        width = contentwidth,
        height = contentheight,
        
        centerx = contentwidth*0.5,
        centery = contentheight*0.5,
        
        devicewidth = display.pixelWidth,
        deviceheight = display.pixelHeight,
        
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'            
        orientation = system.orientation, -- system은 solar2d의 전역변수
        
        x0 = x0,
        y0 = y0,
        endx = endx,
        endy = endy,
        
        fps = display.fps,
    }


    -- 2021/08/17: screen객체를 놓기 위한 레이어
    _luasopia.bglayer = {
        __bd = display.newGroup(),
        add = function(self, child) return self.__bd:insert(child.__bd) end,
    }
    
    -- scene들을 놓기 위한 레이어
    -- pxmode로 진입할 때 scnlayer만 확대한다.
    _luasopia.scnlayer = {
        __bd = display.newGroup(),
        add = function(self, child) return self.__bd:insert(child.__bd) end,
        --2021/08/17:setpixelmode()에서 사용할 setscale() 추가
        setscale = function(self, s) self.__bd.xScale,self.__bd.yScale = s,s end
    }
        
        
    _luasopia.loglayer = {
        __bd = display.newGroup(),
        add = function(self, child) return self.__bd:insert(child.__bd) end,
        --2020/03/15 isobject(_loglayer, Group)가 true가 되려면 아래 두 개 필요
        --__clsid = Group.__id__
        isvisible = function(self) return self.__bd.isVisible end,
        hide = function(self) self.__bd.isVisible = false; return self end,
        show = function(self) self.__bd.isVisible = true; return self end
    }
    _luasopia.loglayer:hide()
        
    _Corona = moveg()


elseif love then-- in the case of using LOVE2d

end

-- 2020/06/23 먼저 아래와 같이 저장한 후 나중에 scene0.__stg__로 교체
-- 이렇게 해야 scene0나 screen 객체를 맨 처음 생성할 때 오류가 발생하지 않음
_luasopia.stage = _luasopia.scnlayer

--------------------------------------------------------------------------------
-- global constants -- 이 위치여야 한다.(위로 옮기면 안됨)
math.randomseed(os.time())
rand = math.random
INF = -math.huge -- infinity constant (일부러 -를 앞에 붙임)
_luasopia.debug = false
lib = {} -- 2020/03/07 added
ui = {} -- 2020/03/07 added

-- -- 2020/04/21 Disp.__getNumObjs 에서 빼야될  수
-- -- enterframe.lua에서 screen 객체(Rect)가 생성되기 때문에 초기값은 1
-- _luasopia.dcdobj = 1 

--------------------------------------------------------------------------------
-- 2021/05/12: luasp 프로젝트를 root폴더 안에서 작성하기로 변경함
_luasopia.root = 'root'
--------------------------------------------------------------------------------
--2021/08/27:added
_luasopia.dtmfrm = 1000/_luasopia.fps
print('dtmfrm:'.._luasopia.dtmfrm)
--------------------------------------------------------------------------------
-- load luasp core files

require 'luasp.core.a01_class'
require 'luasp.core.a02_timer'
require 'luasp.core.a03_util'
require 'luasp.core.a04_color'

require 'luasp.core.b01_disp'
require 'luasp.core.b02_disp_rm'
require 'luasp.core.b04_disp_touch'
require 'luasp.core.b05_disp_tap'

require 'luasp.core.c01_group'
require 'luasp.core.c02_image'
-- require 'luasp.core.c03_image_region' -- 한 그림에서 여러장을 뽑도록 개선해야 함
require 'luasp.core.c04_getsheet'
require 'luasp.core.c05_sprite'

require 'luasp.core.d01_text'
require 'luasp.core.d02_text1'

require 'luasp.core.e02_shape'
require 'luasp.core.e30_line' -- required refactoring

require 'luasp.core.f01_sound'

require 'luasp.core.h01_pxmode'      --2021/08/17
require 'luasp.core.h02_dot'       --2021/08/14
require 'luasp.core.h03_getpixels'   --2021/08/14
require 'luasp.core.h04_pixels'      --2021/08/14

-------------------------------------------------------------------------------
-- shapes

require 'luasp.shape.rect'
require 'luasp.shape.rectscreen' --2021/08/09:screen객체 생성 (Rect 뒤에 와야 함)
require 'luasp.shape.polygon'
require 'luasp.shape.circle'
require 'luasp.shape.star'
require 'luasp.shape.heart'
require 'luasp.shape.arrow'


-------------------------------------------------------------------------------
-- standard library

require 'luasp.lib.01_move'
require 'luasp.lib.02_shift'
require 'luasp.lib.03_puts'
require 'luasp.lib.04_blink' -- 2020/07/01, 2021/05/14 lib로 분리됨
require 'luasp.lib.05_wavescale' -- 2020/07/01, 2021/05/14 lib로 분리됨
require 'luasp.lib.06_ishit'

require 'luasp.lib.push'
require 'luasp.lib.path'
require 'luasp.lib.track' -- 2021/05/14 lib로 분리됨

require 'luasp.lib.tail' -- 2020/06/18 added
require 'luasp.lib.maketile' -- 2020/06/24 added

-------------------------------------------------------------------------------
-- widget

require 'luasp.widget.01_button'
require 'luasp.widget.02_progressbar'
require 'luasp.widget.03_alert'
require 'luasp.widget.04_entry'

-------------------------------------------------------------------------------

require 'luasp.core.g01_scene'-- scene0생성(이후 scene0.__stg__에 객체가 생성)
local enterframedbg = require 'luasp.core.z01_enterframe' -- 맨 마지막에 로딩해야 한다



--[[
-- 2021/05/13 전역 puts()함수 정의
-- puts()함수를 한 번도 호출하지 않는다면 loglayer가 hide()로 유지된다

function puts(str, ...)

    if not _luasopia.loglayer:isvisible() then

        _luasopia.loglayer:show()

    end

    if not _luasopia.logf then

        _luasopia.logf = _req 'luasp.lib.03_puts'

    end

    _luasopia.logf(str,...)
    
end
--]]


function setdebug(args)
    
    _luasopia.debug = true
    --if args.loglines then logf.setNumLines(args.loglines) end
    
    if not _luasopia.loglayer:isvisible() then
        _luasopia.loglayer:show()
    end

    -- 2020/05/30: added
    printf("(content)width:%d, height:%d", screen.width, screen.height)
    printf("(device)width:%d, height:%d", screen.devicewidth, screen.deviceheight)
    printf("orientation:'%s', fps:%d", screen.orientation, screen.fps)
    -- puts("endx:%d, endy:%d", screen.endx, screen.endy)
    
    enterframedbg()

    if args then 
        
        local linecolor = Color(100,100,100)

        if args.border then
            local border = args.border
            if type(border) ~= 'table' then border = {} end
            local color = border.color or linecolor
            local width = border.width or 3

            local br = Rect(screen.width0, screen.height0):empty()
            br:strokewidth(width):strokecolor(color)
            br.__nocnt = true
        
        end 

        -- 2020/04/21 그리드선 추가
        if args.grid then
            local grid = args.grid
            if type(grid) ~= 'table' then grid = {} end

            local xgap = grid.xgap or 100
            local ygap = grid.ygap or 100
            local color = grid.color or linecolor
            local width = grid.width or 2

            for x = xgap, screen.width0, xgap do
                local g = Line(x, 0, x, screen.height0, {width=width, color=color})
                g:addto(_luasopia.loglayer)
                g.__nocnt = true
            end

            for y = ygap, screen.height0, ygap do
                local g = Line(0, y, screen.width0, y, {width=width, color=color})
                g:addto(_luasopia.loglayer)
                g.__nocnt = true
            end

        end

    end

end

--------------------------------------------------------------------------------
-- 2021/05/13: require함수를 치환 (_req는 lua의 original require함수)
_require0 = require
local rooturl = _luasopia.root .. '.'
function require(url) return _require0(rooturl..url) end
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