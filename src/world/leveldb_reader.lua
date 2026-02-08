local ffi = require("ffi")

local ldb = ffi.load("leveldb")

ffi.cdef[[
    typedef struct leveldb_t leveldb_t;
    typedef struct leveldb_options_t leveldb_options_t;
    typedef struct leveldb_writeoptions_t leveldb_writeoptions_t;
    
    leveldb_t* leveldb_open(const leveldb_options_t* options, const char* name, char** errptr);
    void leveldb_put(leveldb_t* db, const leveldb_writeoptions_t* options, const char* key, size_t keylen, const char* val, size_t vallen, char** errptr);
    char* leveldb_get(leveldb_t* db, const leveldb_options_t* options, const char* key, size_t keylen, size_t* vallen, char** errptr);
]]

local World = {}
local db_ptr = nil

function World.generateNewChunk(x, z)
    local dummyData = "CHUNK_DATA_V1_" .. x .. "_" .. z
    
    local key = string.pack("<iiB", x, z, 0) .. "v"
    
    return dummyData
end

function World.init(radius)
    print("§e[Lumina] Initialization Database World...")
    
    local totalChunks = (radius * 2 + 1) ^ 2
    local count = 0

    for x = -radius, radius do
        for z = -radius, radius do
            World.loadChunk(x, z)
            
            count = count + 1
            
            local percent = math.floor((count / totalChunks) * 100)
            local barLength = 20
            local filled = math.floor((percent / 100) * barLength)
            local bar = string.rep("█", filled) .. string.rep("░", barLength - filled)
            
            io.write(string.format("\r§b[World] Building: [%s] %d%% (%d/%d)", bar, percent, count, totalChunks))
            io.flush()
        end
    end
    print("\n§a[World] Loaded" .. count .. " chunk")
end

function World.loadChunk(x, z)
    local key = string.pack("<iiB", x, z, 0) .. "v"
    
    local chunkData = nil
    
    if chunkData then
        return chunkData
    else
        return World.generateNewChunk(x, z)
    end
end

return World