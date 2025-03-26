# w3-test-lua

用于快速测试魔兽争霸 III 1.27 的lua engine特性，参考自 [war3-lua-map](https://github.com/sumneko/war3-lua-map)。

## 设置环境变量
在tools/env.bat中设置
```bat
set we=path\to\we
set w3x2lni=path\to\w3x2lni
```

编辑器打开地图时
输入格式：Lni
输出模式：obj
使用的插件: 
除了 [阻止删除本地插件]

编辑器保存时 第一次
输入格式：Mpq
输出模式：lni
使用的插件:
[输出引用的对象](本地) - slk时输出被引用的对象列表 - used_ids.txt
[阻止删除本地插件]

编辑器保存时 第二次
输入格式：Lni
输出模式：obj
使用的插件:
[输出引用的对象](本地) - slk时输出被引用的对象列表
[阻止删除本地插件]

编辑器保存就会报错
插件[阻止删除本地插件]执行失败 - .\backend\plugin.lua:12: bad argument #1 to 'load' (function expected, got nil)
stack traceback:
        [C]: in function 'load'
        .\backend\plugin.lua:12: in function <.\backend\plugin.lua:10>
        [C]: in function 'xpcall'
        .\backend\plugin.lua:10: in upvalue 'load_plugins'
        .\backend\plugin.lua:37: in function 'backend.plugin'
        .\backend\convert.lua:120: in function 'backend.convert'
        .\backend\cli\lni.lua:4: in function 'backend.cli.lni'
        backend\init.lua:12: in main chunk
        [C]: in ?