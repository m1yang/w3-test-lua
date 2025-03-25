local fs = require 'bee.filesystem'
local ydwe = require 'tools.ydwe'
local subprocess = require 'bee.subprocess'
if not ydwe then
    return
end

local root = fs.path(arg[1])

subprocess.spawn {
    ydwe / 'KKWE.exe',
    "-loadfile", 
    root / '.w3x'
}
