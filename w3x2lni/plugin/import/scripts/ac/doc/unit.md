# unit

## unit.ini

### id
单位在物编中的4位id

```lua
id = 'E000'
```

### class
类别

```lua
class = '生物'
class = '弹道'
```

### attribute
单位的初始属性，不填的部分为0。

```lua
attribute = {
    '生命上限' = 1000,
    '攻击' = 100,
}
```

### type
单位的类型，用于选取器等判断。

```lua
type = {'英雄', '生物'}
```

### restriction
限制

```lua
restriction = {'无敌'}
```

### attack
攻击

```lua
attack = {
    type = '立即',
    range = 100,
}
attack = {
    type = '弹道',
    range = 500,
    mover = {
        model = [[Abilities\Weapons\AncientProtectorMissile\AncientProtectorMissile.mdl]],
        speed = 1000,
        startHeight = 200,
    }
}
```

### hitHeight
受击高度

```lua
hitHeight = 60
```

### skill
技能

```lua
skill = {'技能A', '技能B'}

skill = {
    3 = '技能A',
    6 = '技能B',
}
```

### hideSkill
隐藏技能

```lua
hideSkill = {'技能A', '技能B'}
```

## method

### getName
```lua
unit:getName()
    -> name: string
```

### set
```lua
unit:set(attributeName: string, attributeValue: number)

attributeName: string
    | '生命'
    | '生命上限'
    | '生命恢复'
    | '魔法'
    | '魔法上限'
    | '魔法恢复'
    | '攻击'
    | '护甲'
    | '移动速度'
    | '攻击速度'
    | '冷却缩减'
    | '减耗'
    | '力量'
    | '智力'
    | '敏捷'
    | '攻击范围'
```

### get
```lua
unit:get(attributeName: string)
    -> value: number

attributeName: string
    | '生命'
    | '生命上限'
    | '生命恢复'
    | '魔法'
    | '魔法上限'
    | '魔法恢复'
    | '攻击'
    | '护甲'
    | '移动速度'
    | '攻击速度'
    | '冷却缩减'
    | '减耗'
    | '力量'
    | '智力'
    | '敏捷'
    | '攻击范围'
```

### add
```lua
unit:add(attributeName: string, attributeValue: number)
    -> destructor: function

attributeName: string
    | '生命'
    | '生命上限'
    | '生命恢复'
    | '魔法'
    | '魔法上限'
    | '魔法恢复'
    | '攻击'
    | '护甲'
    | '移动速度'
    | '攻击速度'
    | '冷却缩减'
    | '减耗'
    | '力量'
    | '智力'
    | '敏捷'
    | '攻击范围'
```

### addRestriction
```lua
unit:addRestriction(restrictionName: string)
    -> destructor: function

restrictionName: string
    | '硬直'
    | '无敌'
    | '幽灵'
    | '定身'
    | '飞行'
    | '疾风步'
    | '隐藏'
    | '缴械'
    | '禁魔'
```

### removeRestriction
```lua
unit:removeRestriction(restrictionName: string)

restrictionName: string
    | '硬直'
    | '无敌'
    | '幽灵'
    | '定身'
    | '飞行'
    | '疾风步'
    | '隐藏'
    | '缴械'
    | '禁魔'
```

### getRestriction
```lua
unit:getRestriction(restrictionName: string)
    -> count: integer

restrictionName: string
    | '硬直'
    | '无敌'
    | '幽灵'
    | '定身'
    | '飞行'
    | '疾风步'
    | '隐藏'
    | '缴械'
    | '禁魔'
```

### hasRestriction
```lua
unit:hasRestriction(restrictionName: string)
    -> boolean

restrictionName: string
    | '硬直'
    | '无敌'
    | '幽灵'
    | '定身'
    | '飞行'
    | '疾风步'
    | '隐藏'
    | '缴械'
    | '禁魔'
```

### isAlive
```lua
unit:isAlive()
    -> boolean
```

### isHero
```lua
unit:isHero()
    -> boolean
```

### kill
```lua
unit:kill([target: unit])
```

### remove
```lua
unit:remove()
```

### getPoint
```lua
unit:getPoint()
    -> point
```

### setPoint
```lua
unit:setPoint(point)
```

### getOwner
```lua
unit:getOwner()
    -> player
```

### setOwner
```lua
unit:setOwner(player[, changeColor: boolean])
    -> boolean
```

### particle
```lua
unit:particle(model: string, socket: string[, life: number])
    -> destructor: function
```

### setFacing
```lua
unit:setFacing(angle: number[, time: number])
```

### getFacing
```lua
unit:getFacing()
    -> number
```

### createUnit
```lua
unit:createUnit(name: string, point, face: number)
    -> unit
```

### addHeight
```lua
unit:addHeight(number)
```

### getHeight
```lua
unit:getHeight()
    -> number
```

### getCollision
```lua
unit:getCollision()
    -> number
```

### addSkill
```lua
unit:addSkill(name: string, type: string[, slot: integer])
    -> skill

type: string
    | '技能'
    | '物品'
    | '隐藏'
```

