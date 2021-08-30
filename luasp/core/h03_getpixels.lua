-- 2021/08/15:created

local tins = table.insert

--pico-8 palette
local palette ={
    --'0' means transparent (or empty)
    ['a'] = Color.BLACK,         K = Color.BLACK,
    ['b'] = Color(29,43,83),                        --dark blue
    ['c'] = Color(126,37,83),                       -- dark purple
    ['d'] = Color(0,135,81),                          -- dark green
    ['e'] = Color(171,82,54),                         -- brown
    ['f'] = Color(95,87,79),                          -- dark gray
    ['g'] = Color(194,195,199),  G = Color(194,195,199), -- light gray
    ['h'] = Color(255,241,232), ['1'] = Color(255,241,232),
    ['i'] = Color(255,0,77),    R = Color(255,0,77), -- red
    ['j'] = Color(255,163,0),   O = Color(255,163,0), -- orange
    ['k'] = Color(255,236,39),  Y = Color(255,236,39), -- yellow
    ['l'] = Color(0,228,54),    G = Color(0,228,54), -- green
    ['m'] = Color(41,173,255),  B = Color(41,173,255), -- blue
    ['n'] = Color(131,118,156), I = Color(131,118,156), --indigo
    ['o'] = Color(255,119,168), P = Color(255,119,168), --pink
    ['p'] = Color(255,204,170),                          -- peach
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