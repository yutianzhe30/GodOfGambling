# 《赌神》项目文件结构规范

## 整体目录结构

```
GodOfGambling/
├── .godot/                    # Godot引擎自动生成(不提交Git)
├── addons/                     # 插件目录
│   └── dialogue_manager/       # Dialogue Manager插件
├── assets/                     # 所有游戏资源
│   ├── images/                 # 图片资源
│   ├── audio/                  # 音频资源
│   ├── fonts/                  # 字体文件
│   └── shaders/                # Shader文件
├── src/                        # 源代码目录
│   ├── autoload/              # 自动加载的全局单例
│   ├── core/                  # 核心系统(不依赖具体场景)
│   ├── gameplay/              # 游戏玩法相关
│   ├── ui/                    # UI组件
│   └── characters/            # 角色相关
├── scenes/                     # 场景文件(.tscn)
│   ├── game/                  # 游戏场景
│   ├── ui/                    # UI场景
│   └── levels/                # 关卡场景
├── resources/                  # 资源文件(.tres)
│   ├── skills/                # 技能配置
│   ├── items/                 # 道具配置
│   └── dialogues/             # 对话脚本
├── data/                       # 数据配置(JSON/CSV)
└── tests/                      # 测试场景和脚本
```

---

## 详细说明

### 1. addons/ - 插件

```
addons/
└── dialogue_manager/
    ├── assets/
    ├── components/
    ├── dialogue_manager.gd
    └── plugin.cfg
```

**说明**: 第三方插件统一放此处，通过Godot Asset Library安装或手动放置。

---

### 2. assets/ - 游戏资源

```
assets/
├── images/
│   ├── cards/                 # 扑克牌素材
│   │   ├── fronts/           # 牌面 (clubs_2.png ~ spades_ace.png)
│   │   ├── backs/            # 牌背 (back_red.png, back_blue.png)
│   │   └── atlas/            # 图集导出
│   ├── chips/                 # 筹码素材
│   │   ├── chip_1.png
│   │   ├── chip_10.png
│   │   ├── chip_100.png
│   │   └── chip_1000.png
│   ├── characters/            # 角色立绘/头像
│   │   ├── player/           # 主角
│   │   ├── chen_xiaodao/     # 陈小刀
│   │   ├── boss_1/           # 街头Boss
│   │   ├── boss_2/           # 游轮Boss
│   │   └── boss_3/           # 最终Boss
│   ├── ui/                    # UI元素
│   │   ├── buttons/
│   │   ├── frames/
│   │   ├── icons/
│   │   └── backgrounds/
│   ├── effects/               # 特效素材
│   │   ├── glow.png
│   │   ├── particles/
│   │   └── light_rays/
│   └── environments/          # 场景背景
│       ├── street_bg.png     # 澳门街头
│       ├── cruise_bg.png     # 豪华游轮
│       └── final_bg.png      # 最终赌场
├── audio/
│   ├── bgm/                   # 背景音乐
│   │   ├── main_theme.ogg
│   │   ├── battle_1.ogg
│   │   └── battle_2.ogg
│   ├── sfx/                   # 音效
│   │   ├── deal_card.wav
│   │   ├── flip_card.wav
│   │   ├── chips.wav
│   │   ├── win.wav
│   │   ├── lose.wav
│   │   ├── skill_cast.wav
│   │   └── ui_click.wav
│   └── voice/                 # 语音(如有)
│       └── kai_pai.wav       # "开牌！"
├── fonts/
│   ├── main_font.ttf         # 主字体
│   └── pixel_font.ttf        # 像素字体(可选)
└── shaders/
    ├── crt_effect.gdshader   # CRT扫描线
    ├── glow.gdshader         # 发光效果
    └── neon.gdshader         # 霓虹色散
```

---

### 3. src/ - 源代码

```
src/
├── autoload/                  # 全局自动加载脚本
│   ├── game_manager.gd       # 游戏主管理器
│   ├── scene_manager.gd      # 场景切换管理
│   ├── audio_manager.gd      # 音频管理
│   ├── save_manager.gd       # 存档管理
│   └── dialogue_manager.gd   # 对话管理(包装)
│
├── core/                      # 核心系统(纯逻辑)
│   ├── poker/
│   │   ├── card.gd           # 单张牌的数据结构
│   │   ├── deck.gd           # 牌组(洗牌、发牌)
│   │   ├── hand.gd           # 手牌管理
│   │   └── hand_evaluator.gd # 牌型判定器
│   ├── skills/
│   │   ├── skill.gd          # 技能基类
│   │   ├── skill_xray.gd     # 透视眼
│   │   ├── skill_switch.gd   # 偷龙转凤
│   │   └── skill_pressure.gd # 心理施压
│   ├── items/
│   │   ├── item.gd           # 道具基类
│   │   └── item_chocolate.gd # 巧克力
│   └── data/
│       ├── player_data.gd    # 玩家数据
│       └── game_progress.gd  # 游戏进度
│
├── gameplay/                  # 游戏玩法相关
│   ├── poker_game/
│   │   ├── poker_game.gd           # 牌局主控制器
│   │   ├── betting_system.gd       # 下注系统
│   │   ├── turn_manager.gd         # 回合管理
│   │   └── aura_system.gd          # 气场系统
│   ├── ai/
│   │   ├── ai_base.gd              # AI基类
│   │   ├── ai_aggressive.gd        # 激进型AI
│   │   ├── ai_conservative.gd      # 保守型AI
│   │   ├── ai_bluffer.gd           # 偷鸡型AI
│   │   └── ai_evaluator.gd         # 手牌评估器
│   └── effects/
│       ├── effect_manager.gd       # 特效管理
│       └── card_animation.gd       # 卡牌动画
│
├── characters/                # 角色相关
│   ├── character.gd           # 角色基类
│   ├── player.gd              # 玩家角色
│   └── npc.gd                 # NPC角色
│
└── ui/                        # UI组件脚本
    ├── components/
    │   ├── card_display.gd    # 卡牌显示组件
    │   ├── chip_stack.gd      # 筹码堆显示
    │   ├── aura_bar.gd        # 气场条
    │   ├── skill_button.gd    # 技能按钮
    │   └── betting_panel.gd   # 下注面板
    ├── screens/
    │   ├── main_menu.gd
    │   ├── pause_menu.gd
    │   └── game_over.gd
    └── dialogue/
        └── dialogue_ui.gd     # 对话UI控制器
```

