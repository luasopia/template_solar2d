-- 2021/08/15:created

local tins = table.insert

local palette ={
    ['1'] = Color.WHITE,
    r=Color.RED,
    g=Color.GREEN,
    b=Color.BLUE,
    k=Color.BLACK,
    y=Color.YELLOW,
}


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