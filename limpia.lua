serialin=io.open("/dev/ttyUSB2","r")

lines = ""
contador = 0
EOD = false

repeat
    local line=serialin:read("*line")
    print(line)
    if string.gsub(line, 1, 14) == "+QIND: PB DONE" then
        EOD = true
        print("SALIMOS")
        serialin:flush()
        serialin:close()
    else
        
    end
until EOD == true

