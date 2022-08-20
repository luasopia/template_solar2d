--------------------------------------------------------------------------------
-- 2020/02/10: first created
-- 2021/08/12: modified and added some static methods
--------------------------------------------------------------------------------
local rooturl = _luasopia.root .. '/' -- 2021/05/12
local INF = INF
--------------------------------------------------------------------------------
Sound = class()

if _Gideros then 
    
    local sounds = {} -- 2021/08/12 모든 Sound객체 관리
    -- stopAll(), pauseAll()같은 스태틱메서드에서 사용됨

    local Sndnew = _Gideros.Sound.new
    local EFIN = _Gideros.Event.COMPLETE


    -- The Sound class lets you load and 
    -- play WAV, MP3, MOD, XM, S3M and IT sound files.
    function Sound:init(url, volume)

        self.__bd = Sndnew(rooturl..url, volume)
        self.__vol = volume or 1

        sounds[self]=self -- 2021/08/12 added

    end


    -- 정해진 반복회수만큼 play하기 위한 callback함수
    local function count(self)

        self.__cnt = self.__cnt + 1

        if self.__cnt<self.__loops then

            self.__ch = self.__bd:play()
            self.__ch:addEventListener(EFIN, count, self)

            if self.__vol < 1 then
                self.__ch:setVolume(self.__vol)
            end

        end

    end
    

    function Sound:play(loops)

        local loops = loops or 1
        self.__loops = loops

        -- Sound:play(startTime, looping(=false), paused)
        -- startTime: (number, default = 0) The initial position in milliseconds at which playback should start.
        -- looping: (boolean, default = false)
        -- paused: (boolean, default = false)
        if loops == 1 then
        
            self.__ch = self.__bd:play()
        
        elseif loops == INF then

            self.__ch = self.__bd:play(0,true)

        else -- loops로 주어진 횟수만큼만 플레이한다.

            self.__cnt = 0
            self.__ch = self.__bd:play()
            if self.__ch then
                self.__ch:addEventListener(EFIN, count, self)
            end

        end

        --if self.__vol < 1 then 
        if self.__vol < 1 and self.__ch then
            self.__ch:setVolume(self.__vol)
        end
        --end

        return self

    end


    function Sound:stop()

        if self.__ch then
            self.__ch:stop()
            self.__ch = nil
        end

        return self

    end


    function Sound:pause()

        if self.__ch then
            self.__ch:setPaused(true)
        end

        return self

    end

    
    function Sound:resume()

        if self.__ch then
            self.__ch:setPaused(false)
        end

        return self

    end


    function Sound:setVolume(v)

        self.__vol = v
        if self.__ch then
            self.__ch:setVolume(v)
        end

        return self

    end
    

    function Sound:remove()

        self:stop()
        sounds[self] = nil

    end


    --static methods

    function Sound.stopAll()

        for _, snd in pairs(sounds) do
            snd:stop()
        end

    end


    function Sound.pauseAll()

        for _, snd in pairs(sounds) do
            snd:pause()
        end

    end


    function Sound.resumeAll()

        for _, snd in pairs(sounds) do
            snd:resume()
        end

    end


    function Sound.setVolumeAll(v)

        for _, snd in pairs(sounds) do
            snd:setVolume(v)
        end

    end

--------------------------------------------------------------------------------
elseif _Corona then -- 2020/02/09
--------------------------------------------------------------------------------

-- wav files must be 16-bit uncompressed
-- loadSound()는 파일전체를 로드하며 작은 크기의 효과음 에 적절하다
-- 단, 런타임에 로딩하는 것은 바람직하지 않고 미리 로딩시켜서 핸들을 생성하는 게 낫다.
-- loadStream()은 주로 mp3 같은 배경음악용이고 파일조각을 수시로 읽어들이므로
-- 런타임에 로딩해도 문제가 없다.
    
    local wavs = {} -- stores the (corona) handles of wav files
    local loadsnd = _Corona.audio.loadSound
    local loadstrm = _Corona.audio.loadStream 
    local play = _Corona.audio.play
    local setvol = _Corona.audio.setVolume
    local isplaying = _Corona.audio.isChannelPlaying
    local stop = _Corona.audio.stop
    local pause = _Corona.audio.pause
    local resume = _Corona.audio.resume


    function Sound:init(url, volume)

        local isWav = string.find(url, '.wav')
        if isWav then -- wav파일이면 loadSound()함수를 사용
            self.__bd = wavs[url]
            if self.__bd == nil then
                self.__bd = loadsnd(rooturl..url) --; print(url..' loaded')
                wavs[url] = self.__bd
            end
        else -- mp3는 loadStream함수를 사용. wavs에 저장도 안한다.
            self.__bd = loadstrm(rooturl..url)
        end
        --self.__loops = loops or 0 -- dafault는 한 번 플레이됨
        self.__vol = volume or 1 -- 초기 볼륨은 1(가장크게) 이다.

    end


    function Sound:play(loops)
        --[[
        -- 2020/02/11:만약 play 중이라면 그것은 멈추고 다시 시작한다.
        if self.__ch and _Corona.audio.isChannelPlaying(self.__ch) then
            _Corona.audio.stop(self.__ch)
        end
        --]]
        -- corona에서는 loops 가 추가적인 플레이횟수를 의미함
        -- loops가 INF면 무한반복
        if loops == INF then
            self.__loops = -1
        else
            self.__loops = loops and (loops-1) or 0
        end

        self.__ch = play(self.__bd, {loops=self.__loops})

        if self.__vol<1 then
            setvol(self.__vol, {channel=self.__ch})
        end

        return self

    end



    function Sound:stop()

        if self.__ch and isplaying(self.__ch) then
            stop(self.__ch)
        end

    end


    function Sound:pause()

        -- if self.__ch then
            pause(self.__ch)
        -- end
        return self

    end


    function Sound:resume()

        -- if self.__ch then
            resume(self.__ch)
        -- end
        return self

    end


    -- volume은 1과 0사이의 값이다.
    function Sound:setVolume(v)

        self.__vol = v
        if self.__ch then setvol(v, {channel=self.__ch}) end
        return self

    end


    function Sound:remove()

        if self.__ch then
            stop(self.__ch)
            self.__bd = nil -- self.__ch = nil
        end

    end
    

    -- static methods
    Sound.pauseAll = pause
    Sound.resumeAll = resume
    Sound.setVolumeAll = setvol
    Sound.stopAll = stop

end