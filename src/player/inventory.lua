local Inventory = {}

function Inventory.new(size)
    local inv = { slots = {} }
    for i = 0, size - 1 do inv.slots[i] = {id = 0, count = 0} end
    return inv
end

function Inventory:setItem(slot, itemID, count)
    self.slots[slot] = {id = itemID, count = count}
end

function openChest(player, x, y, z)
end