--##############################################################################
--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- bglayer에 등록
-- 2020/06/23 : Rect클래스를 리팩토링한 후 여기로 옮김
-- 2021/08/09 : screen:onkeydown(k) 메서드 처리 추가
--------------------------------------------------------------------------------
local luasp = _luasopia
local x0, y0, endx, endy = luasp.x0, luasp.y0, luasp.endx, luasp.endy
local int = math.floor

--2020/05/06 Rect(screen)가 safe영역 전체를 덮도록 수정
--2020/08/17 bglayer에 생성되어야 한다
screen = Rect(endx-x0+1, endy-y0+1, {fill=Color.BLACK})
screen.__nocnt = true
screen:addto(_luasopia.bglayer) -- 2021/08/17

screen:setxy(int(luasp.centerx), int(luasp.centery))

--2021/08/14
screen.width0 = luasp.width -- original (content) width
screen.height0 = luasp.height -- original (contetn) height

--2021/08/14:screen.width, screen.height는 pixelmode에서 변할 수 있다.
screen.width = screen.width0
screen.height = screen.height0



screen.centerx = int(luasp.centerx)
screen.centery = int(luasp.centery)
screen.fps = luasp.fps
-- added 2020/05/05
screen.devicewidth = luasp.devicewidth
screen.deviceheight = luasp.deviceheight
-- orientations: 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
screen.orientation = luasp.orientation 
-- added 2020/05/06
screen.x0, screen.y0, screen.endx, screen.endy = x0, y0, endx, endy
-------------------------------------------------------------------------------
--2021/06/05 added
--[[
screen.console = {

    clear = function() 

    end,


    function setlines(n)

    end,


    function hide()

    end,


    function show()

    end,
}
--]]

--------------------------------------------------------------------------------
--2021/08/09: (아래 코드는) 키보드 입력을 처리하기 위해서 작성
--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------

    local function mkkeytbl()

        local KeyCode = _Gideros.KeyCode
        local keyt = {
            [KeyCode.A]='a', [KeyCode.B]='b', [KeyCode.C]='c', [KeyCode.D]='d',
            [KeyCode.E]='e', [KeyCode.F]='f', [KeyCode.G]='g', [KeyCode.H]='h',
            [KeyCode.I]='i', [KeyCode.J]='j', [KeyCode.K]='k', [KeyCode.L]='l',
            [KeyCode.M]='m', [KeyCode.N]='n', [KeyCode.O]='o', [KeyCode.P]='p',
            [KeyCode.Q]='q', [KeyCode.R]='r', [KeyCode.S]='s', [KeyCode.T]='t',
            [KeyCode.U]='u', [KeyCode.V]='v', [KeyCode.W]='w', [KeyCode.X]='x',
            [KeyCode.Y]='y', [KeyCode.Z]='z',
            [KeyCode.NUM_1]='1', [KeyCode.NUM_2]='2', [KeyCode.NUM_3]='3',
            [KeyCode.NUM_4]='4', [KeyCode.NUM_5]='5', [KeyCode.NUM_6]='6',
            [KeyCode.NUM_7]='7', [KeyCode.NUM_8]='8', [KeyCode.NUM_9]='9',
            [KeyCode.NUM_0]='0', 
            --
            [KeyCode.F1]='f1', [KeyCode.F2]='f2', [KeyCode.F3]='f3',
            [KeyCode.F4]='f4', [KeyCode.F5]='f5', [KeyCode.F6]='f6',
            [KeyCode.F7]='f7', [KeyCode.F8]='f8', [KeyCode.F9]='f9',
            [KeyCode.F10]='f10', [KeyCode.F11]='f11', [KeyCode.F12]='f12',
            -- [KeyCode.BACK]='back',
            [KeyCode.BACKSPACE]='back',
            [KeyCode.TAB]='tab',
            [KeyCode.ENTER]='enter',
            [KeyCode.SPACE]='space',
            [KeyCode.ALT]='alt',
            [KeyCode.SHIFT]='shift',
            [KeyCode.CTRL]='ctrl',
            [KeyCode.UP]='up',[KeyCode.DOWN]='down',[KeyCode.LEFT]='left',
            [KeyCode.RIGHT]='right',
            [KeyCode.INSERT]='ins',[KeyCode.DELETE]='del',
            [404]='pageup', --[KeyCode.PAGEUP]='pageUp',
            [405]='pagedown', --[KeyCode.PAGEDOWN]='pageDown',
            [400]='home', --[KeyCode.HOME]='home' 
            [401]='end', --[KeyCode.PAGEDOWN]='end',
        }

        --keyCode가 0 이어서 realCode로 구분해야 할 키들
        local realt = {
            [45]='-',[61]='=',[91]='[',[93]=']',[59]=';',[39]="'",[92]='\\',
            [44]=',',[46]='.',[47]='/',[96]='`',
            [16777252]='capslock',
            [16777216]='esc',
            --2021/08/21:예를 들어 [shift]+[1]을 누르면 keyCode==0,
            -- realColde==36이 나온다.그래서 realCode로 키보드문자열을 만든다.
            [126]='`',[33]='1',[64]='2',[35]='3',[36]='4',[37]='5',[94]=6,
            [38]='7',[42]='8',[40]='9', [41]='0',[95]='-',[43]='=',
            [123]='[',[125]=']',[58]=';',[34]="'",[60]=',',[62]='.',[63]='/',
            [124]='\\'
        }
        return keyt, realt

    end


    -- key가 눌렸을 때에만 onkeydown()이 콜백되도록 함
    function luasp.enkeydown() -- enable key input
        
        local keyt, realt = mkkeytbl()

        local stage, Event = _Gideros.stage, _Gideros.Event
        stage:addEventListener(Event.KEY_DOWN, function(e)
            local k = keyt[e.keyCode] or (realt[e.realCode] or 'unknown')
            screen:onkeydown(k)
            -- puts('keyCode:%d,realCode:%d',e.keyCode, e.realCode)
        end)
        
        -- print('enkeydown()')
    end


    -- key가 눌렸을 때와 뗐을 때 모두 onkey()가 콜백되도록 함
    function luasp.enkeyboth()

        local stage, Event = _Gideros.stage, _Gideros.Event
        local keyt, realt = mkkeytbl()

        stage:addEventListener(Event.KEY_DOWN, function(e)
            local k = keyt[e.keyCode] or (realt[e.realCode] or 'unknown')
            screen:onkey(k,'down')
            -- puts('keyCode:%d,realCode:%d',e.keyCode, e.realCode)
        end)
        
        stage:addEventListener(Event.KEY_UP, function(e)
            local k = keyt[e.keyCode] or (realt[e.realCode] or 'unknown')
            screen:onkey(k,'up')
        end)

        -- print('enkeyboth()')
    end


