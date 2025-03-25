local icon = require 'ac.buff.icon'

local METHOD = {
    ['onAdd']         = '状态-获得',
    ['onRemove']      = '状态-失去',
}
local Count = 0

local function lockEvent(buff)
    buff._lockEvent = buff._lockEvent + 1
end

local function unlockEvent(buff)
    buff._lockEvent = buff._lockEvent - 1
    if buff._lockEvent ~= 0 then
        return
    end
    local first = table.remove(buff._lockList, 1)
    if first then
        buff:eventNotify(table.unpack(first, 1, first.n))
    end
end

local function callMethod(buff, name, ...)
    local method = buff[name]
    if not method then
        return
    end
    local suc, res = xpcall(method, log.error, buff, ...)
    if suc then
        return res
    end
end

local setmetatable = setmetatable
local mt = {}
mt.__index = mt
mt.type = 'buff'

function mt:__tostring()
    return ('{buff|%s-%d}'):format(self._name, self._count)
end

local function createDefine(name)
    local defined = {}
    defined.__index = defined
    defined.__tostring = mt.__tostring
    defined._name = name
    return setmetatable(defined, mt)
end

local function remove(mgr)
    if mgr._removed then
        return
    end
    mgr._removed = true
    for buff in mgr._buffs:pairs() do
        buff:remove()
    end
end

local function onDead(mgr)
    for buff in mgr._buffs:pairs() do
        if buff.keep ~= 1 then
            buff:remove()
        end
    end
end

local function findBuff(mgr, name)
    for buff in mgr._buffs:pairs() do
        if buff._name == name then
            return buff
        end
    end
    return nil
end

local function eachBuff(mgr)
    return mgr._buffs:pairs()
end

local function removeBuffByName(mgr, name, onlyOne)
    local ok = false
    for buff in mgr._buffs:pairs() do
        if buff._name == name then
            ok = true
            buff:remove()
            if onlyOne then
                return true
            end
        end
    end
    print('#', mgr._buffs.max, #mgr._buffs.list)
    return ok
end

local function manager(unit)
    local mgr = {
        _owner = unit,
        _buffs = ac.list(),
        remove = remove,
        onDead = onDead,
        findBuff = findBuff,
        eachBuff = eachBuff,
        removeBuffByName = removeBuffByName,
    }

    unit._buff = mgr

    return mgr
end

local function setRemainig(buff, time)
    if buff._timer then
        buff._timer:remove()
    end
    if time <= 0.0 then
        return
    end
    buff._timer = ac.wait(time, function ()
        buff:eventNotify('onFinish')
        buff:remove()
    end)
end

local function setPulse(buff, pulse)
    if buff._pulse then
        buff._pulse:remove()
    end
    if pulse <= 0.0 then
        return
    end
    buff._pulse = ac.loop(pulse, function ()
        buff:eventNotify('onPulse')
    end)
end

local function onAdd(buff)
    if ac.isNumber(buff.time) then
        setRemainig(buff, buff.time)
    end
    if ac.isNumber(buff.pulse) then
        setPulse(buff, buff.pulse)
    end

    if buff.show == 1 then
        buff._icon = icon(buff)
    end

    buff:eventNotify('onAdd')
end

local function onRemove(buff)
    if buff._pulse then
        buff._pulse:remove()
    end
    if buff._timer then
        buff._timer:remove()
    end
    if buff._icon then
        buff._icon:remove()
    end

    buff:eventNotify('onRemove')
end

local function isSameNameBuffs(otherBuff, buff, coverGlobal)
    if buff == otherBuff then
        return false
    end
    if coverGlobal == 0 then
        if otherBuff._name == buff._name and otherBuff._source == buff._source then
            return true
        end
    elseif coverGlobal == 1 then
        if otherBuff._name == buff._name then
            return true
        end
    end
    return false
end

local function create(unit, name, data)
    local mgr = unit._buff
    if not mgr then
        return nil
    end
    if mgr._removed then
        return nil
    end

    Count = Count + 1
    local self = setmetatable(data, ac.buff[name])
    self._owner = unit
    self._count = Count
    self._mgr = mgr
    self._source = ac.isUnit(self.source) and self.source or unit
    self._lockEvent = 0
    self._lockList = {}

    if not unit:isAlive() and self.keep ~= 1 then
        return nil
    end

    local coverGlobal = ac.toInteger(self.coverGlobal)
    local coverType = ac.toInteger(self.coverType)
    if coverType == 0 then
        for otherBuff in mgr._buffs:pairs() do
            if isSameNameBuffs(otherBuff, self, coverGlobal) then
                local res = otherBuff:eventDispatch('onCover', self)
                if res == false then
                    return nil
                else
                    otherBuff:remove()
                end
            end
        end
    elseif coverType == 1 then
        for otherBuff in mgr._buffs:pairs() do
            if isSameNameBuffs(otherBuff, self, coverGlobal) then
                local res = otherBuff:eventDispatch('onCover', self)
                if res == true then
                    mgr._buffs:insertBefore(self, otherBuff)
                    break
                end
            end
        end
    end

    mgr._buffs:insert(self)

    onAdd(self)

    return self
end

function mt:getOwner()
    return self._owner
end

function mt:remove()
    if self._removed then
        return
    end
    self._removed = true
    local unit = self._owner
    local mgr = unit._buff
    mgr._buffs:remove(self)

    onRemove(self)
end

function mt:remaining(time)
    if ac.isNumber(time) then
        setRemainig(self, time)
    else
        if not self._timer then
            return ac.toNumber(self.time)
        end
        return self._timer:remaining()
    end
end

function mt:pulse(pulse)
    if ac.isNumber(pulse) then
        setPulse(self, pulse)
    else
        return ac.toNumber(self.pulse)
    end
end

function mt:eventNotify(name, ...)
    if self._lockEvent == 0 then
        lockEvent(self)
        local event = METHOD[name]
        if event then
            ac.eventNotify(self, event, self, ...)
            self:getOwner():eventNotify(event, self, ...)
        end
        callMethod(self, name, ...)
        unlockEvent(self)
    else
        self._lockList[#self._lockList+1] = table.pack(name, ...)
    end
end

function mt:eventDispatch(name, ...)
    lockEvent(self)
    local event = METHOD[name]
    if event then
        local res, data = ac.eventDispatch(self, event, self, ...)
        if res ~= nil then
            unlockEvent(self)
            return res, data
        end
        local res, data = self:getOwner():eventDispatch(event, self, ...)
        if res ~= nil then
            unlockEvent(self)
            return res, data
        end
    end
    local res, data = callMethod(self, name, ...)
    unlockEvent(self)
    return res, data
end

ac.buff = setmetatable({}, {
    __index = function (self, name)
        local buff = createDefine(name)
        self[name] = buff
        return buff
    end,
})

return {
    create = create,
    manager = manager,
}
