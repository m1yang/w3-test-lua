local message = require 'jass.message'
local jass = require 'jass.common'
local slk = require 'jass.slk'

local ORDER = require 'ac.war3.order'
local CMD_ORDER = ORDER[slk.ability['@CMD'].DataF]
local PROTO = require 'ac.message.proto'
local KEYBORD = message.keyboard
local FLAG = {
    ['队列'] = 1 << 0,
    ['瞬发'] = 1 << 1,
    ['独立'] = 1 << 2,
    ['恢复'] = 1 << 5,
    ['失败'] = 1 << 8,
}
local COMMAND = {
    ['攻击'] = KEYBORD['A'],
    ['移动'] = KEYBORD['M'],
    ['巡逻'] = KEYBORD['P'],
    ['保持'] = KEYBORD['H'],
    ['停止'] = KEYBORD['S'],
    ['休眠'] = KEYBORD['Z'],
    ['警戒'] = KEYBORD['X']
}
local LastSelectClock = 0

local function localHero()
    return ac.localPlayer():getHero()
end

local function getSelect()
    return ac.unit(message.selection())
end

local function selectHero()
    local hero = localHero()
    if not hero then
        return
    end
    if hero == getSelect() then
        return
    end
    ac.localPlayer():selectUnit(hero)
    LastSelectClock = ac.clock()
end

local function canControl()
    for x = 0, 3 do
        for y = 0, 2 do
            local ability = message.button(x, y)
            if ability then
                return true
            end
        end
    end
    return false
end

local function checkSelectHero()
    local selecting = getSelect()
    if selecting == localHero() then
        return
    end
    if canControl() and selecting:findSkill('@命令') then
        return
    end
    selectHero()
end

local function lockHero()
    local hero = localHero()
    if not hero then
        return
    end
    jass.SetCameraTargetController(hero._handle, 0, 0, false)
end

local function unlockHero()
    jass.SetCameraPosition(jass.GetCameraTargetPositionX(), jass.GetCameraTargetPositionY())
end

local function pressKey(key)
    if ac.clock() == LastSelectClock then
        -- 刚选中新的单位，强制按键会短暂失效，要多试几次
        ac.timer(0.01, 5, function ()
            jass.ForceUIKey(key)
        end)
    else
        jass.ForceUIKey(key)
    end
end

local function proto(id, arg)
    if arg == nil then
        arg = 0
    end
    message.order_target(ORDER['channel'], id, arg, 0, FLAG['瞬发'])
end

local function stackCommand(cmd)
    proto(PROTO[cmd])
end

local function waitCommand(cmd)
    local unit = getSelect()
    local skill = unit:findSkill '@命令'
    if not skill then
        return
    end
    stackCommand(cmd)
    pressKey(skill.hotkey)
end

local function instantCommand(cmd)
    if cmd == '保持' then
        message.order_immediate(ORDER['holdposition'], 0)
    elseif cmd == '停止' then
        message.order_immediate(ORDER['stop'], 0)
    elseif cmd == '休眠' then
        proto(PROTO['休眠'])
    elseif cmd == '警戒' then
        message.order_immediate(ORDER['patrol'], 0)
    end
end

local function findSkillByHotkey(unit, code)
    if not unit then
        return nil
    end
    for skill in unit:eachSkill() do
        local hotkey = skill.hotkey
        if KEYBORD[hotkey] == code then
            return skill
        end
    end
    return nil
end

local function findSkillByAbility(unit, ability)
    if not unit then
        return nil
    end
    for skill in unit:eachSkill '技能' do
        local destAbility = skill._icon and skill._icon._ability
        if destAbility == ability then
            return skill
        end
    end
    return nil
end

local function checkShop(ability)
    local unit = getSelect()
    if not unit or not unit._shop then
        return
    end
    local skill = findSkillByAbility(unit, ability)
    if not skill then
        return false
    end
    proto(skill.index, ac.localPlayer():id())
    return true
end

local function checkCommonCommand(msg)
    -- 基础命令
    if msg.code == COMMAND['攻击'] then
        checkSelectHero()
        waitCommand '攻击'
        return false
    elseif msg.code == COMMAND['移动'] then
        checkSelectHero()
        waitCommand '移动'
        return false
    elseif msg.code == COMMAND['巡逻'] then
        checkSelectHero()
        waitCommand '巡逻'
        return false
    elseif msg.code == COMMAND['保持'] then
        checkSelectHero()
        instantCommand '保持'
        return false
    elseif msg.code == COMMAND['停止'] then
        checkSelectHero()
        instantCommand '停止'
        return false
    elseif msg.code == COMMAND['休眠'] then
        checkSelectHero()
        instantCommand '休眠'
        return false
    elseif msg.code == COMMAND['警戒'] then
        checkSelectHero()
        instantCommand '警戒'
        return false
    end
end

local function checkSkill(msg)
    -- 技能
    local unit = getSelect()
    local skill
    if canControl() then
        skill = findSkillByHotkey(unit, msg.code)
        if skill and skill._icon and checkShop(skill._icon._ability) then
            return false
        end
    else
        skill = findSkillByHotkey(localHero(), msg.code)
        if skill then
            selectHero()
            pressKey(skill.hotkey)
            return false
        end
    end
end

local function onKeyDown(msg)
    -- 空格
    if msg.code == 32 then
        selectHero()
        lockHero()
        return false
    end

    local res = checkSkill(msg)
    if res ~= nil then
        return res
    end

    local res = checkCommonCommand(msg)
    if res ~= nil then
        return res
    end

    return true
end

local function onKeyUp(msg)
    -- 空格
    if msg.code == 32 then
        selectHero()
        unlockHero()
        return false
    end

    return true
end

local function onLeftClick()
    return true
end

local function onRightClick()
    checkSelectHero()
    return true
end

local function onClickAbility(msg)
    local order = msg.order
    if order == CMD_ORDER then
        stackCommand '攻击'
        return true
    end
    if checkShop(ac.id[msg.ability]) then
        return false
    end
    return true
end

function message.hook(msg)
    if msg.type == 'key_down' then
        if msg.state == 0 then
            return onKeyDown(msg)
        end
    elseif msg.type == 'key_up' then
        return onKeyUp(msg)
    elseif msg.type == 'mouse_down' then
        if msg.code == 1 then
            return onLeftClick()
        elseif msg.code == 4 then
            return onRightClick()
        end
    elseif msg.type == 'mouse_ability' then
        if msg.code == 1 then
            return onClickAbility(msg)
        end
    end
    return true
end
