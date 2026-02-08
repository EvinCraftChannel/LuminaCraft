function handleChat(player, message)
    if string.sub(message, 1, 1) == "/" then
        local args = {}
        for word in string.gmatch(message, "%S+") do
            table.insert(args, word)
        end

        local cmdRaw = table.remove(args, 1)
        local cmdName = string.sub(cmdRaw, 2):lower() -- jadikan lowercase agar tidak case-sensitive

        local command = PluginManager.commands[cmdName]
        
        if command then
            if player.role == "operator" or player.role == command.role then
                local success, err = pcall(function()
                    command.run(player, args)
                end)
                
                if not success then
                    print("§c[Error] Command " .. cmdName .. ": " .. tostring(err))
                    player:sendMessage("§cAn internal error occurred while executing this command.")
                end
            else
                player:sendMessage("§cYou don't have permission to use this command!")
            end
        else
            player:sendMessage("§cUnknown command: /" .. cmdName)
        end
        return
    end

    if _G.Server and _G.Server.broadcast then
        _G.Server.broadcast("§7" .. player.username .. ": " .. message)
    else
        print("§7[Chat] " .. player.username .. ": " .. message)
    end
end
