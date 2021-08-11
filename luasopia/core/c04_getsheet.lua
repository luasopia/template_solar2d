-- 2021/08/11:started refactoring Sprite class and getsheet() function

local rooturl = _luasopia.root .. '/' -- 2021/05/12
local tins = table.insert

--------------------------------------------------------------------------------
if _Corona then
--------------------------------------------------------------------------------

    local newImageSheet = _Corona.graphics.newImageSheet
    
    function getsheet(url, frmwidth, frmheight, nfrms)
        local sheet = {}
        local args = {width=frmwidth, height=frmheight, numFrames = nfrms}
        sheet.__txts= newImageSheet('root/'..url, args)
        sheet.__frmwdt = frmwidth
        sheet.__frmhgt = frmheight
        sheet.__nfrms = nfrms
        sheet.__allfrms = {1}
        for k=2,nfrms do tins(sheet.__allfrms, k) end
        
        return sheet
    end

--------------------------------------------------------------------------------
elseif _Gideros then
--------------------------------------------------------------------------------

    local txtNew = _Gideros.Texture.new
    local txtRgnNew = _Gideros.TextureRegion.new
    

    function getsheet(url, frmwidth, frmheight, nfrms)

        local sht = { 
                __txts = {},
                __frmwdt = frmwidth,
                __frmhgt = frmheight,
                __nfrms = nfrms,
                __allfrms={}
        }

        local txt = txtNew(rooturl..url)
        local w, h = txt:getWidth(), txt:getHeight()
        local frm = 0

        for yi = 0, h/frmheight-1 do 

            for xi = 0, w/frmwidth-1 do

                local x, y = xi*frmwidth, yi*frmheight
                local tr = txtRgnNew(txt, x, y, frmwidth, frmheight)
                -- tins(sht.__txts, bmpNew(tr) ) -- bitmap을 저장하면 오류가 남
                tins(sht.__txts, tr) -- 따라서 texture를 테이블에 저장해야 함
                frm = frm + 1
                --print('frm:'..frm)
                tins(sht.__allfrms, frm)
                if nfrms and frm >=nfrms then return sht end

            end

        end

        return sht
        
    end

end
--------------------------------------------------------------------------------