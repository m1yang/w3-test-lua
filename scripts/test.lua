local jass = require 'jass.common'
local japi = require 'jass.japi'
local hook = require 'jass.hook'
local dbg = require 'jass.debug'

local war3Type = {
    ["+loc"] = '点',
    ["+EIP"] = '点特效',
    ["+EIm"] = '附着特效',
    ["+EIf"] = '特效III',
    ["+tmr"] = '计时器',
    ["item"] = '物品',
    ["+w3u"] = '单位',
    ["+grp"] = '单位组',
    ["+dlb"] = '按钮',
    ["+dlg"] = '对话框',
    ["+w3d"] = '可破坏物',
    ["+rev"] = '事件',
    ["alvt"] = '事件',
    ["bevt"] = '事件',
    ["devt"] = '事件',
    ["gevt"] = '事件',
    ["gfvt"] = '事件',
    ["pcvt"] = '玩家聊天事件',
    ["pevt"] = '玩家事件',
    ["psvt"] = '事件',
    ["tmet"] = '事件',
    ["tmvt"] = '事件',
    ["uevt"] = '单位事件',
    ["wdvt"] = '可破坏物事件',
    ["+flt"] = '过滤器',
    ["+fgm"] = '可见度修正器',
    ["+frc"] = '玩家组',
    ["ghth"] = '哈希表',
    ["+mdb"] = '多面板',
    ["+ply"] = '玩家',
    ["+rct"] = '矩形区域',
    ["+agr"] = '范围',
    ["+snd"] = '声音',
    ["+tid"] = '计时器窗口',
    ["+trg"] = '触发器',
    ["+tac"] = '触发器动作',
    ["tcnd"] = '触发器条件',
    ["ipol"] = '物品池',
    ["+mbi"] = '多面板项目',
    ["gcch"] = '缓存',
    ["+que"] = '任务'
}

local function cpu()
    local run = collectgarbage('isrunning')
    local count = collectgarbage('count') / 1024
    print(string.format('内存运行:%s : %.2f MB', run, count))
end

local function gc()
    local before = collectgarbage("count")
    collectgarbage("collect")
    local current = collectgarbage("count")
    
    local cost = before - current
    print(string.format('gc 释放:\t%.2f MB, 当前%.2f MB', cost/1024, current/1024))
end

local function handle()
    local hMax = dbg.handlemax()
    local hNum = dbg.handlecount()
    print(hMax, hNum)

    local temp = {}
    -- 2^20 = 1024*1024 = 1048576
    local startIndex = 1048576;
    for i = startIndex, hMax + startIndex do
        local info = dbg.handledef(dbg.i2h(i))
        local type = war3Type[info.type] or "未知"
        if not temp[type] then
            temp[type] = {}
            -- temp[type] = 0
        end
        -- local reference = info.reference or 0
        -- temp[type] = temp[type] + reference
        table.insert(temp[type], {
            handle = i,
            reference = info.reference or 0,
        })
    end
    print_r(temp['单位'])
    print_r(temp['物品'])
end

local function unit()
    local u = jass.CreateUnit(jass.Player(0), ('>I4'):unpack("nech"), 0, 0, 0)
    dbg.handle_ref(u)
    print(u)
end

local function unitc()
    local u = jass.CreateUnit(jass.Player(0), ('>I4'):unpack("nech"), 0, 0, 0)
    print(u)
    -- dbg.handle_ref(u)
    -- jass.KillUnit(u)
    jass.RemoveUnit(u)
    -- dbg.handle_unref(u)
    local i = jass.CreateItem(('>I4'):unpack("ratc"), 0.0, 0.0)
    print(i)
end

local trg = jass.CreateTrigger();
-- japi.DzTriggerRegisterKeyEventByCode(trg, 115, 0, true, nil)
jass.TriggerRegisterPlayerChatEvent(trg, jass.Player(0), '', false)

jass.TriggerAddAction(trg, function()
    -- local player = jass.GetTriggerPlayer()
    local str = jass.GetEventPlayerChatString()
    if str == "gc" then
        gc()
    elseif str == "cpu" then
        cpu()
    elseif str == "handle" then
        handle()
    elseif str == "unit" then
        unitc()
    end
end)
