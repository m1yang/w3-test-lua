# w3-test-lua

用于快速测试魔兽争霸 III 1.27 的lua engine特性，参考自 [war3-lua-map](https://github.com/sumneko/war3-lua-map)。

## 设置环境变量
在tools/env.bat中设置
```bat
set we=path\to\we
set w3x2lni=path\to\w3x2lni
```
编辑器的插件环境不一样

编辑器打开地图时
输入格式：Lni
输出模式：obj
使用的插件: 
除了 [阻止删除本地插件]

编辑器保存时 第一次
输入格式：Mpq
输出模式：lni
使用的插件:
[输出引用的对象](本地) - slk时输出被引用的对象列表
[阻止删除本地插件]

编辑器保存时 第二次
输入格式：Lni
输出模式：obj
使用的插件:
[输出引用的对象](本地) - slk时输出被引用的对象列表
[阻止删除本地插件]