### findSkill
```lua
unit:findSkill(name: string/index: integer[, type: string])
    -> skill

type: string
    | '技能'
    | '物品'
    | '隐藏'
```

### eachSkill
```lua
for skill in unit:eachSkill([type: string]) do
end

type: string
    | '技能'
    | '物品'
    | '隐藏'
```

### removeSkill
```lua
unit:removeSkill(name: string[, onlyOne: boolean])
    -> boolean
```

### event
```lua
unit:event(name: string, callback: function)
    -> trigger
```

### eventDispatch
```lua
unit:eventDispatch(name, ...)
    -> any
```

### eventNotify
```lua
unit:eventNotify(name, ...)
```

### moverTarget
```lua
unit:moverTarget {
    target = unit,
    speed = number,
    [mover = unit/unitName: string,]
    [model = modelPath: string,]
    [start = point,]
    [angle = number,]
    [maxDistance = number,]
    [fix = {angle: number, distance: number},]
    [heightEquation = function,]
    [startHeight = number,]
    [finishHeight = number,]
    [middleHeight = number,]
    [hitType = string],
    [hitArea = number],
    [hitSame = boolean],
    [timeRate = number(1.0)],
}
    -> mover
```

### moverLine
```lua
unit:moverLine {
    speed = number,
    [mover = unit/unitName: string,]
    [model = modelPath: string,]
    [start = point,]
    [target = point,]
    [angle = number,]
    [distance = number,]
    [fix = {angle: number, distance: number},]
    [heightEquation = function,]
    [startHeight = number,]
    [finishHeight = number,]
    [middleHeight = number,]
    [hitType = string],
    [hitArea = number],
    [hitSame = boolean],
    [timeRate = number(1.0)],
}
    -> mover
```

### walk
```lua
unit:walk(point/unit)
    -> boolean
```

### attack
```lua
unit:attack(point/unit)
    -> boolean
```

### stop
```lua
unit:stop()
```

### stopWalk
```lua
unit:stopWalk()
    -> boolean
```

### blink
```lua
unit:blink(point)
    -> boolean
```

### reborn
```lua
unit:reborn(point, showEffect: boolean)
    -> boolean
```

### slk
```lua
unit:slk(key: string)
    -> any
```

### level
```lua
unit:level([level: integer, showEffect: boolean])
    -> [level: integer]
```

### exp
```lua
unit:exp([exp: integer, showEffect: boolean])
    -> [exp: integer]
```

### addExp
```lua
unit:addExp(exp: integer, showEffect: boolean)
```

### currentSkill
```lua
unit:currentSkill()
    -> skill
```

### isEnemy
```lua
unit:isEnemy(other: unit/player)
    -> boolean
```

### isAlly
```lua
unit:isAlly(other: unit/player)
    -> boolean
```

### isBuilding
```lua
unit:isBuilding()
    -> boolean
```

### isIllusion
```lua
unit:isIllusion()
    -> boolean
```

### isType
```lua
unit:isType(name: string)
    -> boolean
```

### addType
```lua
unit:addType(name: string)
```

### removeType
```lua
unit:removeType(name: string)
```

### isVisible
```lua
unit:isVisible(other: unit)
    -> boolean
```

### damage
```lua
unit:damage {
    target = unit,
    damage = number,
    skill = skill / attack,
}
```

### createItem
```lua
unit:createItem(name: string[, slot: integer])
    -> item
```

### isBagFull
```lua
unit:isBagFull()
    -> boolean
```

### userData
```lua
unit:userData(key: string, value: any)

unit:userData(key: string)
    -> value: any
```

### selectedRadius
```lua
unit:selectedRadius(radius: number)

unit:selectedRadius()
    -> radius: number
```

### isInRange
```lua
unit:isInRange(point, range: number)
```

### bagSize()
```lua
unit:bagSize(size: integer)

unit:bagSize()
    -> size: integer
```

### findItem
```lua
unit:findItem(itemName: string)
    -> item
```

### eachItem
```lua
for item in unit:eachItem() do
end
```

### getXY
```lua
unit:getXY()
    -> x: number, y: number
```

### addBuff
```lua
unit:addBuff(buffName: string) {
    time = number,
    pulse = number,
}
    -> buff
```

### findBuff
```lua
unit:findBuff(buffName: string)
    -> buff
```

### eachBuff
```lua
for buff in unit:eachBuff() do
end
```

### removeBuff
```lua
unit:removeBuff(buffName: string[, onlyOne: boolean])
    -> boolean
```

### createShop
```lua
unit:createShop()
    -> shop
```

### cast
```lua
unit:cast(name: string[, target: any][, data: table])
    -> boolean
```

### speed
```lua
unit:speed([speed: number])
    -> [speed: number]
```

### color

范围均为[0.0-1.0]。

```lua
unit:color(r: number, g: number, b: number, a: number)
```

### animation
```lua
unit:animation(name: integer/string)
```
