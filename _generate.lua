
local encoder = require "Encode/SheeryEncoder"
local config = require "Config"

for idx,originalFileName in ipairs(config.encode_map) do

	local encodedFileName = originalFileName..config.encode_tail

	encoder:EncodeFile(config.encode_key, originalFileName, encodedFileName, config.encode_len)

	encoder:DecodeFile(config.encode_key, encodedFileName, originalFileName, config.encode_len)
end
