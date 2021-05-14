-------------------------------------------------------------------------------
-- 2021/05/13 created
-------------------------------------------------------------------------------
require 'luasopia.init'
-- require()함수는 root폴더를 기본으로 하는 것으로 위에서 치환되었다.
-- (original require 함수는는 _req로 변경됨)
-- The root folder is main/ directory. main/main.lua is firstly executed.
return require 'main' -- main/main.lua 파일로 점프(goto)