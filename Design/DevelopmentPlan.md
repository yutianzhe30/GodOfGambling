# 《赌神》开发计划书

## 项目概述

| 项目 | 内容 |
|------|------|
| **名称** | 赌神 (God of Gambling) |
| **类型** | 2D 像素风扑克策略RPG |
| **核心玩法** | 梭哈(Show Hand) + 特异功能技能系统 |
| **风格** | 80/90年代香港赌片情怀 |
| **引擎** | Godot 4.2 LTS |
| **语言** | GDScript |

---

## 技术选型总表

| 类别 | 选型 | 说明 |
|------|------|------|
| **游戏引擎** | Godot 4.2 LTS | 稳定版，轻量免费，GDScript友好 |
| **编程语言** | GDScript | 纯2D游戏，无需C# |
| **对话系统** | Dialogue Manager (Nathan Hoad) | Godot最流行的对话插件 |
| **美术风格** | 2D像素风 | 降低美术成本，复古港片感 |
| **美术素材** | Kenney.nl + 自制 | 基础UI+扑克牌素材 |
| **动画系统** | Godot Tween | 内置，发牌/翻牌动画 |
| **Shader特效** | Godot Shader Language | CRT扫描线、霓虹色散、发光 |
| **AI系统** | State Machine (状态机) | 硬编码行为树，无需机器学习 |
| **存档系统** | ConfigFile | 内置，单机游戏暂不考虑加密 |
| **版本控制** | Git | 已初始化 |
| **粒子特效** | GPUParticles2D | 气场爆发、技能特效 |

---

## 阶段一：核心验证 (Week 1-2)

**目标**：搭建Godot项目，实现最基础的梭哈扑克逻辑

### 任务清单

| 序号 | 任务 | 具体内容 | 验收标准 |
|------|------|----------|----------|
| 1.1 | 项目搭建 | Godot 4.2+ 项目初始化，目录结构规划 | 项目可正常运行 |
| 1.2 | 牌组系统 | 52张扑克牌、洗牌算法 | 可随机打乱牌序 |
| 1.3 | 发牌逻辑 | 底牌1张 + 明牌4张的发牌流程 | 发牌顺序正确 |
| 1.4 | 牌型判定 | 同花顺、四条、葫芦、同花、顺子、三条、两对、对子、散牌 | 牌型识别正确 |
| 1.5 | 牌型比较 | 梭哈规则下的牌大小比较 | 能判断胜负 |
| 1.6 | 最简对局 | 发牌 → 下注 → 开牌 → 结算 | 完成一局完整游戏 |

### 目录结构
```
GodOfGambling/
├── assets/
│   ├── images/         # 图片素材
│   ├── audio/          # 音效音乐
│   └── fonts/          # 字体文件
├── scenes/
│   ├── game/           # 游戏场景
│   ├── ui/             # UI场景
│   └── effects/        # 特效场景
├── scripts/
│   ├── core/           # 核心逻辑(扑克、牌型)
│   ├── game/           # 游戏流程
│   ├── ai/             # AI逻辑
│   └── ui/             # UI控制
├── data/               # 游戏数据配置
└── project.godot
```

---

## 阶段二：对话系统 + 基础UI (Week 3)

**目标**：引入对话系统，实现基本对话和流程包装

### 任务清单

| 序号 | 任务 | 具体内容 | 技术要点 |
|------|------|----------|----------|
| 2.1 | 插件安装 | 安装 Dialogue Manager 插件 | Asset Library或Git安装 |
| 2.2 | 对话框UI | AVG风格对话框、角色名、头像框 | Control节点布局 |
| 2.3 | 对话脚本 | 编写第一关教学对话 | Dialogue Manager语法 |
| 2.4 | 角色立绘 | 简单的2D角色差分图 | Sprite2D切换 |
| 2.5 | 场景切换 | 主菜单 → 对话 → 牌桌的流程 | SceneTree.change_scene |
| 2.6 | 教学关 | 陈小刀引导玩家熟悉规则 | 对话+实际操作结合 |

