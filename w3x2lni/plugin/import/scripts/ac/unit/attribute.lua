local jass = require 'jass.common'
local japi = require 'jass.japi'

local Care = {'生命', '生命上限', '生命恢复', '魔法', '魔法上限', '魔法恢复', '攻击', '护甲', '移动速度', '攻击速度', '攻击间隔', '冷却缩减', '减耗', '力量', '智力', '敏捷'}

Default = {
    ['攻击间隔'] = 1.0,
}

local Show = {
    ['生命'] = function (unit, v)
        if v > 1 then
            jass.SetWidgetLife(unit._handle, v)
        else
            jass.SetWidgetLife(unit._handle, 1)
        end
    end,
    ['生命上限'] = function (unit, v)
        if v > 1 then
            japi.SetUnitState(unit._handle, 1, v)
        else
            japi.SetUnitState(unit._handle, 1, 1)
        end
    end,
    ['魔法'] = function (unit, v)
        jass.SetUnitState(unit._handle, 2, v)
    end,
    ['魔法上限'] = function (unit, v)
        japi.SetUnitState(unit._handle, 3, v)
    end,
    ['攻击'] = function (unit, v)
        if v > 2147483584 then
            v = 2147483584
        end
        japi.SetUnitState(unit._handle, 0x12, v-1)
        japi.SetUnitState(unit._handle, 0x32, v-1)
    end,
    ['护甲'] = function (unit, v)
        if v > 2147483583 then
            v = 2147483583
        end
        japi.SetUnitState(unit._handle, 0x20, v)
    end,
    ['移动速度'] = function (unit, v)
        jass.SetUnitMoveSpeed(unit._handle, v)
    end,
    ['攻击速度'] = function (unit, v)
        if v >= 0 then
            japi.SetUnitState(unit._handle, 0x51, 1 + v / 100)
        else
            --当攻击速度小于0的时候,每点相当于攻击间隔增加1%
            japi.SetUnitState(unit._handle, 0x51, 1 + v / (100 - v))
        end
    end,
    ['攻击间隔'] = function (unit, v)
        japi.SetUnitState(unit._handle, 0x25, v)
        japi.SetUnitState(unit._handle, 0x38, v)
    end,
    ['力量'] = function (unit, v)
        if v > 2147483647 then
            v = 2147483647
        end
        jass.SetHeroStr(unit._handle, math.floor(v), true)
    end,
    ['敏捷'] = function (unit, v)
        if v > 2147483647 then
            v = 2147483647
        end
        jass.SetHeroAgi(unit._handle, math.floor(v), true)
    end,
    ['智力'] = function (unit, v)
        if v > 2147483647 then
            v = 2147483647
        end
        jass.SetHeroInt(unit._handle, math.floor(v), true)
    end,
    ['攻击范围'] = function (unit, v)
        japi.SetUnitState(unit._handle, 0x16, v)
        japi.SetUnitState(unit._handle, 0x40, v)
    end,
}

local Set = {
    ['生命上限'] = function (attribute)
        local max = attribute:get '生命上限'
        local rate
        if max <= 0.0 then
            rate = 1.0
        else
            rate = attribute:get '生命' / max
        end
        return function ()
            attribute:set('生命', rate * attribute:get '生命上限')
        end
    end,
    ['魔法上限'] = function (attribute)
        local max = attribute:get '魔法上限'
        local rate
        if max <= 0.0 then
            rate = 1.0
        else
            rate = attribute:get '魔法' / max
        end
        return function ()
            attribute:set('魔法', rate * attribute:get '魔法上限')
        end
    end,
}

local Limit = {
    ['生命'] = function (attribute)
        local life = attribute:get '生命'
        if life < 0 then
            attribute._base['生命'] = 0.0
        else
            local maxLife = attribute:get '生命上限'
            if life > maxLife then
                attribute._base['生命'] = maxLife
            end
        end
    end,
    ['魔法'] = function (attribute)
        local life = attribute:get '魔法'
        if life < 0 then
            attribute._base['魔法'] = 0.0
        else
            local maxLife = attribute:get '魔法上限'
            if life > maxLife then
                attribute._base['魔法'] = maxLife
            end
        end
    end,
}

local Get = {
}

local mt = {}
mt.__index = mt

mt.type = 'unit attribute'

-- 设置固定值，会清除百分比部分
function mt:set(k, v)
    local ext = k:sub(-1)
    if ext == '%' then
        error('设置属性不能带属性')
    end
    local wait = self:onSet(k)
    self._base[k] = v
    self._rate[k] = 0.0
    self:onLimit(k)
    self:onShow(k)
    if wait then
        wait()
    end
end

function mt:get(k)
    local base = self._base[k] or 0.0
    local rate = self._rate[k] or 0.0
    local v = base * (1.0 + rate / 100.0)
    if Get[k] then
        v = Get[k](self, v) or v
    end
    return v
end

function mt:add(k, v)
    local ext = k:sub(-1)
    if ext == '%' then
        k = k:sub(1, -2)
        if k == '生命' or k == '魔法' then
            log.error(('[%s]不能使用百分比属性'):format(k))
            return function () end
        end
        local wait = self:onSet(k)
        self._rate[k] = (self._rate[k] or 0.0) + v
        self:onShow(k)
        if wait then
            wait()
        end
    else
        local wait = self:onSet(k)
        self._base[k] = (self._base[k] or 0.0) + v
        self:onLimit(k)
        self:onShow(k)
        if wait then
            wait()
        end
    end
    local used
    return function ()
        if used then
            return
        end
        used = true
        self:add(k, -v)
    end
end

function mt:onShow(k)
    if not Show[k] then
        return
    end
    local v = self:get(k)
    local s = self._show[k] or 0.0
    if v == s then
        return
    end
    local unit = self._unit
    if unit._removed then
        return
    end
    local delta = v - s
    self._show[k] = v
    Show[k](unit, v)
    unit:eventNotify('单位-属性变化', unit, k, delta)
end

function mt:onSet(k)
    if not Set[k] then
        return nil
    end
    return Set[k](self)
end

function mt:onLimit(k)
    if not Limit[k] then
        return nil
    end
    Limit[k](self)
end

return function (unit, default)
    local obj = setmetatable({
        _unit = unit,
        _base = {},
        _rate = {},
        _show = {},
    }, mt)
    for _, k in ipairs(Care) do
        local v = default and default[k] or Default[k] or 0.0
        obj:add(k, v)
    end
    return obj
end
