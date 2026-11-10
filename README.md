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

以下截图均在本地模拟器（API 17，1260×2720）上由设备截屏命令 `snapshot_display` 实拍，未经后期处理，存放于 `docs/screenshots/`。

| 文件 | 画面内容 |
| --- | --- |
| `01-home.jpeg` | 案件入口页：标题、剧情摘要、“接案调查”“读档继续”“重开案件”三个入口 |
| `02-explore.jpeg` | 探索页：图书馆闭架书库场景、当前节点描述、场景切换与选项列表 |
| `03-lib-clue.jpeg` | 检起纸屑后获得“借阅登记本残页”，页头提示“获得线索” |
| `05-restore.jpeg` | 结束进程后重启，页头显示“已恢复到上次进度”，阶段徽标为“调查中”、线索 1/6 |
| `06-lib-complete.jpeg` | 图书馆三个节点全部走完，线索累计至 3 条 |
| `07-lab-conflict.jpeg` | 实验楼 302 播放磁带，记录录音中的争执，页面给出“关键信息”反馈 |
| `08-dorm-complete.jpeg` | 宿舍区收起纸条、核对值夜表完成，线索累计至 6 条 |
| `09-clue-board.jpeg` | 线索板：6/6 线索、三条推理条件（物证链、动机、时间线）全部“已成立” |
| `10-finale.jpeg` | 终局判断页：三条推理条件逐项核对，可提交结论 |
| `11-ending-a.jpeg` | 结局 A“移交校方”：物证链闭合·动机成立·时间线吻合，6/6 线索 |
| `12-ending-b.jpeg` | 结局 B“独自结案”：仅 4/6 线索，“证据存在缺口，结论未被采信” |
| `13-ending-a-replay.jpeg` | 录屏流程中重走主线再次达成的结局 A |
| `14-restore-after-replay.jpeg` | 录屏末尾：`aa force-stop` 后重启，恢复至结局 A 存档 |

## 录屏

运行录屏的两个等价文件（内容完全相同，任选其一）：

| 文件 | 格式 | 说明 |
| --- | --- | --- |
| `docs/demo/mist-archive-demo.mp4` | H.264 / MP4 | 通用格式，Windows 媒体播放器、手机、浏览器均可直接打开 |
| `docs/demo/mist-archive-demo.avi` | MJPEG / AVI | 原始归档文件，部分系统需安装解码器才能播放 |

两个文件的画面均为 630×1360、3 fps、时长约 65 秒、210 帧。

录制方式：模拟器侧以 `snapshot_display` 连续抓取真实屏幕帧，逐帧无损归档后封装为视频，无剪辑、无补帧。内容顺序为：

1. 图书馆闭架书库捡起纸屑、向老管理员说明来意、取走备用钥匙、核对磁带标签（线索 3/6）；
2. 实验楼三层调取门禁记录、上 302 播放磁带、记下录音中的争执（线索 5/6，动机成立）；
3. 宿舍区收起纸条、核对值夜表（线索 6/6，时间线成立）；
4. 线索板核对三条推理条件 → 终局判断 → 提交结论 → 结局 A；
5. `aa force-stop` 结束后台进程，再 `aa start` 重启，页面提示“已恢复到上次进度”并停在结局 A。

## 自动化测试

测试用例位于 `entry/src/ohosTest/ets/test/`，共 16 条（规则引擎 15 条 + 框架自检 1 条），覆盖正常、边界、异常三类，运行于 ohosTest 测试模块。

```powershell
# 构建并安装测试包
hvigorw --mode module -p module=entry@ohosTest assembleHap --no-daemon
hdc install -r entry-ohosTest-signed.hap
# 在设备上执行
hdc shell aa test -b com.sunrui.mistarchive -m entry_test -s unittest OpenHarmonyTestRunner -w 30
```

执行结果：`Tests run: 16, Failure: 0, Error: 0, Pass: 16, Ignore: 0`。用例清单、Mock 输入、预期与实际结果、原始输出见 [`docs/test/自动化测试报告.md`](docs/test/自动化测试报告.md)。

## 仓库与账号

- GitHub 仓库：<https://github.com/sunrui20210407115/mist-archive>
- 本人 GitHub 账号：`sunrui20210407115`
- 承担范围：独立完成，负责全部模块（模型、服务、视图、测试、文档与集成）
