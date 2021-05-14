--2020/06/19 : class for animation
local Group = Group
lib.Ani = class(Group)
local Ani = lib.Ani

function Ani:init(pngs, shifts)
    Group.init(self)
end