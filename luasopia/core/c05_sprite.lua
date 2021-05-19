local int = math.floor
local tIn = table.insert
local timeGapFrame = 1000/_luasopia.fps
local Disp = Display
local DispUpd = Disp.__upd__
--[[---------------------------------------------------------------------------
-- local spr = Sprite(sheet, seq)
-- local sheet = makeSheet(url, frameWidth, frameHeight, numFrames)
-- local seq = { time = ms, -- required
--               frames ( = {1,2,3...,numFrames}) -- 선택: 생략시 모든 프레임 순서 테이블
--               loops (=INF) -- 반복회수, 생략하면 무한반복
--              }
-- seq변수에 여러 테이블을 추가할 수 있다. (ex03.lua참조)
--
-- spr변수는 초기에는 동작이 멈춰있다. 생성하자마자 플레이하려면 다음과 같이 한다.
--
-- local spr = Sprite(sheet, seq, args)
-- spr:play()
--
-- or
--
-- local spr = Sprite(sheet, seq, args):play()
--
-- spr:pause() -- 움직임(seq)을 멈춘다.(이미 멈추어 있는 경우는 무효과)
-- spr:play() -- 정지된 움직임을 다시 푼다. (이미 loops를 다 돌아 멈춘 경우 무효과)
-- spr:play(id or name) -- id/name 시퀀스를 즉시 (첫 프레임부터) 플레이한다.
--
--------------------------------------------------------------------------------]]
Sprite = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then

    -- print('core.sprite (gid)')

    local Snew = _Gideros.Sprite.new
    local Bnew = _Gideros.Bitmap.new

    local function modseq(s, fullFrms)
        local sq = {}
        
        if s.time then

            sq[1] = {time=s.time, frames = s.frames or fullFrms, loops = s.loops or INF}
            sq.default = sq[1]
            sq.__one = true -- seq가 단 한 개라는 것을 저장

        else
        
            for k, v in ipairs(s) do
                sq[k] = {time=v.time, frames = v.frames or fullFrms, loops = v.loops or INF}
                if v.name then sq[v.name] = sq[k] end
            end

        end
        
        -- s.__sq = sq -- 받은 s에 __sq를 저장해두어야 나중에 다시 쓸 수 있다.
        sq.default = sq[1]
        return sq
    end

    -- 2020/03/01:다시 처음부터 플레이할 준비를 하는 함수
    local function setframe1(self)
        self.__idFrame = 1
        if self.__bd:getNumChildren()==1 then self.__bd:removeChildAt(1) end
        self.__bd:addChild(self.__bitmaps[1])
        self.__tmPlay = 0 -- Display와는 별도로 플레이시간을 둔다
        self.__playEnd = false
        self.__play = false
    end

    -- function Sprite:setSequence(sqName, play)
    -- function Sprite:sequence(sqName)
    -- local function setseq(self, sqName)
    function Sprite:seq(sqname)
        if sqname == self.__sqname then return end

        self.__sqname = sqname
        local sq = self.__sq[sqname]
    
        print(string.format('%s, %s',tostring(sqName), tostring(self.__sqname)))

        self.__frames = sq.frames
        self.__loops = sq.loops
        self.__nFrames = #sq.frames
        -- _util.printf('self.__nFrames:%d',self.__nFrames)
        self.__bitmaps = {}
        for k = 1, self.__nFrames do
            -- _util.printf('    k:%d',k)
            local texture = self.__sht.__textures[self.__frames[k] ]
            tIn(self.__bitmaps, Bnew(texture))
            self.__bitmaps[k]:setAnchorPoint(0.5, 0.5)
        end
        self.__timePerFrame = sq.time/self.__nFrames

        setframe1(self)

        return self
    end

    function Sprite:init(sht, seq)
        self.__bd = Snew()
        self.__sht = sht
        -- self.__seq = seq.__sq or modseq(seq, sht.__frames)
        self.__sq = modseq(seq, sht.__frames)

        self:seq(1) -- set 'default'(id==1) sequence
        return Disp.init(self)
    end

    -- 2020/03/01 self.__play 와 self.__playEnd 를 구분한다.
    -- self.__playEnd는 seq에서 지정된 플레이(횟수)가 끝난 것이고
    -- self.__play == false 는 pause()함수가 호출된 경우임
    function Sprite:__upd__()
        if self.__play and not self.__playEnd then
            self.__tmPlay = self.__tmPlay + timeGapFrame
            local playFrameCount = int(self.__tmPlay/self.__timePerFrame)
            local loopCount = int(playFrameCount/self.__nFrames)+1
            local idFrame = playFrameCount%self.__nFrames + 1
            if  idFrame ~= self.__idFrame then
                if 0 < self.__loops and self.__loops < loopCount then 
                    -- self.__play = false
                    self.__playEnd = true
                else
                    self.__idFrame = idFrame
                    self.__bd:removeChildAt(1)
                    self.__bd:addChild(self.__bitmaps[idFrame])
                end
            end
        end
        return DispUpd(self)
    end

    function Sprite:pause() self.__play = false; return self end
    -- 2020/03/01 플레이할게 남아있다면 이어서 플레이한다
    function Sprite:resume() self.__play = true; return self end
    
    -- 2020/03/01 play()가 호출되면 무조건 처음부터 다시 플레이한다.
    function Sprite:play(sqname)
        if sqname ~= nil then
            if sqname ~= self.__sqname then
                self:seq(sqname)
            else -- 이전것과 같은 seq라면 frame을 처음으로 세팅한다
                setframe1(self)
            end
        end

        self.__play = true
        return self
    end

    Sprite.sequence = Sprite.seq
