[English](README_EN.md)

# Gen1Recomp 中文版

Gen1Recomp 中文版是 [bryanthaboi/gen1recomp](https://github.com/bryanthaboi/gen1recomp) 的中文本地化分支。

本项目使用 LÖVE2D 和 Lua 重新实现《宝可梦 红／蓝／黄／金／银／水晶》的运行逻辑。它不是传统 Game Boy 模拟器：程序会读取玩家提供的正版 ROM，验证版本并提取运行所需的数据，之后由项目自身实现的 Lua 引擎运行游戏。

> 本仓库不包含、不提供也不会下载任何 ROM。请使用自己合法取得的游戏 ROM。

> **安全提醒：** 本项目及上游均与 `gen1recomp.com` 无关。请勿从该冒充网站下载程序；上游认可的官方来源是 GitHub 仓库、Discord 和 [gen1re.com](https://gen1re.com)。

## 中文版做了什么

这个分支以尽量减少上游代码改动、方便后续同步官方 `main` 分支为原则，主要进行应用界面的中文本地化：

- 应用默认显示简体中文，不再提供语言选择项。
- 汉化启动器、ROM 导入、模组管理、设置、存档同步等应用界面。
- 增加中文字体支持，解决中文显示为方框的问题。
- 保留上游模组系统、ROM 提取流程和游戏运行逻辑。
- 保留 RG34XXSP Stock OS 64 位掌机支持。

目前的汉化范围不包括：

- ROM 中的游戏剧情、对话、招式、道具和地图文本。
- 第三方模组自行提供的英文内容。

因此，使用美版原版 ROM 时，启动器等应用界面会显示中文，但游戏内部文本仍然是英文。

## 它是模拟器吗

不是传统意义上的模拟器，也不是把原版汇编代码直接转译后运行。

项目的工作流程大致如下：

1. 玩家在应用中选择 ROM。
2. 导入器校验 ROM 的 SHA-1，确认它是受支持的版本。
3. 程序从 ROM 中解析并提取地图、图片、音频程序和其他游戏数据。
4. 提取结果保存在应用的私有缓存目录中，ROM 本身不会复制到缓存。
5. 后续启动直接读取生成的数据，一般不需要再次选择 ROM。
6. 游戏最终仍在 Gen1Recomp 应用中，由它自己的 Lua/LÖVE2D 引擎运行。

## 支持的 ROM

当前只接受指定的美版原版 ROM。汉化 ROM、修改版 ROM、其他地区版本或版本不匹配的 ROM 会因为 SHA-1 不一致而被拒绝。

| 游戏 | SHA-1 |
| --- | --- |
| 红版 | `ea9bcae617fdf159b045185467ae58b2e4a48b9a` |
| 蓝版 | `d7037c83e1ae5b39bde3c30787637ba1d4c48ce2` |
| 黄版 | `cc7d03262ebfaf2f06772c1a480c7d9d5f4a38e1` |
| 金版 | `d8b8a3600a465308c9953dfa04f0081c05bdcb94` |
| 银版 | `49b163f7e57702bc939d642a18f591de55d92dae` |
| 水晶版 1.0 | `f4cd194bdee0d04ca4eac29e09b8e4e9d818c133` |
| 水晶版 1.1 | `f2f52230b536214ef7c9924f483392993e226cfb` |

金版、银版和水晶版目前仍属于第二世代第一阶段支持，相关引擎还在开发中；其中水晶版在启动器中标记为测试版。

## 快速开始

### 使用发布版

1. 启动 Gen1Recomp。
2. 选择要导入的游戏版本。
3. 点击“导入 ROM”，选择对应的 `.gb` 或 `.gbc` 文件。
4. 等待校验和数据提取完成。
5. 点击“开始游戏”。

同一份应用可以并排导入红、蓝、黄、金、银和水晶版，各版本使用独立存档。

### 从源码运行

需要安装 LÖVE 11.x。在项目目录执行：

```bash
love .
```

也可以先使用项目脚本完成初始化：

```bash
scripts/setup.sh --rom "/path/to/your/game.gb"
scripts/run.sh
```

### 低性能设备

“选项 → 性能模式”可以按设备性能缩减可选画面效果：高档开启全部效果，均衡档关闭 3D 倾斜，低档还会关闭大范围缩放并限制帧率；自动档会根据设备类型选择。该设置只影响显示效果，不改变固定步长的游戏逻辑，也不会丢失用户原有的倾斜和缩放偏好。详见 [新功能说明](docs/new-features.md#performance-tier-low-end-devices)。

### 战斗规则集

“选项 → 战斗规则”决定第一世代战斗采用忠实原版还是现代修正规则。两者使用相同的伤害公式，区别在于是否保留原版卡带的特殊行为和著名 Bug；设置保存在 `options.lua`，模组也可以注册自己的规则集。

| 规则 | 忠实原版 `gen1_faithful` | 现代修正 `modern_clean` |
| --- | --- | --- |
| `oneIn256Miss` | 100% 命中率招式仍可能在随机值为 255 时落空 | 100% 命中率招式必定命中 |
| `critUsesBaseSpeed` | 会心率读取基础速度 | 保持相同 |
| `critIgnoresStages` | 会心伤害忽略能力等级 | 计算能力等级 |
| `focusEnergyBug` | 聚气会错误地把会心率降为四分之一 | 聚气按预期提高会心率 |
| `enemyUnlimitedPP` | 敌方不消耗 PP | 敌方会耗尽 PP 并使用挣扎 |
| `hyperBeamSkipRechargeOnKO` | 破坏光线击倒目标后跳过蓄力 | 始终需要蓄力 |

## 在线功能

启动器新增“在线”页面。连接后可以查看在线玩家及其游戏和规则，创建或加入对战房间、观战、组织锦标赛，也可以在本机存档或不同玩家的存档之间交换宝可梦。进入比赛时会直接启动对应游戏和规则集，比赛结束后返回在线页面。房间会校验双方引擎版本、规则集以及密封自定义 Cart；游戏内原有的 LINK 菜单仍然只用于局域网连接。

本地开发环境如果已经准备了 `.runtime/love.app`，可在 macOS 上执行：

```bash
cd "/path/to/gen1recomp-cn"
.runtime/love.app/Contents/MacOS/love .
```

关闭窗口或在终端按 `Control + C` 即可停止。

## 基本操作

| 操作 | 键盘 | 手柄 |
| --- | --- | --- |
| 移动 | 方向键／WASD | 十字键／左摇杆 |
| A 键 | Z／Enter／Space | A |
| B 键 | X／Backspace | B |
| Start | Escape | Start |
| Select | Tab／Shift | Back／Select |

可在游戏内的“选项 → 按键设置”中修改绑定。

### 快捷键

| 按键 | 功能 |
| --- | --- |
| `-`／`=` | 缩小／放大 |
| `1` | 切换游戏速度 |
| `2` | 切换颜色模式 |
| `3` | 切换倾斜效果 |
| `4` | 切换缩放级别 |
| `F1` | 保存 |
| `F2` | 读取 |
| `F10` | 打开／关闭模组管理器 |

## 启动参数与移动端链接

| 参数 | 作用 |
| --- | --- |
| `--game=red` | 跳过启动器并直接启动指定版本；也支持 `blue`、`yellow`、`gold`、`silver`、`crystal` 及首字母缩写 |
| `--cart=id` | 启动指定 ID 的已安装自定义 Cart |
| `--slot=2` | 加载指定存档槽编号或 ID |
| `--launcher` | 强制打开启动器 |
| `--no-sync` | 启动前跳过关联设备的存档同步；等同于 `POKEPORT_LAUNCH_SYNC=0` |
| `--update` | 启动前检查更新，发现新版本时更新并重启；也支持 `-update` |

设备启用存档同步后，快捷入口默认会在启动游戏前同步，避免“继续游戏”加载已经落后的存档。同步期间按任意键可以跳过；发生冲突时会返回启动器，让玩家选择需要保留的副本。

Android 和 iOS 也可以通过 URL 发出同样的启动请求：

```text
gen1recomp++://launch?game=red
```

URL 参数与桌面命令行选项对应：

| URL | 作用 |
| --- | --- |
| `gen1recomp++://launch?game=red` | 直接启动红版 |
| `gen1recomp++://launch?game=red&cart=my_cart` | 启动已安装的 `my_cart` |
| `gen1recomp++://launch?game=red&slot=2` | 启动红版并选择存档槽 2 |
| `gen1recomp++://launch?game=red&launcher=1` | 打开红版对应的启动器页面 |
| `gen1recomp++://launch?game=red&sync=0` | 跳过存档同步 |
| `gen1recomp++://launch?game=red&update=1` | 启动前检查更新 |

`game` 接受与 `--game` 相同的完整名称和缩写；布尔参数支持 `1`/`0`、`true`/`false`、`yes`/`no` 和 `on`/`off`。包含 URL 保留字符的值需要进行百分号编码。未知参数会被忽略，无效的游戏或 Cart 会回退到启动器。

Android 测试命令：

```bash
adb shell am start -a android.intent.action.VIEW \
  -d 'gen1recomp++://launch?game=red' \
  com.theboisclub.pokemonred
```

iOS 模拟器测试命令：

```bash
xcrun simctl openurl booted 'gen1recomp++://launch?game=red'
```

在实体 iPhone 或 iPad 上，可以从备忘录、信息或 Safari 等能够转交自定义 URL 的应用打开该链接。

## 模组与 3D 效果

Gen1Recomp 原工程提供的是模组平台和运行能力，并不默认开启体素 3D 画面。想看到 3D 或体素效果，需要另外安装兼容的视觉模组。

一般安装流程：

1. 在启动器中打开“模组”。
2. 选择“导入模组”。
3. 选择模组的 ZIP 文件，不要提前解压。
4. 在模组列表中启用它。
5. 确认模组支持当前导入的游戏版本，然后重新进入游戏。

模组有自己的许可证和兼容范围。应用汉化、游戏文本汉化与视觉模组是三个不同层级，不能互相替代。

## RG34XXSP 掌机

上游发布版提供面向 Anbernic RG34XXSP Stock OS 64-bit MOD 的 PortMaster 风格安装包。详细安装方式、目录结构、操作说明和故障排查见：

- [RG34XXSP 安装文档](docs/anbernic-rg34xxsp.md)

低性能设备建议在“选项 → 性能”中选择“低”或“自动”。降低性能档位只影响倾斜、缩放和帧率等表现，不会改变游戏逻辑。

## 便携模式

桌面版默认把存档、设置和 ROM 提取缓存写入操作系统的用户数据目录。在应用或源码入口旁创建空文件 `portable.txt` 后，可改为把这些数据保存在程序所在目录，适合移动硬盘或 U 盘使用。

便携模式仅适用于 Windows、Linux 和 macOS，不适用于 Android 或 iOS。

## 常见问题

### 为什么导入汉化 ROM 会失败？

导入器会严格检查 ROM 的 SHA-1。汉化会改变 ROM 内容和哈希，因此当前无法直接导入。要支持汉化 ROM，需要为该 ROM 单独适配校验、地址布局和数据提取规则，不能只关闭哈希检查。

### 为什么应用是中文，游戏对话仍是英文？

当前汉化的是 Gen1Recomp 应用界面。游戏对话来自 ROM 提取的数据，不属于同一套应用本地化文本。

### 为什么安装后没有 3D？

3D 体素效果由第三方模组提供，不是项目默认内容。需要单独导入并启用兼容模组。

### 为什么中文显示成方框？

请确认正在使用本中文分支的完整构建，并且中文字体资源没有在打包或复制过程中丢失。

### ROM 导入后还需要保留吗？

程序不会把 ROM 复制进缓存。成功提取后，后续启动通常不再要求 ROM，但建议自行妥善保管合法备份。

## 开发与同步原则

本分支以官方仓库的 `main` 分支为上游基础。中文改动尽量集中在本地化目录和少量入口代码中，以降低同步上游更新时的冲突。

Switch 构建在 CI 与正式发布中的区别（CI vs release）、触发条件及产物说明见
[Switch 构建文档](docs/switch-build.md)。

主要中文资源位于：

```text
src/locales/zh_CN.lua
src/locales/zh_CN_app.lua
```

应用新增英文文案时，应优先通过 `Strings()` 接入翻译表，而不是在公共绘制层全局替换字符串。

## 法律与安全说明

- 本项目不隶属于任天堂、宝可梦公司或 Game Freak。
- 本仓库不提供 ROM，也不帮助获取盗版 ROM。
- 请仅使用自己合法取得的游戏副本。
- 不要从冒充项目官方站点的第三方网站下载程序。
- 官方上游来源是 [bryanthaboi/gen1recomp](https://github.com/bryanthaboi/gen1recomp)。

## 相关链接

- [中文分支](https://github.com/zhangjiyz/gen1recomp-cn)
- [上游项目](https://github.com/bryanthaboi/gen1recomp)
- [上游开发者指南](https://github.com/bryanthaboi/gen1recomp/wiki/Guide-Developer-Setup)
- [模组开发 Wiki](https://github.com/bryanthaboi/gen1recomp/wiki)
- [AI 使用说明](AIDisclosure.md)

## 致谢

感谢 Gen1Recomp 原作者及所有贡献者，也感谢 [pret](https://github.com/pret) 社区维护的 [pokered](https://github.com/pret/pokered) 反汇编项目。

## iOS 安装与主屏幕入口

在 iOS 启动器中长按已导入的游戏卡带并选择“主屏幕”，即可为该游戏生成独立入口。自定义 Cart 可以在对应列表行选择同一操作。应用会通过 Safari 打开配置描述文件，玩家需要按照系统提示前往“设置”批准安装。生成的入口会保留游戏或 Cart 的封面，并使用相同的 `gen1recomp++://launch` URL 启动。

<div>
    <a href="https://intradeus.github.io/http-protocol-redirector?r=sidestore://source?url=https://github.com/bryanthaboi/gen1recomp/raw/refs/heads/main/mobile/ios/app-repo.json"><img src="./.github/resources/sidestore-badge.png" alt="Add to SideStore" height="60"></a>
    &nbsp;
    <a href="https://intradeus.github.io/http-protocol-redirector?r=feather://source/https://github.com/bryanthaboi/gen1recomp/raw/refs/heads/main/mobile/ios/app-repo.json"><img src="./.github/resources/feather-badge.png" alt="Add to Feather" height="60"></a>
    &nbsp;
    <a href="https://intradeus.github.io/http-protocol-redirector?r=altstore://source?url=https://github.com/bryanthaboi/gen1recomp/raw/refs/heads/main/mobile/ios/app-repo.json"><img src="./.github/resources/altstore-badge.png" alt="Add to AltStore" height="60"></a>
    &nbsp;
    <a href="https://github.com/bryanthaboi/gen1recomp/releases/latest"><img src="./.github/resources/github-badge.png" alt="Download from GitHub" height="60"></a>
</div>

本中文分支会在尊重上游项目、许可证和第三方内容版权的前提下持续同步和完善。
