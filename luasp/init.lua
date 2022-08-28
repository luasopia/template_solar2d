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
    
    -- Solar2d의 경우 아래 세 개는 전역변수로 남아있어야 정상동작한다.
    'system', 'Runtime', 'cloneArray',

    -- 2022/07/18: gideros는 2022.6버전부터 아래 전역변수가 남아있어야 한다
    -- '__styleUpdates', --아닌것같다

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
    local x0, y0, endX, endY = application:getDeviceSafeArea(true)
    local fps = application:getFps()
    
    
    _luasopia = {
        width = contentwidth,
        height = contentheight,
        
        centerX = contentwidth*0.5,
        centerY = contentheight*0.5,
        
        deviceWidth = application:getDeviceWidth(),
        deviceHeight = application:getDeviceHeight(),
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
        orientation = application:getOrientation(),
        -- 디바이스에서 실제 표시되는 영역의 (x0,y0), (endX,endY) 좌표값들을 구한다.
        x0 = x0,
        y0 = y0,
        endX = endX-1,
        endY = endY-1,
        
        fps = fps,
    }


    local Sprite, stage = Sprite, stage
    function _luasopia.newlayer(enableHide)

        local layer = {
            __bd = Sprite.new(),
            add = function(self, child)
                return self.__bd:addChild(child.__bd)
            end,
        }
        stage:addChild(layer.__bd)

        if enableHide then
            
            layer.isVisible = function(self) return self.__bd:isVisible() end
            layer.hide = function(self) self.__bd:setVisible(false); return self end
            layer.show = function(self) self.__bd:setVisible(true); return self end
        end
        
        return layer
    end


    --2021/08/17:screen객체를 넣기 위한 레이어
    _luasopia.bglayer = _luasopia.newlayer()

    -- scene들을 놓기 위한 레이어
    -- pxmode로 진입할 때 scnlayer만 확대한다.
    _luasopia.scnlayer = _luasopia.newlayer()
    _luasopia.scnlayer.setScale = function(self, s) self.__bd:setScale(s) end

    -- print(), printf()함수의 출력(standard output)이 표시되는 레이어
    _luasopia.stdoutlayer = _luasopia.newlayer(true)
    --_luasopia.stdoutlayer:hide()

    
    
    
    -- 2021/09/07: simulator가 실행되는 환경을 검색
    --[[ 2021/09/03: 'Windows' or 'Mac OS' means simulator
        Returns information about device.
        for iOS, returns 5 values: "iOS", iOS version, device type, user interface idiom and device model
        for Android, returns 4 values: "Android", Android version, manufacturer and model information
        for Windows returns 1 value: "Windows"
        for Mac OS X returns 1 value: "Mac OS"
        for Win32 returns 1 value: "Win32"
        for HTML5 returns 2 values: "Web", Browser ID string
    --]]
    local env = application:getDeviceInfo()
    if application:isPlayerMode() and env == 'Windows' then
        _luasopia.env = 'simulatorWin'
    elseif application:isPlayerMode() and env =='Mac OS' then
        _luasopia.env = 'simulatorMac'
    elseif env == 'Web' then
        _luasopia.env = 'web'
    else
        _luasopia.env = 'device'
    end
    
    
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
    -- 우하점(endX,endY)의 좌표값들을 구한다.
	local x0, y0 = display.screenOriginX, display.screenOriginY
	local endX = display.actualContentWidth + x0 - 1
	local endY = display.actualContentHeight + y0 - 1


    _luasopia = {
        
        width = contentwidth,
        height = contentheight,
        
        centerX = contentwidth*0.5,
        centerY = contentheight*0.5,
        
        deviceWidth = display.pixelWidth,
        deviceHeight = display.pixelHeight,
        
        -- 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'            
        orientation = system.orientation, -- system은 solar2d의 전역변수
        
        x0 = x0,
        y0 = y0,
        endX = endX,
        endY = endY,
        
        fps = display.fps,
    }


    --2021/09/07:새로운 레이어를 만드는 함수를 작성
    local display = display
    function _luasopia.newlayer(enableHide)

        local layer = {
            __bd = display.newGroup(),
            add = function(self, child) return self.__bd:insert(child.__bd) end,
        }
        if enableHide then
            layer.isVisible = function(self) return self.__bd.isVisible end
            layer.hide = function(self) self.__bd.isVisible = false; return self end
            layer.show = function(self) self.__bd.isVisible = true; return self end
        end
        return layer
    end


    -- 2021/08/17: screen객체를 놓기 위한 맨 밑바닥 레이어
    _luasopia.bglayer = _luasopia.newlayer()
    
    -- scene들을 놓기 위한 레이어
    _luasopia.scnlayer = _luasopia.newlayer()
    --2021/08/17:setpixelmode()에서 사용할 setScale() 추가
    -- pxmode로 진입할 때 scnlayer만 확대한다.
    _luasopia.scnlayer.setScale = function(self, s)
        self.__bd.xScale,self.__bd.yScale = s,s
    end
        
    -- print(), printf()함수의 출력(standard output)이 표시되는 레이어
    _luasopia.stdoutlayer = _luasopia.newlayer(true) 
    --_luasopia.stdoutlayer:hide() 
    
    --[[
    -- esc키를 눌렀을 때 표시되는 레이어
    _luasopia.esclayer = _luasopia.newlayer(true)
    _luasopia.esclayer:hide()
    --]]
        
    _Corona = moveg()

    -- 2021/09/07: simulator가 실행되는 환경을 검색
    -- system.getInfo('environment') returns the environment that the app is running in.
    -- 'simulator' for the Solar2D Simulator.
    -- 'device' for iOS, the Xcode iOS Simulator, Android devices, the Android emulator, macOS desktop apps, and Windows desktop apps.
    -- 'browser' for HTML5 apps.
    local env = system.getInfo('environment')

    --[[
    -- system.getInfo('platform') returns the OS platform tag, which can be one of:
    -- 'android' — all Android devices and the Android emulator.
    -- 'ios' — all iOS devices and the Xcode iOS Simulator.
    -- 'macos' — macOS desktop apps.
    -- 'tvos' — Apple's tvOS (Apple TV).
    -- 'win32' — Win32 desktop apps.
    -- 'html5' — HTML5 apps.
    -- 시뮬레이터 스킨에 따라서 위값들이 정해진다.
    local platf = system.getInfo('platform')
    print(env, platf)
    --]]

    local archi = system.getInfo('architectureInfo')
    -- print(env, platf, archi)

    if env == 'simulator' then
        if archi=='x86' or archi=='x64' or archi=='IA64' or archi=='ARM' then
            _luasopia.env = 'simulatorWin'
        elseif archi=='i386' or archi=='x86_64' or archi=='ppc' or archi=='ppc64' then
            _luasopia.env = 'simulatorMac'
        end
    elseif env == 'browser' then
        _luasopia.env = 'web'
    else
        _luasopia.env = 'device'
    end

    print('env:',_luasopia.env)

