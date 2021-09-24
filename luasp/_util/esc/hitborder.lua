--------------------------------------------------------------------------------
--2021/08/20:디버깅을 위해서 추가된 메서드
--------------------------------------------------------------------------------
local luasp = _luasopia
local esclayer = luasp.esclayer
local Disp = Display
--------------------------------------------------------------------------------

local function drawhitborder(self)
    
    for k = #self.__htbrdr,1,-1 do

        self.__htbrdr[k]:remove()
        self.__htbrdr[k]=nil

    end


    if self.__cpg then 
        
        local cpg = self.__cpg

        local x0, y0 = self:__getgxy__(cpg[1], cpg[2])

        local x1,y1, x2, y2 = x0,y0
        local len = #cpg

        for k=3,len+1,2 do

            -- print(k)
            if k==len+1 then
                x2, y2= x0,y0
            else
                x2, y2 = self:__getgxy__(cpg[k], cpg[k+1])
            end

            local ln=Line1(x1,y1,x2,y2,{color=self.__htblc, width = self.__htblw})
            esclayer:add(ln)

            x1,y1 = x2,y2
            tins(self.__htbrdr, ln)

        end
    
    elseif self.__ccc then

        local ccc = self.__ccc
        local gx, gy = self:__getgxy__(ccc.x,ccc.y)
        local dot = Rect(10,10,{fill=self.dbhlc})
        esclayer:add(dot)
        dot:xy(gx,gy)
        tins(self.__htbrdr, dot)

        local circ = Circle(ccc.r,{
            strokewidth = self.__htblw,
            strokecolor = self.__htblc
        }):empty()
        esclayer:add(circ)
        circ:xy(gx,gy)
        tins(self.__htbrdr, circ)

    elseif self.__cpt then

        local cpt = self.__cpt
        local gx, gy = self:__getgxy__(cpt.x, cpt.y)
        local dotr = self.__htblw*5
        local dot = Rect(10,10,{fill = self.dbhlc})
        esclayer:add(dot)
        dot:xy(gx,gy)
        tins(self.__htbrdr, dot)

    end

end



local init0 = Disp.init
local remove0 = Disp.remove

local function init1(self)
    
    init0(self) 
    self.__iupds[drawhitborder] = drawhitborder
    self.__htbrdr = {}

    return self

end


local function remove1(self)

    for k = #self.__htbrdr,1,-1 do
        self.__htbrdr[k]:remove()
    end

    remove0(self)

end


function luasp.showhitborder(color, width)

    Disp.__htblc = color or RED -- hit border line color
    Disp.__htblw = width or 3 -- hit border line width

    Disp.init = init1
    Disp.remove = remove1

end


function Disp:showhitborder(color,width)

    self.__htblc = color or RED
    self.__htblw = width or 2 -- hit line width

    self.__iupds[drawhitborder] = drawhitborder
    self.__htbrdr = {}

    self.remove = remove1

    return self

end