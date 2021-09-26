-- 2021/08/11: refactored getsheet() function (and Sprite class)
local luasp = _luasopia
local rooturl = luasp.root .. '/' -- 2021/05/12
local tins = table.insert

--------------------------------------------------------------------------------
ImageSheet = class()
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------

    local txtNew = _Gideros.Texture.new
    local txtRgnNew = _Gideros.TextureRegion.new
    

    function ImageSheet:init(url, frmwidth, frmheight, nfrms)

        self.__txts = {}
        self.__frmwdt = frmwidth
        self.__frmhgt = frmheight
        self.__nfrms = nfrms
        self.__allfrms={}

        local txt = txtNew(rooturl..url)
        local w, h = txt:getWidth(), txt:getHeight()
        local frm = 0

        for yi = 0, h/frmheight-1 do 

            for xi = 0, w/frmwidth-1 do

                local x, y = xi*frmwidth, yi*frmheight
                local tr = txtRgnNew(txt, x, y, frmwidth, frmheight)
                -- tins(sht.__txts, bmpNew(tr) ) -- bitmap을 저장하면 오류가 남
                tins(self.__txts, tr) -- 따라서 texture를 테이블에 저장해야 함
                frm = frm + 1
                tins(self.__allfrms, frm)
                if nfrms and frm >= nfrms then return sht end

            end

        end

    end

--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    local newImageSheet = _Corona.graphics.newImageSheet
    

    function ImageSheet:init(url, frmwidth, frmheight, nfrms)
        
        local args = {width=frmwidth, height=frmheight, numFrames = nfrms}
        self.__txts= newImageSheet('root/'..url, args)
        self.__frmwdt = frmwidth
        self.__frmhgt = frmheight
        self.__nfrms = nfrms
        self.__allfrms = {1}
        for k=2,nfrms do tins(self.__allfrms, k) end
        
    end
    
end