elseif love then-- in the case of using LOVE2d

end
--------------------------------------------------------------------------------
local luasp = _luasopia


-- 2020/06/23 먼저 아래와 같이 저장한 후 나중에 scene0.__stg__로 교체
-- 이렇게 해야 scene0나 screen 객체를 맨 처음 생성할 때 오류가 발생하지 않음
luasp.stage = luasp.scnlayer

--------------------------------------------------------------------------------
-- global constants -- 이 위치여야 한다.(위로 옮기면 안됨)
--INF = -math.huge -- infinity constant (일부러 -를 앞에 붙임)
INF = math.huge -- infinity constant -- 2022/08/27 (-)를 뺐다.
--------------------------------------------------------------------------------
-- 2021/05/12: luasp 프로젝트를 root폴더 안에서 작성하기로 변경함
luasp.root = 'root'
--------------------------------------------------------------------------------
--2021/08/27:added
luasp.dtmfrm = 1000/luasp.fps
-- print('dtmfrm:'.._luasopia.dtmfrm)
--------------------------------------------------------------------------------

-- load luasp core files

require 'luasp.core.a01_class'
require 'luasp.core.a02_timer'
require 'luasp.core.a03_util'
require 'luasp.core.a04_color'

------------------------------------------------------------
-- 2021/09/08: 환경변수들을 따로 config.lua파일에서 관리
require (luasp.root..'.config')
------------------------------------------------------------