----------------------------------------------------------------------------
-- 2020/01/27 corona의 경우는 이미 Sprite 객체가 있음
----------------------------------------------------------------------------

elseif _Corona then

    -- print('core.sprite (cor)')
    
    local newS = _Corona.display.newSprite
--[[
    local function modSeq(s, fullFrms)
        local sq = {}
        local sq0 = nil
        local idsq = {}
        
        if s.time then
            -- loopCount(Optional) default is 0 (loop indefinitely)
            sq0={name = 'default', time = s.time, frames = s.frames or fullFrms, loopCount = s.loops}
            idsq[0]='default'
        end

        if sq0 ~= nil then tIn(sq, sq0) end

        for k, v in ipairs(s) do
            local name = v.name or tostring(k)
            tIn(sq, {name=name, time=v.time, frames = v.frames or fullFrms, loopCount = v.loops})
            idsq[k] = name
            if sq0==nil and k==1 then idsq[0] = name end
        end
        if #s==0 then sq = sq0 end
        sq.__idsq = idsq
        -- s.__sq = sq -- 넘겨받은 s에 __sq를 저장해두어야 나중에 다시 쓸 수 있다.
        return sq
    end
--]]

    local function modseq(s, fullFrms)
        local sq
        local idsq = {}
        
        if s.time then

            -- loopCount(Optional) default is 0 (loop indefinitely)
            sq = {name = 'default', time = s.time, frames = s.frames or fullFrms, loopCount = s.loops}
            idsq[1]='default'

        else

            sq = {}
            for k, v in ipairs(s) do
                local name = v.name or tostring(k)
                tIn(sq, {name=name, time=v.time, frames = v.frames or fullFrms, loopCount = v.loops})
                idsq[k] = name
                -- if k==1 then idsq[0] = name end
            end

        end

        sq.__idsq = idsq
        return sq

    end

        -- function Sprite:setSequence(v, play) -- v can be nil, num, str
    -- function Sprite:__seq(v) -- v can be nil, num, str
    function Sprite:seq(v) -- v can be nil, num, str

        local name = v or 1
        if v=='default' then v=1 end
        if type(v)=='number' then name=self.__sq.__idsq[v] end
        
        -- print(v, name)
        
        self.__bd:setSequence(name)
        -- if play then return self.__bd:play() end
        
        return self
    end

    -- initially, the animation is paused.
    function Sprite:init(sht, seq)
        self.__sht = sht
        self.__sq = modseq(seq, sht.__frames)
        -- print_table(self.__sq)
        self.__bd = newS(sht.sheet, self.__sq)
        
        self:seq(self)
        return Disp.init(self)
    end


    function Sprite:pause()
        self.__bd:pause()
        return self
    end

    -- corona spriteobj:play()에 대한 설명
    -- Play an animation sequence, starting at the current frame.
    -- This does not reset looping.
    -- Note that object:setSequence() must be called before the sequence can be played.
    -- Play can also be called after object:pause().
    function Sprite:play(v)
        if v then self:seq(v) end
        self.__bd:play()
        return self
    end

    Sprite.sequence = Sprite.seq
end
--------------------------------------------------------------------------------
-- 2020/06/21
function Sprite:getwidth() return self.__sht._w end
function Sprite:getheight() return self.__sht._h end