local BinaryStream = {}
BinaryStream.__index = BinaryStream

function BinaryStream.new(buffer)
    return setmetatable({buffer = buffer, offset = 1}, BinaryStream)
end

function BinaryStream:readVarInt()
    local value = 0
    for i = 0, 35, 7 do
        local b = string.byte(self.buffer, self.offset)
        self.offset = self.offset + 1
        value = bit.bor(value, bit.lshift(bit.band(b, 0x7f), i))
        if bit.band(b, 0x80) == 0 then break end
    end
    return value
end

function BinaryStream:readString()
    local len = self:readVarInt()
    local str = string.sub(self.buffer, self.offset, self.offset + len - 1)
    self.offset = self.offset + len
    return str
end