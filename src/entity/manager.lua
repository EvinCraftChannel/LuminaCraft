local EntityManager = {
    entities = {}
}

function EntityManager.addEntity(entity)
    EntityManager.entities[entity.id] = entity
end

function EntityManager.removeEntity(id)
    EntityManager.entities[id] = nil
end

function EntityManager.getAll()
    return EntityManager.entities
end

return EntityManager