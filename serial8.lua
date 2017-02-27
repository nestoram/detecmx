function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

io.output("/dev/ttyUSB2")

serialin=io.open("/dev/ttyUSB2","r")

io.write("AT\r\n")
sleep(5)
qcc = ""
valores = {}
indice = 0
repeat
    local linea=serialin:read()
    --print(linea)
    if string.sub(linea, 0, 2) == "OK" then  --OED is here the stream ending. This can vary
            EOD = true
            serialin:flush()
            serialin:close()
            print(linea)
    elseif linea then
            --print(contador)
            --contador = contador + 1
            qcc = qcc .. linea .. '\n'
    end
until EOD == true

