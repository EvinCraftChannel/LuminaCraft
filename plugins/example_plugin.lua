registerCommand("heal", function(player, args)
    player.health = 20
    player:sendMessage("You have been healed!")
end)

function loadPlugins()
    local files = scandir("./plugins")
    for _, file in ipairs(files) do
        local plugin = loadfile("./plugins/" .. file)
        plugin() -- Menjalankan script plugin
    end
end