local EntityPhysics = {}

function EntityPhysics.update(entity, world)
    EntityPhysics.checkCollision(entity, world)

    if not entity.onGround then
        entity.motionY = entity.motionY - 0.08
    end
    
    entity.x = entity.x + entity.motionX
    entity.y = entity.y + entity.motionY
    entity.z = entity.z + entity.motionZ
    
    entity.motionX = entity.motionX * 0.9
    entity.motionZ = entity.motionZ * 0.9
end

function EntityPhysics.checkCollision(entity, world)
    local block = world.getBlock(math.floor(entity.x), math.floor(entity.y - 0.1), math.floor(entity.z))
    
    if block ~= 0 then
        entity.onGround = true
        entity.motionY = 0
        entity.y = math.floor(entity.y) 
    else
        entity.onGround = false
    end
end

function EntityPhysics.handleMovement(entity, newX, newY, newZ)
    local dist = math.sqrt((newX - entity.x)^2 + (newZ - entity.z)^2)
    
    if dist > 10 then 
        return entity:teleport(entity.x, entity.y, entity.z)
    end

    entity.x, entity.y, entity.z = newX, newY, newZ
    
    if Server and Server.broadcast then
        Server.broadcast("MoveEntityPacket", {id = entity.id, x = newX, y = newY, z = newZ})
    end
end

return EntityPhysics