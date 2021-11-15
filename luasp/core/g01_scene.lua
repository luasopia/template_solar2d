--------------------------------------------------------------------------------
-- 2020/05/29 초기에 scene0를 생성
-- 2021/08/11: scene끼리 교체할 때 화면의 터치를 금지
-- 2021/09/14: create() method 삭제
--------------------------------------------------------------------------------
local Group = Group
local time0 = 300
local luasp = _luasopia
local x0, y0, endX, endY = luasp.x0, luasp.y0, luasp.endX, luasp.endY
local scnlayer = luasp.scnlayer
--------------------------------------------------------------------------------

local function beforeshow(scn)

    local stage = scn.__stg 
    
    luasp.stage = stage
    scn:beforeShow(stage)

    -- 이전에 hideout되면서 위치가 화면 밖이거나 투명일 수 있으므로
    -- 다시 (표준위치로 )원위치 시켜야 한다.
    stage:set{x=0,y=0,scale=1,rot=0,alpha=1}:show()
    
    --stage:resumeTouch()
    --2021/08/11:퇴장 효과(애니) 동안 커버 생성
    luasp.bantouch()

end


--화면에서 입장하는 효과가 다 끝나고 완전히 자리잡으면 호출되는 함수
local function aftershow(scn)

    local stage = scn.__stg 
    
    luasp.stage = stage
    stage:set{x=0,y=0,scale=1,rot=0,alpha=1}:show()
    
    scn:afterShow(stage)
    
    --2021/08/11:입장효과가 다 끝나면 cover를 제거한다.
    luasp.allowtouch()

end


-- 화면에서 퇴장하는 애니메이션 플레이 직전에 호출되는 함수
local function beforehide(scn)

    luasp.stage = scn.__stg
    scn:beforeHide(scn.__stg)

end


local function afterhide(scn)

    local stage = scn.__stg 
    -- print('scene hideout')
    stage:hide()

    luasp.stage = stage
    scn:afterHide(stage)

end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Scene = class()

local scenes = {} -- 생성된 scene들을 저장하는 테이블
local inScene = nil -- current (or scheduled to enter) scene in the screen
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Scene:init()

    -- scene은 scnlayer에 생성한다.
    self.__stg = Group():addTo(scnlayer):setXY(0,0)
    luasp.stage = self.__stg

end    


-- The following methods can be optionally overridden.
function Scene:beforeShow() end -- called just before showing
function Scene:afterShow() end -- called just after showing
function Scene:beforeHide() end -- called just before hiding
function Scene:afterHide() end -- called just after hiding
-- function Scene:destroy() end -- 이게 필요한가?

--------------------------------------------------------------------------------
-- Scene.goto(url [,effect [,time] ])
-- effect = 'fade', 'slideLeft', 'slideRight', 'rotateLeft', 'rotateRight'
--------------------------------------------------------------------------------
local function goto(url, effect, time)

    -- print('scene.goto')

    time = time or time0 -- set given/default transition time

    -- 2020/05/29 직전 scene이 없다면 scene0로 설정한다.
    local outScene = inScene --or luasp.scene0
    
    -- 과거 scenes테이블을 뒤져서 한 번이라도 create()되었다면 그걸 사용
    -- scenes테이블에 없다면 create를 이용하여 새로 생성하고 scenes에 저장
    inScene = scenes[url]
    if inScene == nil then
        inScene = require(url) -- stage를 새로운 Scene 객체로 교체한다
        scenes[url] = inScene
        -- create(inScene)
    end
    
    beforeshow(inScene)
    beforehide(outScene)

    if effect == 'slideRight' then
        
        inScene.__stg:setX(screen.endX+1)
        
        if outScene then 
            outScene.__stg:shift{time=time, x=-screen.endX, onEnd = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, x=0, onEnd = function()
            aftershow(inScene)
        end}

    elseif effect == 'slideLeft' then
        
        inScene.__stg:setX(-screen.endX)
        
        if outScene then 
            outScene.__stg:shift{time=time, x=screen.endX, onEnd = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, x=0, onEnd = function()
            aftershow(inScene)
        end}

-- --[[
    elseif effect == 'rotateRight' then
        
        inScene.__stg:setRot(-90)
        
        if outScene then 
            outScene.__stg:shift{time=time, rot=90, onEnd = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, rot=0, onEnd = function()
            aftershow(inScene)
        end}
        
    elseif effect == 'rotateLeft' then
        
        inScene.__stg:setRot(90)
        
        if outScene then 
            outScene.__stg:shift{time=time, rot=-90, onEnd = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, rot=0, onEnd = function()
            aftershow(inScene)
        end}
        
-- --[[
    elseif effect == 'fade' then
        
        inScene.__stg:setAlpha(0)

        if outScene then 
            outScene.__stg:shift{time=time, alpha=0, onEnd = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, alpha=1, onEnd = function()
            aftershow(inScene)
        end}

 --]]
    else

        if outScene then afterhide(outScene) end
        aftershow(inScene)

    end

end


-- 2021/11/15: goto()를 호출할 때 한 프레임의 시차를 둔다
-- 이렇게 하지 update()함수 안에서 바로 호출할 때 뭔가 오류가 발생한다.
-- (이유를 모르겠음)
function Scene.goto(url,effect,time)
    Timer(20,function()
        goto(url,effect,time)
    end)
end


-- 2020/05/29 초기에 scene0를 생성한다
luasp.scene0 = Scene()
luasp.stage = luasp.scene0.__stg
inScene = luasp.scene0