function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

io.output("/dev/ttyUSB2")

serialin=io.open("/dev/ttyUSB2","r")
io.write("AT+CGDCONT?\r\n")
sleep(10)
qcc = ""
valores = {}
contador = 0
repeat
    local linea=serialin:read()
    if string.sub(linea, 1, 9) == "+CGDCONT:" then
            for word in linea:gmatch('%"(.-)%"') do
                valores[contador] = word
                contador = contador + 1
            end
            print(valores[1])
    elseif string.sub(linea, 0, 2) == "OK" then  --OED is here the stream ending. This can vary
            EOD = true
            serialin:flush()
            serialin:close()
    elseif linea then
            --print(contador)
            --contador = contador + 1
            qcc = qcc .. linea .. '\n'
    end
until EOD == true
--print (qcc)

