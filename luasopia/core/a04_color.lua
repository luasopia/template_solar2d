-- if not_required then return end -- This prevents auto-loading in Gideros
--------------------------------------------------------------------------------
Color = class() --:is'Color'
--------------------------------------------------------------------------------
-- r,g,b are integers between 0~255, alpha is real number between 0~1
-- 2020/03/02 : considering the fisrt argument of constructor is a Color obj
--------------------------------------------------------------------------------
if _Gideros then

    function Color:init(r, g, b, a)
        if isobj(r, Color) then
            self.__r, self.__g, self.__b = r.__r, r.__g, r.__b
            self.hex = r.hex
            self.a = g or r.a or 1 -- in this case, 2nd argument is an alpha
        else
            self.__r, self.__g, self.__b = r, g, b
            self.hex = r*65536 + g*256 + b
            self.a = a or 1
        end
    end

elseif _Corona then
    
    function Color:init(r, g, b, a)
        if isobj(r,Color) then
            self.__r, self.__g, self.__b = r.__r, r.__g, r.__b
            self.r, self.g, self.b = r.r, r.g, r.b
            self.a = g or r.a or 1 -- in this case, 2nd argument is an alpha
        else
            self.__r, self.__g, self.__b = r, g, b
            self.r, self.g, self.b = r/255, g/255, b/255
            -- self.rgb = {self.r, self.g, self.b}
            self.a = a or 1
        end
    end

end

local rand = rand
local lowval = 40 -- 2020/06/12 added to prevent generating too dark color
Color.rand = function()
    return Color(rand(lowval,255),rand(lowval,255),rand(lowval,255))
end

-- 2020/08/27: added 반전색을 만들어주는 함수
Color.invert = function(c)
    return Color(255-c.__r, 255-c.__g, 255-c.__b)
end


