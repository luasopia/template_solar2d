local Group = Group

Ani = class(Group)


--[[

local r = Ani{
    [1] = {
        img = 'part.png' -- or
        shp = {Rect, 100} -- or
        sprt = {imgSht,seq}


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