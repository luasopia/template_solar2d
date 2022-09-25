--##############################################################################
--------------------------------------------------------------------------------
-- 2020/02/23 : screen 에 touch()를 직접붙이기 위해서 Rect를 screen으로 생성해서
-- bglayer에 등록
-- 2020/06/23 : Rect클래스를 리팩토링한 후 여기로 옮김
-- 2021/08/09 : screen:onKey(k) 메서드 처리 추가
--------------------------------------------------------------------------------
local luasp = _luasopia

local x0, y0, endX, endY = luasp.x0, luasp.y0, luasp.endX, luasp.endY
local int = math.floor
local cx, cy = int(luasp.centerX), int(luasp.centerY)
local nilfunc = luasp.nilfunc

--2020/05/06 Rect(screen)가 safe영역 전체를 덮도록 수정
--2020/08/17 bglayer에 생성되어야 한다
screen = Rect(endX-x0+1, endY-y0+1, {fill = luasp.config.backgroundColor})
screen:addTo(luasp.bglayer):setXY(cx, cy)

--2021/08/14
screen.width0 = luasp.width -- original (content) width
screen.height0 = luasp.height -- original (contetn) height

--2021/08/14:screen.width, screen.height는 pixelmode에서 변할 수 있다.
screen.width = screen.width0
screen.height = screen.height0

screen.centerX = cx
screen.centerY = cy
screen.fps = luasp.fps
-- added 2020/05/05
screen.deviceWidth = luasp.deviceWidth
screen.deviceHeight = luasp.deviceHeight
-- orientations: 'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight'
screen.orientation = luasp.orientation 
-- added 2020/05/06
screen.x0, screen.y0, screen.endX, screen.endY = x0, y0, endX, endY

--added 2021/09/24
screen.remove = nilfunc
screen.setX, screen.setY, screen.setXY = nilfunc, nilfunc, nilfunc
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--2021/08/09: (아래 코드는) 키보드 입력을 처리하기 위해서 작성
--2021/09/08: onkeydown은 없애고 onKey(both)만 남기기로 함
--------------------------------------------------------------------------------
local _keyfunc -- 키가 눌렸을 때 호출되는 콜백함수
local enkey
--------------------------------------------------------------------------------
if _Gideros then
    --------------------------------------------------------------------------------
    local stage, Event = _Gideros.stage, _Gideros.Event
    -- local function mkkeytbl()

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


    local function onkeydown(e)
        local k = keyt[e.keyCode] or (realt[e.realCode] or 'unknown')
        _keyfunc(screen, k,'down')
    -- puts('keyCode:%d,realCode:%d',e.keyCode, e.realCode)
    end


    local function onkeyup(e)
        local k = keyt[e.keyCode] or (realt[e.realCode] or 'unknown')
        _keyfunc(screen, k,'up')
    end


    -- key가 눌렸을 때와 뗐을 때 모두 onKey()가 콜백되도록 함
    enkey = function(func)
        
        local stage, Event = _Gideros.stage, _Gideros.Event

        -- enkey()로 호출한 경우 키이벤트 제거
        if func==nil and screen.__onkey then
            stage:removeEventListener(Event.KEY_DOWN, onkeydown)
            stage:removeEventListener(Event.KEY_UP, onkeyup)
            screen.__onkey = false
            return
        end

        _keyfunc = func -- 콜백함수 교체
        if screen.__onkey then return end --키이벤트가 이미 등록되었다면 종료

        stage:addEventListener(Event.KEY_DOWN, onkeydown)
        stage:addEventListener(Event.KEY_UP, onkeyup )
        screen.__onkey = true

    end


        --2021/08/07:simulator일 경우에 실행되는 함수
    --'esc'를 누르면 cli가 실행되고, '`'를 누르면 builder가 실행된다.
    function luasp.allowEsc()

        -- local keyt, realt = mkkeytbl()

        
        stage:addEventListener(Event.KEY_DOWN, function(e)

            local k = keyt[e.keyCode] or (realt[e.realCode] or 'unknown')
            if k=='esc' then

                if luasp.cli and luasp.cli.isactive then

                    return luasp.cli:hide()
                    
                end

                
                if luasp.console==nil then

                    luasp.require0('luasp._util.esc.console')
                    luasp.console:show()

                else

                    if luasp.console.isactive then
                        luasp.console:hide()
                    else
                        luasp.console:show()
                    end
                    
                end

            end

        end)


    end


    local function ontilde(e)

        local k = keyt[e.keyCode] or (realt[e.realCode] or 'unknown')
        if k=='`' then
            
            print('cli')

            if luasp.cli == nil then

                luasp.require0('luasp._util.esc.cli')
                
            end

            luasp.cli:show()
            

        end

    end


    function luasp.allowCli()

        stage:addEventListener(Event.KEY_DOWN, ontilde)

    end

    function luasp.banCli()

        stage:removeEventListener(Event.KEY_DOWN, ontilde)

    end

--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    -- gideros와 문자열을 일치시키기 위한 변환테이블
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

    local function onKey(e)

        if _keyfunc == nil then return true end

        local k = keyt[e.keyName] or e.keyName
        _keyfunc(screen, k, e.phase)
        return true

    end

    -- key가 눌렸을 때와 뗐을 때 모두 콜백됨
    enkey = function(func)

        -- enkey(nil)로 호출한 경우 키이벤트 제거
        if func==nil and screen.__onkey then
            Runtime:removeEventListener('key', onKey)
            screen.__onkey = false
            return
        end

        _keyfunc = func -- 콜백함수 교체
        if screen.__onkey then return end --이벤트가 이미 등록되었다면 반환

        Runtime:addEventListener('key', onKey)
        screen.__onkey = true

    end

    
    --2021/09/07:simulator일 경우에 실행되는 함수
    --'esc'를 누르면 console이 실행된다
    function luasp.allowEsc()

        Runtime:addEventListener('key', function(e)

            if e.phase=='down' then

                local k = keyt[e.keyName] or e.keyName

                if k=='esc' then

                    if luasp.cli and luasp.cli.isactive then
                        luasp.cli:hide()
                        return true
                    end


                    if luasp.console==nil then

                        luasp.require0('luasp._util.esc.console')
                        luasp.console:show()

                    else

                        if luasp.console.isactive then
                            luasp.console:hide()
                        else
                            luasp.console:show()
                        end

                    end
                end

            end

            return true

        end)

    end




    local function ontilde(e)

        if e.phase=='down' then

            local k = keyt[e.keyName] or e.keyName

            if k=='`' then
            
                -- print('cli')

                if luasp.cli == nil then

                    luasp.require0('luasp._util.esc.cli')
                    
                end

                luasp.cli:show()
                --Runtime:removeEventListener('key', ontilde)

            end

        end

        return true
    end
        

    function luasp.allowCli()

        Runtime:addEventListener('key', ontilde)

    end


    function luasp.banCli()

        Runtime:removeEventListener('key', ontilde)

    end


end

--------------------------------------------------------------------------------
-- end of respective local functions
--------------------------------------------------------------------------------
local tmrkeycheck 
local function checkkeyfunc(self)

    -- print('ckd')
    if screen.onKey then
        enkey(screen.onKey)
        tmrkeycheck:remove()
    end

end
tmrkeycheck = Timer(200, checkkeyfunc, INF)
tmrkeycheck.__nocnt = true


function luasp.changeKeyFunc(func)

    enkey(func)
    
end


function luasp.restoreKeyUser()

    enkey(screen.onKey)

end