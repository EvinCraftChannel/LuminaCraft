local PluginManager = { commands = {} }

function PluginManager.registerCommand(name, roleRequired, callback)
    PluginManager.commands[name] = {
        role = roleRequired, -- "operator", "member", "visitor"
        run = callback
    }
end