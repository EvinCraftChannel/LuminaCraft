local leveldb = require('leveldb')

function loadWorld(path)
    local db = leveldb.open(path .. "/db")
    local levelDat = db:get("vlowlevel") 
    return db
end