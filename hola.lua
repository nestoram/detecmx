#!/usr/bin/lua
function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

luasql = require "luasql.postgres"
env = assert(luasql.postgres())
con = assert(env:connect('monitoreo', 'postgres', 'nestoram', "148.244.87.165"))
-- retrieve a cursor
--cur = assert(con:execute('select username, password from login'))

--[[
/*****************************************************/
    REGION PARA OBTENER ESTADISTICAS DE PING
/*****************************************************/
--]]


print("Arrancamos PING")
local handle = io.popen("ping 8.8.8.8 -w 10 | grep statistics -A 3")
local result = handle:read("*a")
handle:close()
arreglo_lineas = {}
indice = 0
result = string.gsub(result,"/"," ")

for i in string.gmatch(result,"%S+") do
	arreglo_lineas[indice] = i
	indice = indice + 1
end
--print("Longitud arreglo PING = " .. table.getn(arreglo_lineas))
pck_enviados = arreglo_lineas[5]
pck_recibidos = arreglo_lineas[8]
pck_duplicados = "" --arreglo_lineas[11]
pck_perdidos = arreglo_lineas[11]
tmp_min = arreglo_lineas[19]
tmp_avg = arreglo_lineas[20]
tmp_max = arreglo_lineas[21]

--[[
/*****************************************************/
    REGION PARA OBTENER ESTADISTICAS DE TX / RX
/*****************************************************/
--]]
print("Arrancamos info tx")
handle = io.popen("ip -s link | grep 3g-wan -A 3 | tail -n +4")
result = handle:read("*a")
handle:close()

arreglo_tx = {}
arreglo_rx = {}

indice = 0
for i in string.gmatch(result, "%S+") do
    arreglo_tx[indice] = i
    indice = indice + 1
end
print("Arrancamos info rx")
handle = io.popen("ip -s link | grep 3g-wan -A 5 | tail -n +6")
result = handle:read("*a")
handle:close()

indice = 0
for i in string.gmatch(result, "%S+") do
    arreglo_rx[indice] = i
    indice = indice + 1
end
--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")
sleep(5)

--[[
/*****************************************************/
    REGION PARA OBTENER EL IMEI
/*****************************************************/
--]]
print("Arrancamos IMEI")
es_imei = false
imei = ""

while es_imei == false do
    handle = io.popen("lua serial.lua")
    result = handle:read("*a")
    handle:close()
   
    for i in string.gmatch(result, "%S+") do
        valor = string.match(result, '%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d')
        if valor ~= nil then
            es_imei = true
            imei = valor
        end
    end
end

sleep(5)
--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")
sleep(10)


--[[
/*****************************************************/
    REGION PARA OBTENER EL QCCID
/*****************************************************/
--]]

print("Arrancamos QCCID")
es_qccid = false
qccid = ""

while es_qccid == false do
    handle = io.popen("lua serial2.lua")
    result = handle:read("*a")
    handle:close()
    for i in string.gmatch(result, "%S+") do
        if string.len(result) == 29 then
            es_qccid = true
            qccid = result
        else
            print("Dormimos")
            sleep(5)
        end
    end
end
sleep(5)

--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")

sleep(10)

--[[
/*****************************************************/
    REGION PARA OBTENER EL CARRIER
/*****************************************************/
--]]

print("Arrancamos CARRIER")
es_carrier = false
carrier = ""

while es_carrier == false do
    handle = io.popen("lua serial3.lua")
    result = handle:read("*a")
    handle:close()
    
    if result == "" then
        print("Dormimos")
        sleep(5)
    else
        es_carrier = true
        carrier = result
    end
end
sleep(5)
--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")

sleep(10)
--[[
/*****************************************************/
    REGION PARA OBTENER EL APN
/*****************************************************/
--]]

print("Arrancamos APN")
es_apn = false
apn = ""

