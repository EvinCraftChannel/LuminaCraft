local uv = require('uv')
local ServerProps = require('./src/utils/properties')
local Network = require('./src/network/packet_handler')
local World = require('./src/world/leveldb_reader')
local CustomItemManager = require('./src/item/custom_item_manager')
local PluginManager = require('./src/plugin/manager')
local PlayerManager = require('./src/player/manager')
local config = ServerProps.load("server.properties")
PluginManager.loadAll("./plugins")
local server = uv.new_udp()
World.init(4)
server:bind("0.0.0.0", config.port or 19132)
local tick_timer = uv.new_timer()
tick_timer:start(0, 50, function()
    for _, player in pairs(PlayerManager.getAll()) do
        player:update() 
    end
    
    for _, entity in pairs(EntityManager.getAll()) do
        EntityPhysics.update(entity)
    end
end)

server:recv_start(function(err, data, addr)
    if data then
        Network.handle(data, addr, server, config)
    end
end)

print("§a[Lumina] Server " .. config["server-name"] .. " running on port " .. config.port)