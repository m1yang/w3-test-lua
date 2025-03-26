local mt = {}

mt.info = {
    name = '导入文件',
    version = 1.2,
    author = '最萌小汐',
    description = '导入底层需要的文件'
}

local function importFiles(w2l)
    local needInsideLua = w2l.setting.remove_we_only
    local basePath = 'w3x2lni\\plugin\\import\\'
    local list = w2l.input_ar:list_file()
    local files = {}
    for _, name in ipairs(list) do
        if name:sub(1, #basePath):lower() == basePath then
            local buf = w2l.input_ar:get(name)
            w2l.input_ar:remove(name)
            files[name] = buf
            local newName = name:sub(#basePath+1)
            if needInsideLua or newName:sub(1, #'scripts\\') ~= 'scripts\\' then
                if not w2l.input_ar:get(newName) then
                    w2l.output_ar:set(newName, buf)
                end
            end
        end
    end
    for i = #list, 1, -1 do
        local name = list[i]
        if files[name] then
            table.remove(list, i)
        end
    end
end

function mt:on_convert(w2l)
    if w2l.setting.mode == 'lni' then
        return
    end

    importFiles(w2l)
end

return mt
