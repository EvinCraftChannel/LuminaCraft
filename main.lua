local uv = require('uv')
local ServerProps = require('./src/utils/properties')
local Network = require('./src/network/packet_handler')
local World = require('./src/world/leveldb_reader')
local PluginManager = require('./src/plugin/manager')
local PlayerManager = require('./src/player/manager')
local EntityManager = require('./src/entity/manager')
local EntityPhysics = require('./src/entity/physics')

local config = ServerProps.load("server.properties")

_G.Server = {
    broadcast = function(msg)
        print("[BROADCAST] " .. msg)
    end
}

PluginManager.loadAll("./plugins")

local server = uv.new_udp()
local port = tonumber(config["server-port"]) or 19132

World.init(2)

server:bind("0.0.0.0", port)
print("§a[Lumina] Server " .. config["server-name"] .. " running on port " .. port)

local tick_timer = uv.new_timer()
tick_timer:start(0, 50, function()
    for _, player in pairs(PlayerManager.getAll()) do
        player:update() 
    end
    
    for _, entity in pairs(EntityManager.getAll()) do
        EntityPhysics.update(entity, World)
    end
end)

server:recv_start(function(err, data, addr)
    if err then
        print("Network Error: " .. tostring(err))
        return
    end
    if data then
        Network.handle(data, addr, server, config)
    end
end)
