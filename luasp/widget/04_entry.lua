--------------------------------------------------------------------------------
--2021/08/21:created. CAPSLOCK은 항상 꺼져있다고 인식함
--2021/08/22:Text1클래스를 사용. 앵커점은 (0,1)좌하점이다.
--------------------------------------------------------------------------------
local fontsize0= 45
local blinktm = 1000
--------------------------------------------------------------------------------

local Disp = Display
local Group = Group

local shift = {
    ['space']={' ', ' '},
    ['a']={'a', 'A'}, ['b']={'b', 'B'}, ['c']={'c', 'C'}, ['d']={'d', 'D'},
    ['e']={'e', 'E'}, ['f']={'f', 'F'}, ['g']={'g', 'G'}, ['h']={'h', 'H'},
    ['i']={'i', 'I'}, ['j']={'j', 'J'}, ['k']={'k', 'K'}, ['l']={'l', 'L'},
    ['m']={'m', 'M'}, ['n']={'n', 'N'}, ['o']={'o', 'O'}, ['p']={'p', 'P'},
    ['q']={'q', 'Q'}, ['r']={'r', 'R'}, ['r']={'r', 'R'}, ['s']={'s', 'S'},
    ['t']={'t', 'T'}, ['u']={'u', 'U'}, ['v']={'v', 'V'}, ['w']={'w', 'W'},
    ['x']={'x', 'X'}, ['y']={'y', 'Y'}, ['z']={'z', 'Z'},
    ['`']={'`', '~'}, ['-']={'-', '_'}, ['=']={'=', '+'},
    ['1']={'1', '!'}, ['2']={'2', '@'}, ['3']={'3', '#'}, ['4']={'4', '$'},
    ['5']={'5', '%'}, ['6']={'6', '^'}, ['7']={'7', '&'}, ['8']={'8', '*'},
    ['9']={'9', '('}, ['0']={'0', ')'},
    [';']={';', ':'}, ["'"]={"'", '"'}, [',']={',', '<'}, ['.']={'.', '>'},
    ['/']={'/', '?'}, ['[']={'[', '{'}, [']']={']', '}'},
    ['\\']={'\\','|'},
} 

local undershift = 1

-- local yoffs1, yoffs2 = 0, 0
-- if _Gideros then yoffs1, yoffs2=7,14 end
-- print(yoffs)
--------------------------------------------------------------------------------
Entry = class(Group)
--------------------------------------------------------------------------------

local entry
local function onkey(_, key, phase) -- 첫번째 인자는 screen
    if phase == 'up' then
        if key == 'shift' then
            undershift = 1
        end

    
    else

        -- print(key)
        if key == 'right' then
            entry:__setcaretx__(entry.__caretx+1)
        elseif key == 'left' then
            entry:__setcaretx__(entry.__caretx-1)
        elseif key == 'back' then
            entry:__delback__()
        elseif key == 'del' then
            entry:__del__()

        elseif key == 'shift' then
            undershift = 2

        elseif key=='enter' then

            entry.__entered = true
            if entry.__onenter then
                entry.__onenter(entry)
            end

        elseif key=='home' then

            entry:__setcaretx__(1)

        elseif key=='end' then

            entry:__setcaretx__(entry.__endx)

        else

            local keyshifted = shift[key]
            if keyshifted then 
                entry:__inschar__(keyshifted[undershift])
            end
        
        end

    end

end

--------------------------------------------------------------------------------
-- opt = {fontsize, header, borderwidth, bordercolor, soundeffect,}
--------------------------------------------------------------------------------
local nilfunc = function() end

function Entry:init(header, onenter, opt)

    Group.init(self)

    -- header = header or ''
    self.__onenter = onenter or nilfunc
    opt = opt or {}


    entry = self
    screen.onkey = onkey

    self.__fsz = fontsize or fontsize0
    self.__chgap = self.__fsz*0.555 -- 문자간격

    -- print(self.__chgap) -- charecter gap
    
    if header then
        self.__txthdr = Text1(header,{fontsize=self.__fsz}):addto(self)
        self.__hdr=header
    else
        self.__hdr=''
    end
    
    -- __entry는 text와 caret이 들어가는 그룹
    self.__entry = Group():addto(self):setx(#self.__hdr*self.__chgap)
    
    self.__txtin = Text1('',{fontsize=self.__fsz}):addto(self.__entry)
    
    self.__caret = Rect(4,self.__fsz):addto(self.__entry) -- 먼저 add()해야 한다.
    self.__caret:setanchor(0,0.75):blink(blinktm)
    self.__endx = 1 -- caret의 맨 우측값
    self:__setcaretx__(1) -- caretx의 가장 작은 값은 1이다.
    self.__shift = 1

    return self

end


function Entry:__inschar__(char)

    local text = self.__txtin:getstring()
    local len = text:len()
    local x = self.__caretx

    local left = text:sub(1,x-1)
    local right = text:sub(x,len)
    -- print(string.format("'%s','%s','%s'", text, left, right))
    self.__txtin:setstr(left..char..right)

    self:__setcaretx__(x+1, true)

end


function Entry:__delback__()

    local x = self.__caretx
    if x==1 then return end
    

    local text = self.__txtin:getstring()
    local len = text:len()

    local left = text:sub(1,x-2)
    local right = text:sub(x,len)
    -- print(string.format("'%s','%s','%s'", text, left, right))
    self.__txtin:setstr(left..right)

    self:__setcaretx__(x-1)
    self.__endx = self.__endx-1

end


function Entry:__del__()

    local x = self.__caretx
    if x==self.__endx then return end
    

    local text = self.__txtin:getstring()
    local len = text:len()

    local left = text:sub(1,x-1)
    local right = text:sub(x+1,len)
    -- print(string.format("'%s','%s','%s'", text, left, right))
    self.__txtin:setstr(left..right)

    self.__endx = self.__endx-1
    self.__caret:blink(blinktm)

end




function Entry:__setcaretx__(x, inc_endx)
    
    if x<1 then
        x=1
    end

    if inc_endx then -- caret의 우측최대값을 x값으로 변경(증가)
        self.__endx = x
    end

    if x>self.__endx then
        x=self.__endx
    end

    self.__caretx = x
    self.__caret:setx((x-1)*self.__chgap)
    self.__caret:blink(blinktm)

end


function Entry:getstring()

    return self.__txtin:getstring()

end