function file_check(file_name)
  local file_found=io.open(file_name, "r")

  if file_found==nil then
    file_found=0
  else
    file_found=1
  end
  return file_found
end
existe_archivo = file_check("/tmp/qccid.txt")

if existe_archivo == 1 then
    io.input("/tmp/qccid.txt")
    imei = io.read("*all")
    print(imei)
else
    io.output("/dev/ttyUSB2")

    serialin=io.open("/dev/ttyUSB2","r")
    io.write("AT+QCCID\r\n")
    lines = ""
    contador = 0

    repeat
        local line=serialin:read()
        if string.len(line) == 28 then
            fh = io.open("/tmp/qccid.txt","w")
            fh:write(line)
            fh:close()
            print(line)
        elseif string.sub(line, 1, 2) == "OK" then  --OED is here the stream ending. This can vary
            EOD = true
            --line=serialin:read()
            serialin:flush()
            serialin:close()
        elseif line then
            --print(contador)
            --contador = contador + 1
            --lines = lines .. line .. string.len(line) .. '\n'
        end
    until EOD == true
end