while es_apn == false do
    print("ANTES DE LLAMADA APN")
    handle = io.popen("lua serial4.lua")
    result = handle:read("*a")
    handle:close()
    print("DESPUES DE LLAMADA APN")

    if result == "" then
        print("Dormimos")
        sleep(5)
    else
        es_apn = true
        apn = result
    end
end
sleep(5)
--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")


sleep(10)
--[[
/***************************************_*************/
    REGION PARA OBTENER INTENSIDAD DE SENAL
/*****************************************************/
--]]

print("Arrancamos SIGNAL")
es_signal = false
signal = ""

while es_signal == false do
    handle = io.popen("lua serial5.lua")
    result = handle:read("*a")
    handle:close()

    if string.len(result) ~= 3 then
        print("Dormimos - " .. string.len(result))
        sleep(5)
    else
        es_signal = true
        signal = result
    end
end
sleep(5)
--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")

sleep(10)
--[[
/*****************************************************/
    REGION PARA OBTENER ANTENA Y TIPO DE CNX
/*****************************************************/
--]]
print("AT+CREG=2")
io.popen("lua serial6.lua")
sleep(2)

--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")


print("Arrancamos ANTENA")
es_cnx = false
cnx = ""
lac = ""
cid = ""
indice = 0
valores = {}

while es_cnx == false do
    handle = io.popen("lua serial7.lua")
    result = handle:read("*a")
    handle:close()

    print(result)

    if result == "" then
        print("Dormimos")
        sleep(5)
    else
        es_cnx = true
        for i in string.gmatch(result, "%S+") do
	    valores[indice] = i
	    indice = indice + 1
        end
        lac = valores[3]
        cid = valores[4]
        cnx = valores[5]
    end
end

sleep(5)
--[[
/**************/
  ENVIO DE AT
/**************/
--]]
print("AT")
io.popen("lua serial8.lua")
sleep(5)

print("Iniciamos Insert")
query1 = "INSERT INTO lecturas (fecha,hora,imei,sim,antena,intensidad,carrier,conexion,apn,modem_rx_bytes,modem_rx_packets,modem_rx_errors,modem_rx_dropped,modem_rx_overrun,modem_rx_mcast,modem_tx_bytes,"
query2 = "modem_tx_packets,modem_tx_errors,modem_tx_dropped,modem_tx_carrier,modem_tx_collsns,ping_packets_tx,ping_packets_rx,ping_packets_dp,ping_packets_ls,round_trip_min,round_trip_avg,round_trip_max) values "
query3 = "(NOW(), NOW(), '" .. imei .. "','" .. qccid  .. "','".. lac .. "|" .. cid  .."', '" .. signal  .."','" .. carrier  .. "','" .. cnx  .."','" .. apn  .."','" .. arreglo_rx[0] .. "','" .. arreglo_rx[1] .. "','"
query4 = arreglo_rx[2] .. "','" .. arreglo_rx[3] .. "','" .. arreglo_rx[4] .. "','" .. arreglo_rx[5] .. "','" .. arreglo_tx[0] .. "','" .. arreglo_tx[1] .. "','" .. arreglo_tx[2] .. "','"
query5 = arreglo_tx[3] .. "','" .. arreglo_tx[4] .. "','" .. arreglo_tx[5] .. "','" .. pck_enviados  .. "','" .. pck_recibidos .. "','" .. pck_duplicados  .. "','" .. pck_perdidos  .. "','" .. tmp_min  .. "','" .. tmp_avg  .. "','" .. tmp_max  .. "')"

--print(query1 .. query2 .. query3 .. query4 .. query5)

print("Iniciamos ejecucion de query")
cur = assert(con:execute(query1 .. query2 .. query3 ..query4..query5))
-- print all rows, the rows will be indexed by field names
--row = cur:fetch ({}, "a")
--while row do
--    print(string.format("username: %s, password: %s", row.username, row.password))
--    -- reusing the table of results
--    row = cur:fetch (row, "a")
-- end
-- close everything
-- cur:close()
con:close()
env:close()
