local CustomItemManager = { items = {} }

function CustomItemManager.registerItem(id_name, numeric_id, params)
    CustomItemManager.items[id_name] = {
        id = numeric_id,
        name = id_name,
        component = {
            ["minecraft:icon"] = params.icon,
            ["minecraft:display_name"] = params.display_name,
            ["minecraft:render_offsets"] = "apple",
        }
    }
end

function CustomItemManager.getItemTable()
    local table = {}
    for name, data in pairs(CustomItemManager.items) do
        table[name] = data.id
    end
    return table
end

return CustomItemManager