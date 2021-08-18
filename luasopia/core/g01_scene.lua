local Group = Group
local time0 = 300
local lsp = _luasopia
local x0, y0, endx, endy = lsp.x0, lsp.y0, lsp.endx, lsp.endy
local scnlayer = lsp.scnlayer
--------------------------------------------------------------------------------
-- private static methods
--------------------------------------------------------------------------------
local function create(scn)

    lsp.stage = scn.__stg
    scn:create(scn.__stg)

end


local function beforeshow(scn)

    local stage = scn.__stg 
    
    lsp.stage = stage
    scn:beforeshow(stage)

    -- 이전에 hideout되면서 위치가 화면 밖이거나 투명일 수 있으므로
    -- 다시 (표준위치로 )원위치 시켜야 한다.
    stage:set{x=0,y=0,scale=1,rot=0,alpha=1}:show()
    
    --stage:resumetouch()
    --2021/08/11:퇴장 효과(애니) 동안 커버 생성
    scn:__mkcover__()

end

--화면에서 입장하는 효과가 다 끝나고 완전히 자리잡으면 호출되는 함수
local function aftershow(scn)

    local stage = scn.__stg 

    --2021/08/11:입장효과가 다 끝나면 cover를 제거한다.
    scn:__rmcover__()

    lsp.stage = stage
    stage:set{x=0,y=0,scale=1,rot=0,alpha=1}:show()

    scn:aftershow(stage)

end

-- 화면에서 퇴장하는 애니메이션 플레이 직전에 호출되는 함수
local function beforehide(scn)

    lsp.stage = scn.__stg
    scn:beforehide(scn.__stg)

    --2021/08/11:퇴장 효과(애니) 동안 커버 생성
    scn:__mkcover__()

end


local function afterhide(scn)

    local stage = scn.__stg 
    -- print('scene hideout')
    stage:hide()

    lsp.stage = stage
    scn:afterhide(stage)

end
--------------------------------------------------------------------------------
Scene = class()

local scenes = {} -- 생성된 scene들을 저장하는 테이블
local inScene = nil -- current (or scheduled to enter) scene in the screen

--------------------------------------------------------------------------------
function Scene:init()

    -- scene은 scnlayer에 생성한다.
    self.__stg = Group():addto(scnlayer):xy(0,0)
    lsp.stage = self.__stg

end    


-- The following methods can be optionally overridden.
function Scene:create() end -- 최초에 딱 한 번만 호출됨
function Scene:beforeshow() end -- called just before showing
function Scene:aftershow() end -- called just after showing
function Scene:beforehide() end -- called just before hiding
function Scene:afterhide() end -- called just after hiding
-- function Scene:destroy() end


--------------------------------------------------------------------------------
-- 2021/08/11:입장/퇴장 효과(애니메이션) 도중에 터치(탭)가 발생하는 것을 막기위해서
-- 아래의 두 개의 내부메서드가 사용된다.

function Scene:__mkcover__()

    self.tag=self.tag or 'scn0'

    
    if self.__cover==nil or self.__cover:isremoved() then
        
        print('mkcover '..self.tag)

        self.__cover = Rect(screen.width,screen.height):alpha(0)
        -- solar2d는 alpha가 0이면 기본적으로 touch 이벤트가 불능이 된다.
        -- alpha가 0임에도 터치이벤트가 발생토록 하려면 아래와 같이 한다.
        -- gideros는 alpha가 0이어도 터치이벤트가 발생한다.
        if _Corona then self.__cover.__bd.isHitTestable = true end -- solar2d에서만 필요
        function self.__cover:ontouch() end
    end

end

function Scene:__rmcover__()

    self.tag=self.tag or 'scn0'
    
    if self.__cover and not self.__cover:isremoved() then
        print('rmcover '..self.tag)
        self.__cover:remove()
    end

end

--------------------------------------------------------------------------------
-- Scene.goto(url [,effect [,time] ])
-- effect = 'fade', 'slideRight'
--------------------------------------------------------------------------------
function Scene.goto(url, effect, time)

    -- print('scene.goto')

    time = time or time0 -- set given/default transition time

    -- 2020/05/29 직전 scene이 없다면 scene0로 설정한다.
    local outScene = inScene --or lsp.scene0
    
    -- 과거 scenes테이블을 뒤져서 한 번이라도 create()되었다면 그걸 사용
    -- scenes테이블에 없다면 create를 이용하여 새로 생성하고 scenes에 저장
    inScene = scenes[url]
    if inScene == nil then
        inScene = require(url) -- stage를 새로운 Scene 객체로 교체한다
        scenes[url] = inScene
        create(inScene)
    end
    
    beforeshow(inScene)
    beforehide(outScene)

    if effect == 'slideRight' then
        
        inScene.__stg:x(screen.endx+1)
        
        if outScene then 
            outScene.__stg:shift{time=time, x=-screen.endx, onend = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, x=0, onend = function()
            aftershow(inScene)
        end}

    elseif effect == 'slideLeft' then
        
        inScene.__stg:x(-screen.endx)
        
        if outScene then 
            outScene.__stg:shift{time=time, x=screen.endx, onend = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, x=0, onend = function()
            aftershow(inScene)
        end}

-- --[[
    elseif effect == 'rotateRight' then
        
        inScene.__stg:rot(-90)
        
        if outScene then 
            outScene.__stg:shift{time=time, rot=90, onend = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, rot=0, onend = function()
            aftershow(inScene)
        end}
        
    elseif effect == 'rotateLeft' then
        
        inScene.__stg:rot(90)
        
        if outScene then 
            outScene.__stg:shift{time=time, rot=-90, onend = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, rot=0, onend = function()
            aftershow(inScene)
        end}
        
-- --[[
    elseif effect == 'fade' then
        
        inScene.__stg:alpha(0)

        if outScene then 
            outScene.__stg:shift{time=time, alpha=0, onend = function()
                afterhide(outScene)
            end}
        end
        
        inScene.__stg:shift{time=time, alpha=1, onend = function()
            aftershow(inScene)
        end}

 --]]
    else

        if outScene then afterhide(outScene) end
        aftershow(inScene)

    end

end

-- 2020/05/29 초기에 scene0를 생성한다
-- scnlayer에는 screen(Rect객체)과 scene.__stg 만을 집어넣는다
lsp.scene0 = Scene()
lsp.stage = lsp.scene0.__stg
inScene = lsp.scene0