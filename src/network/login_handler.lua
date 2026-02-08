local json = require('json')

local LoginHandler = {}

local function decodeBase64URL(data)
    data = data:gsub('-', '+'):gsub('_', '/')
    local pad = #data % 4
    if pad > 0 then
        data = data .. string.rep('=', 4 - pad)
    end
    
    local success, openssl = pcall(require, 'openssl')
    if success then
        return openssl.base64(data, false)
    end
    
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function decodeJWT(token)
    if not token then return {} end
    local parts = {}
    for part in token:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    
    if #parts < 2 then return {} end
    
    local payloadJson = decodeBase64URL(parts[2])
    local success, data = pcall(json.decode, payloadJson)
    return success and data or {}
end

function LoginHandler.parse(payload)
    local startPos = payload:find('{"chain"') or payload:find('{"Chain"')
    
    if not startPos then 
        print("Error: Could not find JSON start in login packet")
        return nil 
    end
    
    local cleanJson = payload:sub(startPos)
    
    local success, rootData = pcall(json.decode, cleanJson)
    
    if not success or not rootData then
        cleanJson = cleanJson:gsub("%z+$", "")
        rootData = json.decode(cleanJson)
    end

    local playerInfo = {
        username = "Unknown",
        uuid = nil,
        xuid = nil,
        skinId = nil,
        skinData = nil,
        device = "Unknown",
        language = "en_US"
    }

    if rootData.chain and type(rootData.chain) == "table" then
        for _, token in ipairs(rootData.chain) do
            local claims = decodeJWT(token)
            
            if claims.extraData then
                playerInfo.username = claims.extraData.displayName
                playerInfo.uuid = claims.extraData.identity
                playerInfo.xuid = claims.extraData.XUID
            end
        end
    end

    local clientToken = rootData.clientData or rootData.ClientData
    if clientToken then
        local claims = decodeJWT(clientToken)
        
        playerInfo.skinId = claims.SkinId
        playerInfo.skinData = claims.SkinData
        playerInfo.device = claims.DeviceModel
        playerInfo.language = claims.LanguageCode
        playerInfo.gameVersion = claims.GameVersion
    end

    print("§a[Login] User: " .. playerInfo.username .. ", Device: " .. (playerInfo.device or "?"))

    return playerInfo
end

return LoginHandler
