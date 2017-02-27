function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

io.output("/dev/ttyUSB2")

serialin=io.open("/dev/ttyUSB2","r")
io.write("AT+COPS?\r\n")
sleep(10)
qcc = ""
contador = 0
repeat
    local linea=serialin:read()
    if linea == nil then
            EOD = true
            serialin:close()
    elseif string.sub(linea, 1, 6) == "+COPS:" then
            word=linea:match('%"(.-)%"')
            print(word)
    elseif string.sub(linea, 1, 2) == "OK" then  --OED is here the stream ending. This can vary
            EOD = true
            serialin:flush()
            serialin:close()
            --print("Linea OK")
    elseif linea then
            --print(contador)
            --contador = contador + 1
            qcc = qcc .. linea .. '\n'
            --print("otro tipo de linea")
    end
until EOD == true
--print (qcc)