require 'luasp.core.b01_disp'
require 'luasp.core.b02_disp_rm'
require 'luasp.core.b04_disp_touch'
require 'luasp.core.b05_disp_tap'

require 'luasp.core.c01_group'
require 'luasp.core.c02_image'
-- require 'luasp.core.c03_image_region' -- 한 그림에서 여러장을 뽑도록 개선해야 함
-- require 'luasp.core.c04_getsheet'
require 'luasp.core.c04_image_sheet'
require 'luasp.core.c05_sprite'

require 'luasp.core.d01_text'
require 'luasp.core.d02_text1'

require 'luasp.core.e02_shape'
require 'luasp.core.e30_line' -- required refactoring
require 'luasp.core.e31_line1' -- (내부용) 단순선

require 'luasp.core.f01_sound'


--[[
-- 2022/08/23: pxmode는 일단 보류
require 'luasp.core.wip.h01_pxmode'      --2021/08/17
require 'luasp.core.wip.h02_dot'       --2021/08/14
require 'luasp.core.wip.h03_palette'   --2021/08/14
require 'luasp.core.wip.h04_getpixels'   --2021/08/14
require 'luasp.core.wip.h05_pixels'      --2021/08/14
--]]

-------------------------------------------------------------------------------
-- shapes

require 'luasp.shape.rect'
require 'luasp.shape.rectscreen' --2021/08/09:screen객체 생성 (Rect 뒤에 와야 함)
require 'luasp.shape.roundrect' --2021/10/10
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
require 'luasp.lib.05_wave' -- 2022/08/27
require 'luasp.lib.06_ishit'
require 'luasp.lib.07_hover' -- 2022/08/23

-- require 'luasp.lib.wip.push'
-- require 'luasp.lib.wip.path'
-- require 'luasp.lib.wip.track' -- 2021/05/14 lib로 분리됨
-- require 'luasp.lib.wip.tail' -- 2020/06/18 added
-- require 'luasp.lib.wip.maketile' -- 2020/06/24 added

-------------------------------------------------------------------------------
-- widget

require 'luasp.widget.01_button'
require 'luasp.widget.02_progressbar'
require 'luasp.widget.03_alert'
require 'luasp.widget.04_entry'
require 'luasp.widget.05_labelbox'

-------------------------------------------------------------------------------

require 'luasp.core.g01_scene'-- scene0생성(이후 scene0.__stg__에 객체가 생성)
require 'luasp.core.z01_enterframe' -- 맨 마지막에 로딩해야 한다

-------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 2021/05/13: require함수를 치환 (_req는 lua의 original require함수)
_require0 = require
-- local rooturl = _luasopia.root .. '.'
function require(url) return _require0(luasp.root ..'.'.. url) end
--------------------------------------------------------------------------------


if luasp.env =='simulatorWin' or luasp.env =='simulatorMac' then
    
    if _Gideros then
    
        -- 나중에 api함수로 교체해야함
        luasp.resourceDir='E:/coding/__luasopia/_template_gideros/assets/'

    elseif _Corona then

        local fullpath = system.pathForFile('main.lua', system.ResourceDirectory)
        fullpath = string.gsub(fullpath, '[\\]', '/')
        fullpath = string.gsub(fullpath, 'main.lua', '')
        luasp.resourceDir = fullpath

    end

    _luasopia.esclayer = _luasopia.newlayer(true)
    _luasopia.esclayer:hide() -- 처음에는 숨겨놓는다.

    _luasopia.clilayer = _luasopia.newlayer(true)
    _luasopia.clilayer:hide() -- 처음에는 숨겨놓는다.

    print('resourceDir="'..luasp.resourceDir..'"')
    
    
    luasp.allowEsc()
    luasp.allowCli()

end


--------------------------------------------------------------------------------

-- 2020/04/12: 사용자가 _G에 변수를 생성하는 것을 막는다
-- 대신 모든 사용자 전역변수는 global테이블에 만들어야 한다.
-- 2021/09/11: banGlobal()함수를 만들었다.
global = {} 
local gmetatable = getmetatable(_G)

function luasp.banGlobal()

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

end

function luasp.allowGlobal()
    setmetatable(_G, gmetatable)
end

luasp.banGlobal()