--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    -- gideros와 문자열을 일치시키기 위한 변환테이블
    local function mkkeytbl()

        local keyt = {
            ['insert'] = 'ins',
            ['deleteForward'] = 'del',
            ['pageUp'] = 'pageup',
            ['pageDown'] = 'pagedown',
            ['deleteBack'] = 'back',
            ['leftShift'] = 'shift', ['rightShift'] = 'shift',
            ['leftControl'] = 'ctrl',
            ['capsLock'] = 'capslock',
            ['+'] = '=',
            ['escape'] = 'esc',
        }    

        return keyt
    end


    -- key가 눌렸을 때에만 onkeydown()이 콜백되도록 함
    local function onkeydown(e)

        local keyt = mkkeytbl()

        if e.phase=='down' then
            local k = keyt[e.keyName] or e.keyName
            screen:onkeydown(k)
        end
        
        return true
        
    end


    function luasp.enkeydown() -- enable key input

        Runtime:addEventListener('key', onkeydown)
        screen.__keydown = true

    end

    
    -- key가 눌렸을 때와 뗐을 때 모두 onkey()가 콜백되도록 함
    local function onkeyboth(e)

        local keyt = mkkeytbl()

        local k = keyt[e.keyName] or e.keyName
        screen:onkey(k, e.phase)
        return true
            
    end

    
    function luasp.enkeyboth() -- enable key input

        Runtime:addEventListener('key', onkeyboth)
        screen.__keyboth = true

    end

end
--------------------------------------------------------------------------------
-- end of respective local functions
--------------------------------------------------------------------------------

local function checkkey(self)

    -- print('ckd')

    if self.onkeydown then
        luasp.enkeydown()
        screen:__rmupd__(checkkey)
    end

    if self.onkey then
        luasp.enkeyboth()
        screen:__rmupd__(checkkey)
    end

end

screen:__addupd__(checkkey)