-- web color (refer to : https://en.wikipedia.org/wiki/Web_colors )

-- Pink colors
Color.PINK              = Color(255, 192, 203)
Color.LIGHT_PINK        = Color(255, 182, 193) 
Color.HOT_PINK          = Color(255, 105, 180)
Color.DEEP_PINK         = Color(255, 20, 147)
Color.PALE_VIOLET_RED   = Color(219, 112, 147)
Color.MEDIUM_VIOLET_RED = Color(199, 21, 133)

-- Red colors
Color.LIGHT_SALMON      = Color(255, 160, 122)
Color.SALMON            = Color(250, 128, 114)
Color.DARK_SALMON       = Color(233, 150, 122)
Color.LIGHT_CORAL       = Color(240, 128, 128)
Color.INDIAN_RED        = Color(205, 92, 92)
Color.CRIMSON           = Color(220, 20, 60)
Color.FIRE_BRICK        = Color(178, 34, 34)	
Color.DARK_RED          = Color(139, 0, 0)
Color.RED               = Color(255, 0, 0)

-- Orange colors
Color.ORANGE_RED         = Color(255, 69, 0)
Color.TOMATO            = Color(255, 99, 71)
Color.CORAL             = Color(255, 127, 80)
Color.DARK_ORANGE       = Color(255, 140, 0)
Color.ORANGE            = Color(255, 165, 0)

-- Yellow colors
Color.YELLOW            = Color(255, 255, 0)
Color.LIGHT_YELLOW      = Color(255, 255, 224)
Color.LEMON_CHIFFON     = Color(255, 250, 205)
Color.LIGHT_GOLDENROD_YELLOW = Color(250, 250, 210)
Color.PAPAYA_WHIP       = Color(255, 239,213)
Color.MOCCASIN          = Color(255, 228, 181)
Color.PEACH_PUFF        = Color(255, 218, 185)
Color.PALE_GOLDENROD    = Color(238, 232, 170)
Color.KHAKI             = Color(240, 230, 140)
Color.DARK_KHAKI        = Color(189, 183, 107)
Color.GOLD              = Color(255, 215, 0)   

-- Brown colors
Color.CORNSILK          = Color(255, 248, 220)
Color.BLANCHED_ALMOND   = Color(255, 235, 205)
Color.Bisque            = Color(255, 228, 196)
Color.NAVAJO_WHITE      = Color(255, 222, 173)
Color.WHEAT             = Color(245, 222, 179) 
Color.BURLYWOOD         = Color(222, 184, 135) 
Color.TAN               = Color(210, 180, 140)
Color.ROSY_BROWN        = Color(188, 143, 143)
Color.SANDY_BROWN       = Color(244, 164, 96)
Color.GOLDENROD         = Color(218, 165, 32)
Color.DARK_GOLDENROD    = Color(184, 134, 11)
Color.PERU              = Color(205, 133, 63)
Color.CHOCOLATE         = Color(210, 105, 30)
Color.SADDLE_BROWN      = Color(139, 69, 19)
Color.SIENNA            = Color(160, 82, 45)
Color.BROWN             = Color(165, 42, 42)
Color.MAROON            = Color(128, 0, 0)

-- Purple, violet, and magenta colors
Color.LAVENDER          = Color(230, 230, 250)
Color.THISTLE           = Color(216, 191, 216)
Color.PLUM              = Color(221, 160, 221)
Color.VIOLET            = Color(238, 130, 238) 
Color.ORCHID            = Color(218, 112, 214)
Color.FUCHSIA           = Color(255, 0, 255)
Color.MAGENTA           = Color(255, 0, 255)
Color.MEDIUM_ORCHID     = Color(186,  85, 211)
Color.MEDIUM_PURPLE     = Color(147, 112, 219)
Color.BLUE_VIOLET       = Color(138, 43, 226)
Color.DARK_VIOLET       = Color(148, 0, 211)
Color.DARK_ORCHID       = Color(153, 50, 204)
Color.DARK_MAGENTA      = Color(139, 0, 139)
Color.PURPLE            = Color(128, 0, 128)
Color.INDIGO            = Color(75, 0, 130)
Color.DARK_SLATE_BLUE   = Color(72, 61, 139)
Color.SLATE_BLUE        = Color(106, 90, 205)
Color.MEDIUM_SLATE_BLUE = Color(123, 104, 238)

-- White colors
Color.WHITE             = Color(255, 255, 255)
Color.SNOW              = Color(255, 250, 250)
Color.HONEYDEW          = Color(240, 255, 240) 
Color.MINT_CREAM        = Color(245, 255, 250) 
Color.AZURE             = Color(240, 255, 255)
Color.ALICE_BLUE        = Color(240, 248, 255)
Color.GHOST_WHITE       = Color(248, 248, 255)
Color.WHITE_SMOKE       = Color(245, 245, 245)
Color.SEASHELL          = Color(255, 245, 238)
Color.BEIGE             = Color(245, 245, 220)
Color.OLD_LACE          = Color(253, 245, 230)
Color.FLORAL_WHITE      = Color(255, 250, 240)
Color.IVORY             = Color(255, 255, 240)
Color.ANTIQUE_WHITE     = Color(250, 235, 215)
Color.LINEN             = Color(250, 240, 230)
Color.LAVENDER_BLUSH    = Color(255, 240, 245)
Color.MISTY_ROSE        = Color(255, 228, 225)

-- Gray and black colors
Color.GAINSBORO         = Color(220, 220, 220)
Color.LIGHT_GRAY        = Color(211, 211, 211)
Color.SILVER            = Color(192, 192, 192)
Color.DARK_GRAY         = Color(169, 169, 169)
Color.GRAY              = Color(128, 128, 128)
Color.DIM_GRAY          = Color(105, 105, 105)
Color.LIGHT_SLATE_GRAY  = Color(119, 136, 153)
Color.SLATE_GRAY        = Color(112, 128, 144)
Color.DARK_SLATE_GRAY   = Color(47, 79, 79)
Color.BLACK             = Color(0,0,0)

-- Green colors
Color.DARK_OLIVE_GREEN  = Color(85, 107, 47)
Color.OLIVE             = Color(128, 128, 0)
Color.OLIVE_DRAB        = Color(107, 142, 35)
Color.YELLOW_GREEN      = Color(154, 205, 50)
Color.LIME_GREEN        = Color(50, 205, 50)
Color.LIME              = Color(0, 255, 0)
Color.LAWN_GREEN        = Color(124, 252, 0) 
Color.CHARTREUSE        = Color(127, 255, 0) 
Color.GREEN_YELLOW      = Color(173, 255, 47)
Color.SPRING_GREEN      = Color(0, 255, 127) 
Color.MEDIUM_SPRING_GREEN = Color(0, 250, 154)
Color.LIGHT_GREEN       = Color(144, 238, 144) 
Color.PALE_GREEN        = Color(152, 251, 152)
Color.DARK_SEA_GREEN    = Color(143, 188, 143)
Color.MEDIUM_AQUAMARINE = Color(102, 205, 170)
Color.MEDIUM_SEA_GREEN  = Color(60, 179, 113)
Color.SEA_GREEN         = Color(46, 139, 87)
Color.FOREST_GREEN      = Color(34, 139, 34)
Color.GREEN             = Color(0, 128, 0)
Color.DARK_GREEN        = Color(0, 100, 0)

-- cyan colors
Color.AQUA              = Color(0, 255, 255)
Color.CYAN              = Color(0, 255, 255)
Color.LIGHT_CYAN        = Color(224, 255, 255)
Color.PALE_TURQUOISE    = Color(175, 238, 238)
Color.AQUAMARINE        = Color(127, 255, 212)
Color.TURQUOISE         = Color(64, 224, 208)
Color.MEDIUM_TURQUOISE  = Color(72, 209, 204)
Color.DARK_TURQUOISE    = Color(0, 206, 209)
Color.LIGHT_SEA_GREEN   = Color(32, 178, 170)
Color.CADET_BLUE        = Color(95, 158, 160)
Color.DARK_CYAN         = Color(0, 139, 139)
Color.TEAL              = Color(0, 128, 128)

-- Blue colors
Color.LIGHT_STEEL_BLUE  = Color(176, 196, 222)
Color.POWDER_BLUE       = Color(176, 224, 230)
Color.LIGHT_BLUE        = Color(173, 216, 230)
Color.SKY_BLUE          = Color(135, 206, 235)
Color.LIGHT_SKY_BLUE    = Color(135, 206, 250)
Color.DEEP_SKY_BLUE     = Color(0, 191, 255)
Color.DODGER_BLUE       = Color(30, 144, 255)
Color.CORN_FLOWER_BLUE  = Color(100, 149, 237)
Color.STEEL_BLUE        = Color(70, 130, 180)
Color.ROYAL_BLUE        = Color(65, 105, 225)
Color.BLUE              = Color(0, 0, 255)
Color.MEDIUM_BLUE       = Color(0, 0, 205)
Color.DARK_BLUE         = Color(0, 0, 139)
Color.NAVY              = Color(0, 0, 128)
Color.MIDNIGHT_BLUE     = Color(25, 25, 112)