io.output("/dev/ttyUSB2")

serialin=io.open("/dev/ttyUSB2","r")
io.write("AT+QCCID\r\n")
qcc = ""
contador = 0
repeat
    local linea=serialin:read()
    if string.len(linea) == 28 then
            print(linea)
    elseif string.sub(linea, 0, 2) == "OK" then  --OED is here the stream ending. This can vary
            EOD = true
            line=serialin:read()
            serialin:flush()
            serialin:close()
    elseif linea then
            contador = contador + 1
            qcc = qcc .. linea .. '\n'
    end
until EOD == true
