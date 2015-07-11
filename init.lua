wifiTrys   = 0
NWIFITRYS  = 10
function checkWifi()
    ip = wifi.sta.getip()
    if ( ip ~= nil )then
        tmr.stop(1)
        print(ip)
        dofile("scada.lua")
    else
        wifiTrys = wifiTrys + 1
    end
    if( wifiTrys > NWIFITRYS ) then
        dofile("pilot.lua")
        --print("Wrong SSID/PWD")
        tmr.stop(1)
    end
end


if not file.open("config.lua","r") then
    dofile("pilot.lua")
else
    wifi.setmode(wifi.STATION)
    dofile("config.lua")
    wifi.sta.config(config.ssid,config.pwd)
    tmr.alarm(1,2500,1,checkWifi)
end
