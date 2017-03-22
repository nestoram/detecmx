#!/usr/bin/lua
function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

luasql = require "luasql.postgres"
env = assert(luasql.postgres())
con = assert(env:connect('monitoreo', 'postgres', 'nestoram', "148.244.87.165"))

--[[
/*****************************************************/
    REGION PARA OBTENER DATOS DE ANTENAS
/*****************************************************/
--]]

print("Arrancamos AT+QOPS=2,1")
local handle = io.popen("lua serial9.lua")

sleep(70)

local result = handle:read("*a")
handle:close()
arreglo_lineas = {}
indice = 0
print(result)
for i in string.gmatch(result,"%S+") do
    arreglo_lineas[indice] = i
    print(arreglo_lineas[0])
    indice = indice + 1
    if indice == 9 then
        query = "insert into antenas_startup (imei, carrier, campo_1, campo_2, campo_3, campo_4, campo_5, campo_6, campo_7, campo_8) "
        query_2 = " VALUES ('863835020078510','".. arreglo_lineas[0] .."','".. arreglo_lineas[1] .."','".. arreglo_lineas[2] .."',"
        query_3 = "'" .. arreglo_lineas[3] .. "','" .. arreglo_lineas[4] .. "','".. arreglo_lineas[5] .."','".. arreglo_lineas[6] .."',"
        query_4 = "'" .. arreglo_lineas[7] .. "','" .. arreglo_lineas[8] .. "')"
        print("Iniciamos ejecucion de query")
        cur = assert(con:execute(query .. query_2 .. query_3 .. query_4))
        indice = 0
    end
end

con:close()
env:close()
