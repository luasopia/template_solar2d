-- if not_required then return end -- This prevents auto-loading in Gideros

local tIn = table.insert
-- local timeGapFrame = 1000/screen.fps
local timeGapFrame = 1000/_luasopia.fps

local rooturl = _luasopia.root .. '/' -- 2021/05/12
--------------------------------------------------------------------------------
-- 생성자 및 멤버함수
----------------------------------------------------------------------------
-- 2020/01/02,2020/01/18: 하나의 Bitmap이 여러 Sprite에 동시에 add될 수 없다.
-- 따라서 공용 Bitmap을 따로 저장해놓아도 소용이 없다. 단, texture는 가능함
-- TextureRegion은 맨처음 호출에서 미리 생성해서 sht.__textures에 저장한다.
-- 이후에 같은 sht 테이블이 넘어온다면 이미 생성된 sht.__textures을 이용한다
-- 이것으로 같은 sht에 대해서 계산 코드를 여러 번 수행하는 것을 회피한다.
----------------------------------------------------------------------------
if _Gideros then

    -- log('getsheet (gid)')
    
    local Tnew = _Gideros.Texture.new
    local TRnew = _Gideros.TextureRegion.new
    
    function getsheet(url, frameWidth, frameHeight, numFrames)
        local txts, frms = {}, {}
        local sht = {__textures = txts, __frames = frms, _w = frameWidth, _h = frameHeight}
        local txt = Tnew(rooturl..url)
        local w, h = txt:getWidth(), txt:getHeight()
        local nfrms = 0
        for yi = 0, h/frameHeight-1 do 
            for xi = 0, w/frameWidth-1 do
                local x, y = xi*frameWidth, yi*frameHeight
                local tr = TRnew(txt, x, y, frameWidth, frameHeight)
                tIn(txts, tr)
                nfrms = nfrms + 1
                tIn(frms, nfrms)
                -- print('frm:'..nfrms)
                if numFrames and nfrms >=numFrames then return sht end
            end
        end
        return sht
    end

elseif _Corona then

    local newIS = _Corona.graphics.newImageSheet
    
    function getsheet(url, frameWidth, frameHeight, numFrames)
        local args = {width=frameWidth, height=frameHeight, numFrames = numFrames}
        local sht = {sheet = newIS(rooturl..url, args), __frames={}, _w = frameWidth, _h = frameHeight}
        for k=1,numFrames do tIn(sht.__frames, k) end
        return sht
    end
    
end

--[[
Sheet = class() --:is'Sheet'
----------------------------------------------------------------------------
if _Gideros then

    -- log('getSheet (gid)')
    
    local Tnew = _Gideros.Texture.new
    local TRnew = _Gideros.TextureRegion.new
    
    function Sheet:init(url, frameWidth, frameHeight, numFrames)
        local txts, frms = {}, {}
        -- local sht = {__textures = txts, __frames = frms}
        local txt = Tnew(url)
        local w, h = txt:getWidth(), txt:getHeight()
        local nfrms = 0
        for yi = 0, h/frameHeight-1 do 
            for xi = 0, w/frameWidth-1 do
                local x, y = xi*frameWidth, yi*frameHeight
                local tr = TRnew(txt, x, y, frameWidth, frameHeight)
                tIn(txts, tr)
                nfrms = nfrms + 1
                tIn(frms, nfrms)
                print('frm:'..nfrms)
                if numFrames and nfrms >=numFrames then
                    self.__textures = txts
                    self.__frames = frms
                    return
                end
            end
        end

        self.__textures = txts
        self.__frames = frms
        -- return sht
    end

elseif _Corona then

    local newIS = _Corona.graphics.newImageSheet
    
    -- function getSheet(url, frameWidth, frameHeight, numFrames)
    function Sheet:init(url, frameWidth, frameHeight, numFrames)
        local args = {width=frameWidth, height=frameHeight, numFrames = numFrames}
        -- local sht = {sheet = newIS(url, args), __frames={} }
        -- for k=1,numFrames do tIn(sht.__frames, k) end
        -- return sht
        
        self.sheet = newIS(url, args)
        self.__frames = {}
        for k = 1,numFrames do tIn(self.__frames, k) end

    end
    
end
--]]