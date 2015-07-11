wifi.setmode(wifi.STATION)
apCfg={}
staCfg={}
function urldecode(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
    str = string.gsub(str, "\r\n", "\n")
    return str
end
function writeap()
    file.remove("beacon.lua")
    file.open("beacon.lua","w+")
    function listap(t)
        for k in pairs(t) do
            file.writeline(k.."<input type=\"radio\" name='SSID' value=\""..k.."\"> <br /> ")
        end
        collectgarbage()
        file.writeline("<input type='text' name='Password' maxlength='100' /><br><br>")
        file.writeline("<input type='text' name='connid' maxlength='100' placeholder='Connection ID' />")
    end
    wifi.sta.getap(listap)
end
tmr.alarm(0,500,0,writeap)
apCfg.ssid="ESPConfigTool"
apCfg.pwd="espConfigTool"
wifi.setmode(wifi.STATIONAP)
wifi.ap.config(apCfg)
file.close()
server=net.createServer(net.TCP)
server:listen(80,function(ap)
    ap:on("receive", function(ap, payload)
        ssid_start,ssid_end=string.find(payload,"SSID=")
        if ssid_start and ssid_end then
            amper1_start, amper1_end =string.find(payload,"&", ssid_end+1)
            if amper1_start and amper1_end then
                amper_start, amper_end =string.find(payload,"&", amper1_end+1)
                if amper_end and amper_start then
                    http_start, http_end =string.find(payload,"HTTP/1.1", amper_end+1)
                    if http_start and http_end then
                        staCfg.ssid=urldecode(string.sub(payload,ssid_end+1, amper1_start-1))
                        staCfg.pwd=urldecode(string.sub(payload,amper1_end+10, amper_start-1))
                        staCfg.connid=urldecode(string.sub(payload,amper_end+8, http_start-2))
                        if staCfg.ssid and staCfg.pwd then
                            wifi.sta.config(staCfg.ssid,staCfg.pwd)
                            file.open("config.lua","w+")
                            file.writeline('config={}')
                            file.writeline('config.ssid=\"'.. staCfg.ssid .. '\"')
                            file.writeline('config.pwd=\"' .. staCfg.pwd .. '\"')
                            file.writeline('config.connid=\"' .. staCfg.connid .. '\"')
                            file.close();
                            server:close()
                            file.remove("beacon.lua")
                            wifi.setmode(wifi.STATION)
                            --print("RESTARTNODE")
                        end
                    end
                end
            end
        end
        tmr.delay(1000000)
        if file.open("beacon.lua","r") then
            ap:send("<!DOCTYPE html> ")
            ap:send("<html lang='en'> ")
            ap:send("<body> ")
            ap:send("<h1>ESP8266 Wireless control setup</h1> ")
            ap:send("<form method='GET' action=\"#\">")
            ap:send("SSID:")
            ap:send(file.read())
            ap:send("<br />")
            ap:send("Password:")
            ap:send("<input type='submit' value='Submit' />")
            collectgarbage()
        end
        file.close()
    end)
end)
