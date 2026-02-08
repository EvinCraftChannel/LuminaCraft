local PlayerManager = require('../player/manager')
local LoginHandler = require('./login_handler')
local TextHandler = require('./text_handler')
local BinaryStream = require('./binary_stream')

local Network = {}

function Network.sendPong(addr, server, config)
    local motd = table.concat({
        "MCPE",
        config["motd"] or "LuminaServer",
        "775",
        "1.21.132",
        tostring(#PlayerManager.getAll()),
        config["max-players"] or "20",
        "1234567890",
        config["server-name"] or "Lumina",
        config["gamemode"] or "Survival",
        "1",
        config["server-port"] or "19132"
    }, ";")

    local packet = string.char(0x1c) 
    packet = packet .. string.pack(">j", os.time()) 
    packet = packet .. string.pack(">j", 1234567890) 
    packet = packet .. "\x00\xff\xff\x00\xfe\xfe\xfe\xfe\xfd\xfd\xfd\xfd\x12\x34\x56\x78"
    packet = packet .. string.pack(">s2", motd)

    server:send(packet, addr)
end

function Network.handle(data, addr, server, config)
    local stream = BinaryStream.new(data)
    local packetID = string.byte(data, 1)

    if packetID == 0x01 then
        return Network.sendPong(addr, server, config)
    end

    if packetID == 0xfe then
        local payload = data:sub(2) 
        local innerID = string.byte(payload, 1)

        if innerID == 0x01 then
            local info = LoginHandler.parse(payload)
            if info then
                local player = PlayerManager.addPlayer(addr, info.username, addr)
                
                if info.username == "GGgamingMCPE489" then
                    player.role = "operator"
                    print("§b[Lumina] Operator " .. info.username .. " joined.")
                else
                    player.role = "member"
                end
                
            end
        end

        if innerID == 0x05 then
            PlayerManager.removePlayer(addr)
        end

        if innerID == 0x09 then
            TextHandler.handle(payload, addr)
        end
    end
end

return Network