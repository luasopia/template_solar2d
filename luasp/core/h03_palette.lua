--2021/09/04:created

--[[
--pico-8 palette
local palette ={
    --'0' means transparent (or empty)
    ['a'] = Color.BLACK,         K = Color.BLACK,
    ['b'] = Color(29,43,83),                        --dark blue
    ['c'] = Color(126,37,83),                       -- dark purple
    ['d'] = Color(0,135,81),                          -- dark green
    ['e'] = Color(171,82,54),                         -- brown
    ['f'] = Color(95,87,79),                          -- dark gray
    ['g'] = Color(194,195,199),                      -- light gray
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
--]]

local luasp = _luasopia
--------------------------------------------------------------------------------
Palette = class()
--------------------------------------------------------------------------------

function Palette:init()

    -- 아래는 사용자가 직접 도트를 문자열로 입력할 때
    -- 사용되는 key들
    self['0'] = Color(0,0,0,0)      -- no color (transparent)
    self['1'] = Color(255,241,232)  -- 'w'hite
    self['k'] = Color.BLACK         -- blac'k'
    self['r'] = Color(255,0,77)     -- 'r'ed
    self['g'] = Color(255,0,77)     -- 'g'reen
    self['b'] = Color(41,173,255)   -- 'b'lue
    self['y'] = Color(255,236,39)   -- 'y'ellow
    self['p'] =  Color(255,119,168) -- 'p'ink

end

--------------------------------------------------------------------------------
-- pico-8 color palette
local pxp = Palette()

pxp[1] = Color.BLACK
pxp[2] = Color(29,43,83)
pxp[3] = Color(126,37,83)      -- dark purple
pxp[4] = Color(0,135,81)       -- dark green
pxp[5] = Color(171,82,54)      -- brown
pxp[6] = Color(95,87,79)       -- dark gray
pxp[7] = Color(194,195,199)    -- light gray
pxp[8] = Color(255,241,232)    -- white
pxp[9] = Color(255,0,77)       -- red
pxp[10] = Color(255,163,0)     -- orange
pxp[11] = Color(255,236,39)    -- yellow
pxp[12] = Color(0,228,54)      -- green
pxp[13] = Color(41,173,255)    -- blue
pxp[14] = Color(131,118,156)   --indigo
pxp[15] = Color(255,119,168)   --pink
pxp[16] = Color(255,204,170)   -- peach

luasp.palette0 = pxp