### Dialogue Manager 基础用法
```gdscript
# 对话文件示例 (test.dialogue)
~ start
陈小刀: 小子，想学赌术？先学会梭哈的基本规则！
陈小刀: 每人五张牌，一张底牌四张明牌，最后比大小。
- 我懂了 => ~ understood
- 再讲一遍 => ~ start

~ understood
陈小刀: 好，那我们开始吧！
do GameManager.start_game()
=> END
```

---

## 阶段三：扑克场景完善 (Week 4-5)

**目标**：完整的牌桌视觉与交互

### 任务清单

| 序号 | 任务 | 具体内容 | 技术要点 |
|------|------|----------|----------|
| 3.1 | 牌桌场景 | 赌桌背景、筹码区域、发牌位置 | Node2D布局 |
| 3.2 | 扑克牌素材 | 52张牌面 + 牌背 | SpriteFrames或Atlas |
| 3.3 | 发牌动画 | 牌从牌堆飞到玩家/对手位置 | Tween动画 |
| 3.4 | 翻牌特效 | 底牌翻开时的慢动作和音效 | Tween + Audio |
| 3.5 | 下注系统 | 筹码堆叠、跟注/加注/放弃按钮 | Button + 筹码计数 |
| 3.6 | 筹码视觉 | 不同面额筹码的2D表现 | Sprite2D动态生成 |
| 3.7 | AI基础 | 基于手牌强度的简单决策 | 自信值计算 |

### AI状态机设计
```gdscript
# AI类型枚举
enum AIType { AGGRESSIVE, CONSERVATIVE, BLUFFER }

# AI决策流程
func make_decision():
    var confidence = evaluate_hand_strength()  # 评估手牌强度
    var aura = get_current_aura()              # 当前气场
    
    match ai_type:
        AIType.AGGRESSIVE:   # 激进型 - 手好就加注
            if confidence > 0.7: raise()
            elif confidence > 0.4: call()
            else: fold()
        AIType.CONSERVATIVE: # 保守型 - 牌好才跟
            if confidence > 0.8: raise()
            elif confidence > 0.6: call()
            else: fold()
        AIType.BLUFFER:      # 偷鸡型 - 喜欢虚张声势
            if randf() < 0.3: raise()  # 随机偷鸡
            elif confidence > 0.5: call()
            else: fold()
```

---

## 阶段四：特异功能系统 (Week 6)

**目标**：加入"气场"和技能，核心差异化玩法

### 任务清单

| 序号 | 任务 | 具体内容 | 技术要点 |
|------|------|----------|----------|
| 4.1 | 气场UI | 蓝条进度条，满值发光特效 | ProgressBar + Shader |
| 4.2 | 气场逻辑 | 回合回复、下注获得、巧克力回复 | 数值系统 |
| 4.3 | 技能按钮 | 三个技能的UI按钮和冷却显示 | Button + 状态管理 |
| 4.4 | 技能1-透视眼 | 查看对手底牌一回合 | 修改UI显示层 |
| 4.5 | 技能2-偷龙转凤 | 底牌与牌库顶交换 | 数组swap操作 |
| 4.6 | 技能3-心理施压 | 显示对手自信度(极高/中等/心虚) | 读取AI评估值 |
| 4.7 | 技能特效 | 发动时的粒子+Shader光效 | GPUParticles2D |

### 技能系统架构
```gdscript
# 技能基类
class_name Skill
extends Resource

@export var skill_name: String
@export var aura_cost: int
@export var description: String

func can_use(caster: Character) -> bool:
    return caster.aura >= aura_cost

func use(caster: Character, target: Character) -> void:
    caster.consume_aura(aura_cost)
    execute_effect(caster, target)

func execute_effect(caster: Character, target: Character) -> void:
    push_error("Must override execute_effect()")

# 具体技能实现
class_name XRayVision
extends Skill

func _init():
    skill_name = "透视眼"
    aura_cost = 30
    description = "查看对手底牌"

func execute_effect(caster: Character, target: Character) -> void:
    caster.reveal_opponent_card(target.hidden_card)
```

---

## 阶段五：完整流程包装 (Week 7-8)

**目标**：3个Boss关卡串联，形成可通关的游戏

### 任务清单

