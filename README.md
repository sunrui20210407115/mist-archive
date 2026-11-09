# 迷雾档案（Mist Archive）

《鸿蒙高级应用开发工程师认证》期末大作业 · 主题一：校园线索推理与多结局探索 App。

玩家扮演调查者，在校园三个场景中探索、收集线索、与人物对话，线索与选择真实改变可触发的后续事件，最终依据推理条件进入两个不同结局。应用支持中途退出后恢复进度，并支持重开案件。

## 功能

- 三个可探索场景：图书馆闭架书库、实验楼三层、宿舍区晾晒区
- 12 个事件节点，每个节点带条件判定与状态效果
- 6 条可查阅线索（线索板集中查看，未获取的线索灰显）
- 条件驱动的选择：缺少线索或前置信息时选项被禁用并给出提示
- 阶段进度：接案 → 调查中 → 可终局 → 已结案
- 两个结局：结局 A（移交校方，物证链闭合）、结局 B（独自结案，证据缺口）
- 存档与恢复：Preferences 快照，带版本号校验与损坏回退
- 重开案件：清空存档并归零进度
- 执行日志：relationalStore 记录每次选择，可按时间倒序查询

## 开发环境

| 项目 | 版本 |
| --- | --- |
| 操作系统 | Windows 11 |
| DevEco Studio | 5.0.13.240（build 233.14475.28.36.5013240） |
| HarmonyOS SDK | 5.0.5 Release（API 17） |
| hvigor | 5.17.6 |
| 开发语言 | ArkTS / ArkUI（Stage 模型） |
| 数据持久化 | @kit.ArkData（Preferences、relationalStore） |

## 目录结构

```
mist-archive/
├─ AppScope/                        应用级配置与图标
├─ entry/src/main/ets/
│  ├─ entryability/EntryAbility.ets 应用入口，初始化存档与日志服务
│  ├─ model/
│  │  ├─ GameTypes.ets              状态、线索、节点、选择、结局等类型
│  │  └─ StoryData.ets              6 条线索、12 个事件节点、2 个结局
│  ├─ service/
│  │  ├─ RuleEngine.ets             条件判定、效果应用、阶段推进、结局裁决
│  │  ├─ SaveService.ets            Preferences 存档与版本校验
│  │  └─ LogRepo.ets                RDB 建表、写入、查询
│  ├─ viewmodel/GameStore.ets       @Observed 会话状态，供视图订阅
│  ├─ view/                         首页、探索、线索板、终局、结局视图
│  └─ pages/Index.ets               页面入口与导航
└─ docs/                            需求说明书、测试与截图
```

## 运行方法

1. 用 DevEco Studio 打开工程根目录 `mist-archive`。
2. 打开 `File > Project Structure > Signing Configs`，勾选自动签名（需登录华为账号），或使用已有调试证书。
3. 选择 API 17 及以上的模拟器或真机，点击 Run。

命令行构建（不签名，验证可编译）：

```powershell
$env:NODE_HOME='<DevEcoStudio>\tools\node'
$env:DEVECO_SDK_HOME='<DevEcoStudio>\sdk'
$env:JAVA_HOME='<DevEcoStudio>\jbr'
& '<DevEcoStudio>\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@default assembleHap --no-daemon
```

产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`

## 截图

运行截图位于 `docs/screenshots/`，包含首页、探索、线索板、终局判断、结局与持久化恢复。

## 录屏

运行录屏位于 `docs/screen-record/`，演示“接案 → 收集线索 → 条件拦截 → 终局判断 → 结局 → 退出重启恢复”。

## 测试

自动化测试用例与执行记录见 `docs/测试记录.md`。
