function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

io.output("/dev/ttyUSB2")

serialin=io.open("/dev/ttyUSB2","r")
io.write("AT+QOPS=2,1\r\n")
arreglo_carrier = {}
arreglo_antenas = {}
indice_carrier = 0
indice_antenas = 0
carrier_actual = ""
arreglo_datos = {}
indice_renglones = 0
arreglo_renglones = {}

repeat
    local line=serialin:read()
    if string.len(line) > 0 and string.sub(line, 1, 6) == "+QOPS:" then
        a = string.gsub(line,'"','')
        a = string.gsub(a,' ','')
        a = string.gsub(a,'+QOPS:','')
        a = string.gsub(a,',',' ')
        for i in string.gmatch(a,"%S+") do
            arreglo_carrier[indice_carrier] = i
            indice_carrier = indice_carrier + 1
        end
        carrier_actual = arreglo_carrier[0]
        indice_carrier = 0
        arreglo_lineas = {}
        --print(line)
    elseif string.sub(line, 1, 2) == "OK" then  --OED is here the stream ending. This can vary
        --print(line)
        EOD = true
        serialin:flush()
        serialin:close()
        --line=serialin:read()
    elseif line then
        if string.len(line) > 0 and string.sub(line, 1, 8) ~= "AT+QOPS=" then
            --print(line)
            b = string.gsub(line,'"','')
            b = string.gsub(b,',',' ')
            
            for i in string.gmatch(b,"%S+") do
                arreglo_antenas[indice_antenas] = i
                indice_antenas = indice_antenas + 1
            end
            if arreglo_antenas[9] == nil then
                arreglo_renglones[indice_renglones] = "('863835020078510','" .. carrier_actual .. "','" .. arreglo_antenas[1] .. "','" .. arreglo_antenas[2] .. "','" .. arreglo_antenas[3] .. "','" .. arreglo_antenas[4] .. "','" .. arreglo_antenas[5] .. "','" .. arreglo_antenas[6] .. "','" .. arreglo_antenas[7] .. "','" .. arreglo_antenas[8] .. "','')"
            else
                arreglo_renglones[indice_renglones] = "('863835020078510','" .. carrier_actual .. "','" .. arreglo_antenas[1] .. "','" .. arreglo_antenas[2] .. "','" .. arreglo_antenas[3] .. "','" .. arreglo_antenas[4] .. "','" .. arreglo_antenas[5] .. "','" .. arreglo_antenas[6] .. "','" .. arreglo_antenas[7] .. "','" .. arreglo_antenas[8] .. "','" .. arreglo_antenas[9] .. "')"
            end
            indice_antenas = 0
            arreglo_antenas = {}
            indice_renglones = indice_renglones + 1
        end
    end
until EOD == true

luasql = require "luasql.postgres"
env = assert(luasql.postgres())
con = assert(env:connect('monitoreo', 'postgres', 'nestoram', "148.244.87.165"))

for i,line in ipairs(arreglo_renglones) do
    --print(line)
    query = "insert into antenas_startup (imei, carrier, campo_1, campo_2, campo_3, campo_4, campo_5, campo_6, campo_7, campo_8, campo_9) VALUES " .. line
    print("Iniciamos ejecucion de query")
    cur = assert(con:execute(query))

end

con:close()
env:close()

