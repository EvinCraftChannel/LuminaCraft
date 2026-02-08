local json = require('cjson')

local LoginHandler = {}

local function decodeBase64(data)
    data = data:gsub('-', '+'):gsub('_', '/')
    while #data % 4 ~= 0 do data = data .. '=' end
    return require('openssl').base64(data, false)
end

function LoginHandler.parse(payload)

    local startPos = payload:find('{"Chain"')
    if not startPos then return nil end
    local cleanJson = payload:sub(startPos)
    
    local rootData = json.decode(cleanJson)
    
    local clientJWT = rootData.ClientData
    
    local sections = {}
    for section in clientJWT:gmatch("[^.]+") do
        table.insert(sections, section)
    end
    
    local decodedClientData = decodeBase64(sections[2])
    local playerInfo = json.decode(decodedClientData)

    return {
        username = playerInfo.ThirdPartyName or playerInfo.DisplayName,
        skinId = playerInfo.SkinId,
        skinData = playerInfo.SkinData,
        device = playerInfo.DeviceModel,
        protocol = playerInfo.Protocol,
        language = playerInfo.LanguageCode
    }
end

return LoginHandler
