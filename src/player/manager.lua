local Inventory = require('./inventory')

local PlayerManager = {
    players = {}
}

local Player = {}
Player.__index = Player

function Player.new(id, username, addr, role)
    local self = setmetatable({}, Player)
    self.id = id
    self.username = username
    self.addr = addr
    self.role = role or "member"
    self.x, self.y, self.z = 0, 100, 0
    self.inventory = Inventory.new(36)
    self.health = 20
    return self
end

function Player:sendMessage(message)
    print("[CHAT -> " .. self.username .. "]: " .. message)
end

function Player:update()
    if self.y < -10 then
        self.x, self.y, self.z = 0, 100, 0
    end
end
function Player:openContainer(containerBlock)
    for slot, item in pairs(containerBlock.items) do
        self:sendInventorySlot(slot, item)
    end
end
function PlayerManager.addPlayer(guid, username, addr)
    local newPlayer = Player.new(guid, username, addr)
    PlayerManager.players[guid] = newPlayer
    print("§a[Server] " .. username .. " Joined the game!")
    return newPlayer
end

function PlayerManager.removePlayer(guid)
    local p = PlayerManager.players[guid]
    if p then
        print("§e[Lumina] " .. p.username .. " keluar.")
        PlayerManager.players[guid] = nil
    end
end

function PlayerManager.getPlayer(guid)
    return PlayerManager.players[guid]
end

function PlayerManager.getAll()
    return PlayerManager.players
end

return PlayerManager