| 序号 | 任务 | 具体内容 | 特性 |
|------|------|----------|------|
| 5.1 | Boss 1 | 澳门街头 - 陈小刀 | 只会心理战，无特异功能 |
| 5.2 | Boss 2 | 豪华游轮 - 中级对手 | 会使用"透视眼" |
| 5.3 | Boss 3 | 最终决战 - 仇笑痴 | 掌握"偷龙转凤"，数值高 |
| 5.4 | 剧情串联 | 关卡间的对话和过场 | 线性流程 |
| 5.5 | 存档系统 | 进度、金钱、解锁技能存储 | ConfigFile |
| 5.6 | 音效 | 港风BGM、经典音效 | AudioStreamPlayer |
| 5.7 | Shader后期 | CRT扫描线、霓虹色散 | CanvasItem Shader |

### Boss设计

#### Boss 1: 街头混混
- **AI类型**: BLUFFER (偷鸡型)
- **技能**: 无
- **特点**: 喜欢虚张声势，玩家可学习"心理施压"来识破

#### Boss 2: 游轮高手
- **AI类型**: CONSERVATIVE (保守型)
- **技能**: 透视眼 (30气场)
- **特点**: 会看穿玩家底牌，需要玩家学会隐藏实力

#### Boss 3: 仇笑痴
- **AI类型**: AGGRESSIVE (激进型)
- **技能**: 透视眼 + 偷龙转凤 (50气场)
- **特点**: 数值高，会换牌，需要精巧规划气场击败

---

## 美术资源清单

| 资源 | 来源 | 优先级 |
|------|------|--------|
| 扑克牌52张 | Kenney.nl 或自制 | 高 |
| 筹码(多颜色) | Kenney.nl | 高 |
| 赌桌背景 | 自制简单像素图 | 中 |
| 角色立绘(3个Boss+主角+陈小刀) | 简单像素头像 | 中 |
| UI边框/按钮 | Kenney.nl | 高 |
| 特效素材(光效粒子) | 自制或开源 | 低 |

---

## 音效资源清单

| 音效 | 用途 | 来源 |
|------|------|------|
| 发牌声 | 发牌动画 | 免费音效包 |
| 筹码碰撞 | 下注/结算 | 免费音效包 |
| 翻牌声 | 开牌 | 免费音效包 |
| 胜利音效 | 赢得对局 | 免费音效包 |
| "开牌！" | 经典台词 | 可录制或找素材 |
| BGM | 港风电子乐 | 免费音乐或自制 |

---

## 风险与简化方案

| 原设计难点 | 简化方案 |
|------------|----------|
| QTE和手速判定 | **完全删除**，改为回合制点击发动 |
| 复杂AI/机器博弈 | **状态机硬编码**，基于手牌自信值决策 |
| 多玩法(骰子/麻将) | **放弃**，100%聚焦梭哈 |
| 复杂RPG属性系统 | **线性养成**，打败Boss→气场上限+10 |
| 全配音 | **仅关键音效**，如"开牌！" |
| 多重结局 | **线性剧情**，无分支 |

---

## 里程碑

| 里程碑 | 时间点 | 可玩内容 |
|--------|--------|----------|
| **MVP 0.1** | Week 2结束 | 能玩一局基础梭哈 |
| **MVP 0.2** | Week 3结束 | 有对话和教学 |
| **MVP 0.3** | Week 5结束 | 完整牌桌体验 |
| **Alpha** | Week 6结束 | 有特异功能 |
| **Beta** | Week 8结束 | 3关完整流程可通关 |

---

## 开发原则

> **少即是多 (Less is More)**

1. **优先完成**：基础梭哈逻辑 > 对话 > 牌桌美术 > 技能 > 完整流程
2. **随时可玩**：每个阶段结束都应有可运行的版本
3. **减法思维**：功能做不完就砍，保证核心体验完整
4. **演出>操作**：重点放在发牌/开牌的视觉表现，而非复杂操作

---

## 下一步行动

### 立即开始 (Day 1)
1. 下载安装 Godot 4.2 LTS
2. 创建新项目，设置目录结构
3. 初始化Git仓库
4. 导入 Dialogue Manager 插件

### Day 2-3
1. 实现牌组系统和洗牌
2. 实现牌型判定算法
3. 实现最简对局流程

### Day 4-5
1. 搭建基础对话系统
2. 编写教学对话脚本
3. 连接对话到牌桌

---

*计划制定日期: 2026-03-14*
*版本: v1.0*
