local bit = require('bit')

local BinaryStream = {}
BinaryStream.__index = BinaryStream

function BinaryStream.new(buffer)
    return setmetatable({buffer = buffer or "", offset = 1}, BinaryStream)
end

function BinaryStream:readVarInt()
    local value = 0
    for i = 0, 35, 7 do
        if self.offset > #self.buffer then 
            return value 
        end
        
        local b = string.byte(self.buffer, self.offset)
        self.offset = self.offset + 1
        
        value = bit.bor(value, bit.lshift(bit.band(b, 0x7f), i))
        
        if bit.band(b, 0x80) == 0 then 
            return value 
        end
    end
    return value
end

function BinaryStream:readVarIntSigned()
    local raw = self:readVarInt()
    return bit.bxor(bit.arshift(raw, 1), -(bit.band(raw, 1)))
end

function BinaryStream:readString()
    local len = self:readVarInt()
    
    if len <= 0 or (self.offset + len - 1) > #self.buffer then
        return ""
    end
    
    local str = string.sub(self.buffer, self.offset, self.offset + len - 1)
    self.offset = self.offset + len
    return str
end

return BinaryStream
