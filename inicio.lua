io.output("/dev/ttyUSB2")

serialin=io.open("/dev/ttyUSB2","r")
io.write("AT\r\n")
lines = ""
contador = 0
repeat
    local line=serialin:read()
    if string.sub(line, 0, 2) == "OK" then  --OED is here the stream ending. This can vary
            EOD = true
            line=serialin:read()
            serialin:flush()
            serialin:close()
    elseif line then
            print(contador)
            contador = contador + 1
            lines = lines .. line .. '\n'
    end
until EOD == true
print (lines)

