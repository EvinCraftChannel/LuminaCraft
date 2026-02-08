function handleChat(player, message)
    if string.sub(message, 1, 1) == "/" then
        local cmdName = string.sub(message, 2)
        local command = PluginManager.commands[cmdName]
        if command then
            if player.role == command.role or player.role == "operator" then
                command.run(player)
            else
                player:sendMessage("§cYou don't have permission!")
            end
        end
        return
    end
    Server.broadcast("§7" .. player.username .. ": " .. message)
end