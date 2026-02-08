function updateEntityMovement(entity)
    entity.x = entity.x + entity.motionX
    entity.z = entity.z + entity.motionZ

    broadcastPacket(createMovePacket(entity))
end