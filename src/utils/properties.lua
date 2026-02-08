local ServerProps = {}

function ServerProps.load(filename)
    local config = {}
    
    local file = io.open(filename, "r")
    
    if not file then
        print("§c[Error] File " .. filename .. " not found! Using default settings.")
        return {
            ["server-name"] = "Lumina Server",
            ["port"] = 19132,
            ["gamemode"] = "survival"
        }
    end

    for line in file:lines() do
        local key, value = line:match("^(.-)=(.-)$")
        if key and value then
            key = key:gsub("%s+", "")
            value = value:gsub("^%s*(.-)%s*$", "%1")
            
            config[key] = value
        end
    end

    file:close()
    return config
end

return ServerProps