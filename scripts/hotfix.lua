local jass = require 'jass.common'
local japi = require 'jass.japi'
local hook = require 'jass.hook'
local dbg = require 'jass.debug'

--- 热更新.注意别死循环。
---@param Entry string 入口文件(require用的路径)  一般是 Main
local function hotFix(Entry)
    package.loaded[Entry] = nil

    xpcall(require, function(msg)
        print(msg, debug.traceback())
    end, Entry)
end

local handles = {
    unit = {},
    item = {},
    timer = {},
    trigger = {},
    frame = {},
}
-- function hook.CreateUnit(pid, uid, x, y, face, realCreateUnit)
--     print('创建单位:')
--     local handle = realCreateUnit(pid, uid, x, y, face)
--     handles.unit[handle] = true
--     return handle
-- end

local CreateUnit = jass.CreateUnit
rawset(jass, 'CreateUnit', function(...)
    local handle = CreateUnit(...)
    handles.unit[handle] = true
    return handle
end)

local CreateItem = jass.CreateItem
rawset(jass, 'CreateItem', function(...)
    local handle = CreateItem(...)
    handles.item[handle] = true
    return handle
end)

local CreateTimer = jass.CreateTimer
rawset(jass, 'CreateTimer', function(...)
    local handle = CreateTimer(...)
    handles.timer[handle] = true
    return handle
end)

local CreateTrigger = jass.CreateTrigger
rawset(jass, 'CreateTrigger', function(...)
    local handle = CreateTrigger(...)
    handles.trigger[handle] = true
    return handle
end)

local DzCreateFrameByTagName = jass.DzCreateFrameByTagName
rawset(jass, 'DzCreateFrameByTagName', function(...)
    local handle = DzCreateFrameByTagName(...)
    handles.frame[handle] = true
    return handle
end)

local function clearHandles()
    local u = handles.unit
    for key in pairs(u) do
        jass.RemoveUnit(key)
    end

    local i = handles.item
    for key in pairs(i) do
        jass.RemoveItem(key)
    end

    local t = handles.timer
    for key in pairs(t) do
        jass.DestroyTimer(key)
    end

    local tri = handles.trigger
    for key in pairs(tri) do
        jass.TriggerClearActions(key)
        jass.DisableTrigger(key)
        jass.DestroyTrigger(key)
    end

    local f = handles.frame
    for key in pairs(f) do
        jass.RemoveUnit(key)
    end
end

local t = jass.CreateTrigger();
japi.DzTriggerRegisterKeyEventByCode(t, 116, 0, true, nil)

jass.TriggerAddAction(t, function()
    print('清除数据...')
    clearHandles()
    print('开始重载...')
    hotFix("tstl_output")
end)