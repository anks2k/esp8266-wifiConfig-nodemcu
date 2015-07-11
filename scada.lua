conn=net.createConnection(net.TCP, 0)
conn:connect(PORT_NUMBER,"YOUR_IP_ADDRESS_HERE")
conn:on("connection", function(conn) print("Successfully Reached Destination\n") end)
conn:on("receive", function(conn, payload)
    print(payload)
end)
-- Remove dofile("scada.lua") if you do not want recursive and successive connection
conn:on("disconnection", function(conn) print("DISCONN")  conn:close() dofile("scada.lua") end)

