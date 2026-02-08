local EntityPhysics = {}

function EntityPhysics.update(entity, world)
    if not entity then return end
    
    EntityPhysics.checkCollision(entity, world)

    if not entity.onGround then
        entity.motionY = (entity.motionY or 0) - 0.08
    end
    
    entity.motionX = entity.motionX or 0
    entity.motionY = entity.motionY or 0
    entity.motionZ = entity.motionZ or 0
    
    entity.x = entity.x + entity.motionX
    entity.y = entity.y + entity.motionY
    entity.z = entity.z + entity.motionZ
    
    entity.motionX = entity.motionX * 0.9
    entity.motionZ = entity.motionZ * 0.9
end

function EntityPhysics.checkCollision(entity, world)
    if entity.y < 0 then
        entity.onGround = true
        entity.motionY = 0
        entity.y = 0
    else
        entity.onGround = false
    end
end

return EntityPhysics
