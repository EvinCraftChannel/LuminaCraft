local fs = require('fs')
local PluginManager = { commands = {} }

function PluginManager.registerCommand(name, roleRequired, callback)
    PluginManager.commands[name] = {
        role = roleRequired,
        run = callback
    }
    print("Registered command: " .. name)
end

function PluginManager.loadAll(path)
    print("§e[Lumina] Loading plugins from " .. path .. "...")
    
    if not fs.existsSync(path) then
        fs.mkdirSync(path)
        return
    end

    local files = fs.readdirSync(path)
    for _, file in ipairs(files) do
        if file:match("%.lua$") then
            print("Loading plugin: " .. file)
            local pluginChunk, err = loadfile(path .. "/" .. file)
            if pluginChunk then
                local env = setmetatable({
                    registerCommand = PluginManager.registerCommand,
                    print = print
                }, { __index = _G })
                
                setfenv(pluginChunk, env)
                pluginChunk()
            else
                print("Error loading plugin " .. file .. ": " .. err)
            end
        end
    end
end

return PluginManager
