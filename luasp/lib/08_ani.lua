local Group = Group

Ani = class(Group)


--[[

local r = Ani{
    [1] = {
        img = Image('png') -- or
        shp = Rect(100) -- or
        sprt = Sprite(...)


        x=
        y=
        rot=
        scale=
        alpha=

        drot=
    },

    [2] = ...

}



--]]



function Ani:init(args) -- ARGumentS

    Group.init(self)

    self.parts = {}
    
    for k=1,#args do

    end

end