function file_check(file_name)
  local file_found=io.open(file_name, "r")      

  if file_found==nil then
    file_found=file_name .. " ... Error - File Not Found"
  else
    file_found=file_name .. " ... File Found"
  end
  return file_found
end

io.output("/dev/ttyUSB2")

serialin=io.open("/dev/ttyUSB2","r")
io.write("AT+GSN\r\n")
lines = ""
contador = 0

--print(file_check('/tmp/imei.txt'))

repeat
    local line=serialin:read()
    if string.len(line) == 15 then
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

--print (lines)
