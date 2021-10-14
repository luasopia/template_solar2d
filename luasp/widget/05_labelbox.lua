-- 2021/09/12: created
local luasp = _luasopia
local Text1 = luasp.Text1
local print0 = luasp.print0

LabelBox = class(Group)

function LabelBox:init(labeltext,width,height,opt)

    self.__lbtxt = labeltext
    self.__wdt, self.__hgt= width, height

    opt = opt or {}
    opt.borderwidth = opt.borderwidth or 3
    opt.bordercolor = opt.bordercolor or Color.GRAY
    opt.labelymargin = opt.labelymargin or 10
    self.__lbopt = opt

    Group.init(self)

    return self:__drawlb__()

end


function LabelBox:__drawlb__()

    local opt = self.__lbopt

    local box = RoundRect(self.__wdt, self.__hgt,{
        strokeWidth=opt.borderwidth,
        strokeColor=opt.bordercolor,
    })
    box:empty():setAnchor(0,0):addTo(self)
    self.box = box
    
    self.label = Text1(self.__lbtxt):addTo(self):setY(-opt.labelymargin)

    return self

end


-- Group:clear()메서드를 오버라이드한다.
-- clear하더라도 label, box는 다시 그린다.
function LabelBox:clear()

    Group.clear(self)
    return self:__drawlb__()

end

function LabelBox:setlabel(str)

    print0(str)

    self.label:setstr(str)
    return self

end