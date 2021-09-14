-- 2021/09/12: created

Labelbox = class(Group)

function Labelbox:init(labeltext,width,height,opt)

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


function Labelbox:__drawlb__()

    local opt = self.__lbopt

    local box = Rect(self.__wdt, self.__hgt,{strokewidth=opt.borderwidth, strokecolor=opt.bordercolor})
    box:empty():setanchor(0,0):addto(self)
    self.box = box
    
    self.label = Text1(self.__lbtxt):addto(self):sety(-opt.labelymargin)

    return self

end


-- Group:clear()메서드를 오버라이드한다.
-- clear하더라도 label, box는 다시 그린다.
function Labelbox:clear()

    Group.clear(self)
    return self:__drawlb__()

end

function Labelbox:setlabel(str)

    _print0(str)

    self.label:setstr(str)
    return self

end