local PlayerManager = require('../player/manager')
local LoginHandler = require('./login_handler')
local TextHandler = require('./text_handler')
local BinaryStream = require('./binary_stream')

local Network = {}

local RAKNET_MAGIC = "\x00\xff\xff\x00\xfe\xfe\xfe\xfe\xfd\xfd\xfd\xfd\x12\x34\x56\x78"

function Network.sendPong(addr, server, config)
    local playerCount = 0
    for _ in pairs(PlayerManager.getAll()) do playerCount = playerCount + 1 end

    local motdParts = {
        "MCPE",
        config["motd"] or "LuminaServer",     -- Line 1
        "775",                                -- Protocol (1.21.132)
        "1.21.132",                           -- Version
        tostring(playerCount),                -- Online
        config["max-players"] or "20",        -- Max
        "1234567890",                         -- Server GUID (Random)
        config["server-name"] or "Lumina",    -- Line 2
        config["gamemode"] or "Survival",     -- Gamemode
        "1",                                  -- Nintendo status
        config["server-port"] or "19132"      -- Port
    }
    local motd = table.concat(motdParts, ";")

    local packet = string.char(0x1c) 
    packet = packet .. string.pack(">j", os.time())
    packet = packet .. string.pack(">j", 1234567890)
    packet = packet .. RAKNET_MAGIC
    packet = packet .. string.pack(">s2", motd)

    server:send(packet, addr)
end

function Network.handle(data, addr, server, config)
    if not data or #data == 0 then return end
    
    local packetID = string.byte(data, 1)

    if packetID == 0x01 or packetID == 0x02 then
        return Network.sendPong(addr, server, config)
    end

    if packetID == 0xfe then
        local status, err = pcall(function()
            local payload = data:sub(2) 
            if #payload == 0 then return end
            
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
        end)

        if not status then
            print("§c[Network] Error handling 0xfe: " .. tostring(err))
        end
    end
    
end

return Network
