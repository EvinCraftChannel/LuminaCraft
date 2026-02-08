local ffi = require("ffi")

local libs = { "leveldb", "libleveldb.so", "libleveldb.so.1", "libleveldb.dylib" }
local ldb = nil

for _, name in ipairs(libs) do
    local status, lib = pcall(ffi.load, name)
    if status then
        ldb = lib
        print("§a[LevelDB] Library loaded: " .. name)
        break
    end
end

local use_db = (ldb ~= nil)

if use_db then
    ffi.cdef[[
        typedef struct leveldb_t leveldb_t;
        typedef struct leveldb_options_t leveldb_options_t;
        typedef struct leveldb_readoptions_t leveldb_readoptions_t;
        typedef struct leveldb_writeoptions_t leveldb_writeoptions_t;
        typedef struct leveldb_iterator_t leveldb_iterator_t;

        leveldb_options_t* leveldb_options_create();
        void leveldb_options_set_create_if_missing(leveldb_options_t*, unsigned char);
        void leveldb_options_destroy(leveldb_options_t*);

        leveldb_writeoptions_t* leveldb_writeoptions_create();
        void leveldb_writeoptions_destroy(leveldb_writeoptions_t*);

        leveldb_readoptions_t* leveldb_readoptions_create();
        void leveldb_readoptions_destroy(leveldb_readoptions_t*);

        leveldb_t* leveldb_open(const leveldb_options_t* options, const char* name, char** errptr);
        void leveldb_close(leveldb_t* db);
        
        void leveldb_put(leveldb_t* db, const leveldb_writeoptions_t* options, const char* key, size_t keylen, const char* val, size_t vallen, char** errptr);
        char* leveldb_get(leveldb_t* db, const leveldb_readoptions_t* options, const char* key, size_t keylen, size_t* vallen, char** errptr);
        
        void leveldb_free(void* ptr);
    ]]
end

local World = {}
local db_ptr = nil
local read_opts = nil
local write_opts = nil
local memory_store = {}

-- Helper untuk membuka DB
local function openDB(path)
    if not use_db then return end
    
    local options = ldb.leveldb_options_create()
    ldb.leveldb_options_set_create_if_missing(options, 1)
    
    local err_ptr = ffi.new("char*[1]")
    db_ptr = ldb.leveldb_open(options, path, err_ptr)
    
    if err_ptr[0] ~= nil then
        local err_msg = ffi.string(err_ptr[0])
        ldb.leveldb_free(err_ptr[0])
        print("§c[LevelDB] Error opening DB: " .. err_msg)
        use_db = false
    else
        read_opts = ldb.leveldb_readoptions_create()
        write_opts = ldb.leveldb_writeoptions_create()
        print("§a[LevelDB] Database opened successfully at " .. path)
    end
    
    ldb.leveldb_options_destroy(options)
end

function World.init(radius)
    os.execute("mkdir -p worlds/BedrockLevel/db")
    openDB("worlds/BedrockLevel/db")

    print("§e[Lumina] Initialization World...")
    
    local totalChunks = (radius * 2 + 1) ^ 2
    local count = 0

    for x = -radius, radius do
        for z = -radius, radius do
            local data = World.loadChunk(x, z)
            if not data then
                data = World.generateNewChunk(x, z)
                World.saveChunk(x, z, data)
            end
            
            count = count + 1
            
            if count % 5 == 0 then
                local percent = math.floor((count / totalChunks) * 100)
                local barLength = 20
                local filled = math.floor((percent / 100) * barLength)
                local bar = string.rep("█", filled) .. string.rep("░", barLength - filled)
                io.write(string.format("\r§b[World] Building: [%s] %d%% (%d/%d)", bar, percent, count, totalChunks))
                io.flush()
            end
        end
    end
    print("\n§a[World] Loaded " .. count .. " chunks.")
end

function World.generateNewChunk(x, z)
    return "CHUNK_DATA_V1_" .. x .. "_" .. z
end

function World.saveChunk(x, z, data)
    local key = string.pack("<iiB", x, z, 47)
    
    if use_db and db_ptr then
        local err_ptr = ffi.new("char*[1]")
        ldb.leveldb_put(db_ptr, write_opts, key, #key, data, #data, err_ptr)
        
        if err_ptr[0] ~= nil then
            local err = ffi.string(err_ptr[0])
            ldb.leveldb_free(err_ptr[0])
            print("§cError saving chunk: " .. err)
        end
    else
        memory_store[key] = data
    end
end

function World.loadChunk(x, z)
    local key = string.pack("<iiB", x, z, 47)
    
    if use_db and db_ptr then
        local vallen = ffi.new("size_t[1]")
        local err_ptr = ffi.new("char*[1]")
        
        local val = ldb.leveldb_get(db_ptr, read_opts, key, #key, vallen, err_ptr)
        
        if err_ptr[0] ~= nil then
            ldb.leveldb_free(err_ptr[0])
            return nil
        end
        
        if val ~= nil then
            local lua_str = ffi.string(val, vallen[0])
            ldb.leveldb_free(val)
            return lua_str
        end
        return nil
    else
        return memory_store[key]
    end
end

function World.close()
    if use_db and db_ptr then
        ldb.leveldb_readoptions_destroy(read_opts)
        ldb.leveldb_writeoptions_destroy(write_opts)
        ldb.leveldb_close(db_ptr)
        print("§e[LevelDB] Database closed.")
    end
end

return World
