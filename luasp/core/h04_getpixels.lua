local tblins = table.insert
local max, _INF = math.max, -math.huge

--[[

getpixels({
    '    1',
    '  111',
    ' 1111',
    '11111',
},
local alien = getpixels(
    {
    '  1     1',
    '   1   1',
    '  1111111',
    ' 11r111r11',
    '11111111111',
    '1 1111111 1',
    '1 1     1 1',
    '   11 11',
    },{
    '  1     1  ',
    '1  1   1  1',
    '1 1111111 1',
    '111 111 111',
    ' 111111111 ',
    '  1111111  ',
    '   1   1   ',
    '  1     1  '
    }
)

)



--]]


-- 2021/08/15:created
local luasp = _luasopia
local tins = table.insert

--------------------------------------------------------------------------------
local palette = luasp.palette0
--------------------------------------------------------------------------------

function getpixels(...) --decode maps table

    local maps = {...}

    local pxsht={
        __txts={},
        __allfrms = {},
    } -- pixels sheet
    
    local width, height = -math.huge, -math.huge
    
    for k = 1,#maps do
        
        local map=maps[k]
        
        local pxs = {}
        local idpx = 1
        local x, y = 0, 0

        for i=1,#map do

            local pt = map:sub(i,i)
            
            if pt == ':' then

                if height < y+2 then height = y+2 end

                y = y + 1
                x = 0
            
            elseif pt =='0' then

                if width < x+1 then width = x+1 end

                x=x+1

            else

                -- x0,y0는 앵커가 (0,0)일 때의 xy좌표값이다.
                pxs[idpx] = {x0=x, y0=y, c=palette[pt]}
                idpx = idpx + 1

                if width < x+1 then width = x+1 end

                x=x+1
            
            end

            
        end
        
        pxsht.__txts[k] = pxs
        pxsht.__allfrms[k] = k

    end

    pxsht.__frmwdt = width
    pxsht.__frmhgt = height
    pxsht.__nfrms = #pxsht.__allfrms
   
    return pxsht

end


-- 2021/09/05:
-- tbl={ -- 테이블의 숫자는 팔레트(색)번호를 지정한다. 0은 투명색
-- {{1,2,3..},{4,5,6..},{7,8,9...}}, --pixelart1
-- {{1,2,3..},{4,5,6..},{7,8,9...}}, --pixelart2
-- ...
-- }
local function getpxs(tbl)

    local nfrms = #tbl
    local maxw, maxh = 0, 0

    local pxsht={
        __txts={},
        __allfrms = {},
        __nfrms = nfrms
    } -- pixels sheet


    for idfrm = 1,nfrms do

        local pxart = tbl[idfrm]
        local pxs, idpx = {}, 1
        local ncol = #pxart
        maxh = max(maxh, ncol)
        local maxnrow = 0

        for y = 1, ncol do

            local row = pxart[y]
            local nrow = #row
            maxw = max(maxw, nrow)
            maxnrow = max(maxnrow, nrow)
            for x = 1, nrow do

                local idcolor = row[x] -- pixel color
                if idcolor ~=0 then -- 투명색(0)은 건너뛴다
                    -- pxs[idpx]={x0=x-1, y0=y-1, c=palette[idcolor]}
                    -- idpx = idpx + 1
                    tblins(pxs, {x0=x-1, y0=y-1, c=palette[idcolor]})
                end

            end

        end

        -- 각각의 프레임마다 width, height를 저장한다.(서로 다를 수 있음)
        pxs.width, pxs.height = maxnrow, ncol -- width는 nrow들 중 가장 큰것으로
        pxsht.__txts[idfrm] = pxs
        pxsht.__allfrms[idfrm] = idfrm
        --print('idfrm:',idfrm)

    end -- for idfrm = 1,nfrms do

    pxsht.__frmwdt, pxsht.__frmhgt = maxw, maxh

    return pxsht

end

luasp._getpxs0 = getpxs