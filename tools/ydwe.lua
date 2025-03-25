local fs = require 'bee.filesystem'
local registry = require 'bee.registry'

local wc3Open = [[HKEY_CURRENT_USER\SOFTWARE\Classes\YDWEMap\shell\open\command]]
local wc3Run = [[HKEY_CURRENT_USER\SOFTWARE\Classes\YDWEMap\shell\run_war3\command]]
local function main()
    local command = registry.open(wc3Open)['']
    local f, l = command:find('"[^"]*"')
    return fs.path(command:sub(f+1, l-1)):parent_path()
end
local suc, r = pcall(main)
if not suc or not r then
    print('需要YDWE关联w3x文件')
    return false
end
return r