---

### 4. scenes/ - 场景文件(.tscn)

```
scenes/
├── game/                      # 游戏场景
│   ├── poker_table.tscn      # 牌桌主场景
│   ├── card.tscn             # 卡牌预制体
│   └── chip.tscn             # 筹码预制体
│
├── ui/                        # UI场景
│   ├── hud.tscn              # 游戏主界面
│   ├── main_menu.tscn        # 主菜单
│   ├── dialogue_box.tscn     # 对话框
│   ├── betting_ui.tscn       # 下注界面
│   ├── skill_panel.tscn      # 技能面板
│   ├── aura_display.tscn     # 气场显示
│   ├── pause_menu.tscn       # 暂停菜单
│   └── settings.tscn         # 设置界面
│
└── levels/                    # 关卡场景
    ├── level_01_street.tscn  # 第一关:澳门街头
    ├── level_02_cruise.tscn  # 第二关:豪华游轮
    └── level_03_final.tscn   # 第三关:最终决战
```

---

### 5. resources/ - 资源配置(.tres)

```
resources/
├── skills/
│   ├── xray_vision.tres      # 透视眼配置
│   ├── card_switch.tres      # 偷龙转凤配置
│   └── mind_pressure.tres    # 心理施压配置
│
├── items/
│   └── chocolate.tres        # 巧克力配置
│
├── characters/
│   ├── player_stats.tres     # 玩家初始数据
│   ├── boss_01_stats.tres    # Boss1数据
│   ├── boss_02_stats.tres    # Boss2数据
│   └── boss_03_stats.tres    # Boss3数据
│
└── dialogues/                 # 对话脚本(.dialogue)
    ├── prologue.dialogue     # 序章
    ├── level_01.dialogue     # 第一关对话
    ├── level_02.dialogue     # 第二关对话
    └── level_03.dialogue     # 第三关对话
```

---

### 6. data/ - 数据文件

```
data/
├── card_definitions.json     # 牌定义(如有需要)
├── level_configs.json        # 关卡配置
└── localization/             # 本地化
    └── zh_CN.json
```

---

### 7. tests/ - 测试

```
tests/
├── unit/
│   ├── test_deck.gd          # 牌组测试
│   ├── test_hand_evaluator.gd # 牌型判定测试
│   └── test_aura_system.gd   # 气场系统测试
└── integration/
    ├── test_poker_game.gd    # 牌局流程测试
    └── test_dialogue.gd      # 对话系统测试
```

---

## 命名规范

### 文件命名
- **场景文件**: `snake_case.tscn` (如 `poker_table.tscn`)
- **脚本文件**: `snake_case.gd` (如 `game_manager.gd`)
- **资源文件**: `snake_case.tres` (如 `xray_vision.tres`)
- **图片文件**: `snake_case.png` (如 `card_back.png`)
- **类名(PascalCase)**: `GameManager`, `PokerTable`

### 节点命名
- **场景根节点**: 与场景名一致，如 `PokerTable`
- **UI控件**: 类型+功能，如 `StartButton`, `AuraBar`
- **游戏对象**: 功能+类型，如 `PlayerHand`, `OpponentArea`

---

## Git忽略规则

```gitignore
# Godot
.import/
.godot/
export.cfg
export_presets.cfg

# OS
.DS_Store
Thumbs.db

# 临时文件
*.tmp
```

---

## 创建脚本

可按此顺序创建初始文件结构：

```bash
# 核心系统
touch src/core/poker/card.gd
touch src/core/poker/deck.gd
touch src/core/poker/hand.gd
touch src/core/poker/hand_evaluator.gd

# 游戏玩法
touch src/gameplay/poker_game/poker_game.gd
touch src/gameplay/ai/ai_base.gd

# 全局管理
touch src/autoload/game_manager.gd
touch src/autoload/scene_manager.gd

# 场景
touch scenes/game/poker_table.tscn
touch scenes/ui/main_menu.tscn
```
