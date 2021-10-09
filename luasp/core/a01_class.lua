--------------------------------------------------------------------------------
-- magic methods : init(), remove()
--------------------------------------------------------------------------------
_luasopia.nilfunc = function() end
local nilfunc = _luasopia.nilfunc
local setmetatable = setmetatable
local getmetatable = getmetatable
--------------------------------------------------------------------------------

-- 모든 클래스의 부모클래스
local Object = {
	init = nilfunc, -- default constructor
	remove = nilfunc, -- default destructor
	__clsid = 0, -- 2021/09/21 added --0으로 고정시켜야 한다.
}

local clsid = 0


local function construct(cls, ...)

	--local obj = setmetatable({ __clsid = true }, { __index = cls })
	-- 2020/06/10: (2*) 때문에 아래와 같이 metatable을 cls로 설정 가능
	-- local obj = setmetatable({ __clsid = cls.__id__ }, cls) -- (*1)
	-- 2021/09/21: 개별객체의 __clsid 필드를 삭제하고 cls.__clsid를 참조하도록 함
	local obj = setmetatable({}, cls) -- (*1)
	cls.init(obj, ...)
	return obj

end


class = function(baseClass)

	local super = baseClass or Object
	clsid = clsid + 1 -- 생성되는 클래스마다 고유의 id를 갖게 한다.
	------------------------------------------------------------------------
	-- init=nilfunc 으로 지정해서 만약 사용자 생성자가 없어도
	-- super.init이 자동 실행되는 것을 막는다.
	-- 따라서 자식클래스는 **반드시 생성자를 만들어야 한다**
	-- 부모생성자를 호출하려면 자식생성자 안에서 baseClass.init(self,...) 라고 호출
	-- 단, remove 은 빈함수로 지정하지 않았으므로
	-- 자식의 소멸자가 없으면 **부모의 소멸자가 자동호출된다.**
	------------------------------------------------------------------------
	-- 2020/06/10 : cls.__index = cls 로 설정
	-- 이렇게 하면 (*1)에서 metatable을 cls로 지정할 수 있다.(성능에 조금 이득)
	-- 그리고 cls 에 직접 __add 와 같은 필드를 추가할 수 있다.
	------------------------------------------------------------------------
	local cls = {	
		init = nilfunc,
		__clsid = clsid, -- 클래스 고유번호, isObject()메서드에서 사용된다
	}
	cls.__index = cls --(*2) 이것으로 cls인지 obj인지를 type()함수에서 구별한다.

	return setmetatable(
		cls, -- cls ( construct()의 cls로 넘겨짐 )
		------------------------------------------------------------------------
		-- 아래는 cls의 메타테이블
		------------------------------------------------------------------------
		{
			__index = super, -- 상속구현
			__call = construct -- Classname(...) 과 같이 객체 생성
		}
	)

end


-- 2021/10/06: 객체를 생성하지 못하고 상속만 가능한 virtualClass 추가
-- virtualClass의 생성자. 에러를 발생시킨다.
local function banConstruct()
	error('Virtual class cannot make object.')
end


virtualClass = function(baseClass)

	local cls = class(baseClass)
	getmetatable(cls).__call = banConstruct
	return cls

end

--------------------------------------------------------------------------------
-- redefining type(), tostring(), and defining isObject() functions
--------------------------------------------------------------------------------

--2021/09/21: redefining type() global function
-- type(data) returns 'class' if data itself is a class
-- type(data) returns 'object' if data is an class instance
_type0 = type
local type0 = _type0
function type(data)
	
	local datatype = type0(data)
	
    if datatype =='table' and data.__clsid then
        if data.__index == data then
            return 'class' -- data is class itself
        else
            return 'object' -- data is an instance of a class
        end
    else
        return datatype
    end
	
end


-- 어떤 객체가 클래스의 객체인지를 판단하는 (전역)함수
-- 2020/09/30 : 부모클래스에 대해서도 true를 반환하도록 수정

function isObject(obj, cls)

	--return _type0(obj)=='table' and obj.__clsid == cls.__clsid

	if type(obj)=='object' and type(cls)=='class' then

		local objcls = obj
		repeat
			objcls = getmetatable(objcls).__index
			if objcls.__clsid == cls.__clsid then 
				return true
			end
		until objcls.__clsid == Object.__clsid -- __clsid of the Object
		return false

	else

		return false

	end

end


--2021/09/21: redefining tostring() global function
_tostring0 = tostring
local tostring0 = _tostring0
function tostring(data)

	local str = tostring0(data)
	local datatype = type(data)

	if datatype == 'class' then
		str = str:gsub('table','class') -- 두 개가 리턴된다. 첫 번째가 결과문자열
		return str						-- 따라서 return str:gsub(...)라고 하면 안된다
	elseif datatype == 'object' then
		str = str:gsub('table','object')
		return str
	else
		return str
	end

end