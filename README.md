# RMUC 2027 场地 Unity 模型

本仓库提供 RMUC 2027 赛季比赛场地的 Unity 仿真资源，包含可直接打开的完整工程、场地预制体、
显示网格、同源几何点集与配置清单。资源由官方 CAD 发布件（`RMUC2027_V1.0.0.stp`）经 OCCT 三角化
与 Blender 导出生成，用于仿真环境搭建、感知算法验证与三维可视化。

> 本仓库提供的是**内部仿真基准**，不是规则书坐标，也不是实机裁判系统坐标，且未经过实机定位
> 精度验收。具体适用范围见[数据边界](#数据边界与适用范围)，使用前请务必阅读。

---

## 内容概览

| 路径 | 大小 | 说明 |
| --- | --- | --- |
| `Project/` | — | 完整 Unity 工程（Unity 2022.3.62f1），可直接打开 |
| `Project/Assets/Field/field_visual_m.fbx` | 185,370,700 B | 场地显示网格，7,071,310 三角面，42 种 CAD 材质 |
| `Project/Assets/Field/field_geometry_m.ply` | 197,723,182 B | 同源几何点集，7,048,495 顶点，供点云与几何核对 |
| `Project/Assets/Field/field_geometry.json` | 843 B | 几何清单：实例数、包围盒、毫米至米变换矩阵 |
| `Project/Assets/Rmvf/Prefabs/OfficialField.prefab` | 100,414 B | 场地唯一预制体，81 个实例 / 40 个定义 |
| `Project/Assets/Rmvf/Scenes/U1Field.unity` | 32,910 B | 场地场景，引用上述预制体，含光学相机与平行光 |
| `Project/Assets/Rmvf/Editor/OpenFieldOnLoad.cs` | 3,117 B | 首次打开工程时自动载入场地场景的编辑器脚本 |
| `Project/Packages/manifest.json` | — | 仅声明内置模块，不依赖第三方包或网络解析 |
| `Project/ProjectSettings/` | — | 工程设置，构建场景列表已指向 `U1Field` |
| `reference/field.json` | 3,615 B | 场地与仿真传感器的唯一配置 |
| `一键打开场地.bat` | 3,142 B | Windows 一键启动脚本，自动定位 Unity Editor |

工程使用内置渲染管线（非 URP / HDRP），场地场景不引用任何自定义脚本，移除
`Assets/Rmvf/Editor` 不影响场景显示，仅失去自动载入能力。

---

## 环境要求

| 项目 | 要求 |
| --- | --- |
| Unity Editor | 2022.3.62f1（`4af31df58517`）；其他版本可打开但会触发工程升级 |
| 渲染管线 | 内置渲染管线（Built-in），无需额外包 |
| 操作系统 | Windows 10 / 11（一键脚本）；工程本身跨平台 |
| 磁盘 | 首次导入后 `Library/` 约数 GB |
| Git | 克隆需安装 Git LFS（见[大文件与 Git LFS](#大文件与-git-lfs)） |

Unity 许可与账号登录由 Unity 官方机制管理，本仓库不提供任何破解或免许可方案。

---

## 快速开始

### 方式一：一键启动（Windows）

1. 完整克隆仓库，包含 Git LFS 对象。
2. 双击根目录 `一键打开场地.bat`。
3. 脚本按以下顺序定位 Unity Editor：环境变量 `RMVF_UNITY_EXE` → 同目录 `unity_path.txt`
   首行 → Unity Hub 标准安装目录 → 已知非标准路径 → Hub 下其他已装版本。
4. 定位成功后以 `-projectPath` 打开 `Project/`，导入完成后自动载入 `U1Field` 场景。

若编辑器安装在非标准路径，可在仓库根新建 `unity_path.txt`，首行写入 `Unity.exe` 的完整路径。

### 方式二：手动打开

用 Unity Hub 添加 `Project/` 目录，以 2022.3.62f1 打开，随后在 Project 面板双击
`Assets/Rmvf/Scenes/U1Field.unity`。

### 关于双击 `.unity` 文件

`.unity` 是 YAML 格式的资产文件，不是可执行文件，Windows 未为其注册文件关联，在资源管理器
中双击不会启动 Unity。场景必须由 Unity Editor 在某个工程内打开，因此本仓库提供的是完整工程
而非单独的场景文件。

### 首次导入开销

场地网格包含 7,071,310 个三角面与 42 种材质，首次导入通常需要数分钟，`Library/` 目录随后
增长至数 GB。导入期间场景可能显示不完整，属正常现象。

---

## 场地数据规格

| 指标 | 数值 |
| --- | --- |
| 三角面数 | 7,071,310 |
| 顶点数 | 7,048,495 |
| 实例数 / 定义数 | 81 / 40 |
| CAD 材质数 | 42 |
| 三角化弦长 | 2.0 mm |
| 包围盒（米） | (-0.000, -0.501, -0.301) → (28.000, 15.502, 3.498) |
| 完整底板尺寸 | 约 28 × 16.003 m |
| 名义比赛区域 | 28 × 15 m |
| 标定 ID | `sim_rmuc2027_u1_v1` |
| `map_ready` | `false` |

完整底板保留了 CAD 外侧底板与 1.5° 双侧倾斜，未按名义尺寸强行缩放。

源文件共 110,586 个 BRep 面，其中 1 个退化面（部件 `0_1_1_32`，面索引 5431，面积约
2.71e-20 mm²）没有三角形，未参与网格化，已在 `field_geometry.json` 中登记。

---

## 坐标与单位约定

- X / Y 轴沿 CAD 的 X / Y 轴，Z = 0 取中轴地面折线高程。该 Z 基准为本项目的转换选择，
  与官方规定无关。
- CAD 毫米坐标经统一矩阵换算为米，平移量为 `(13.99998853897, 5.8756563235, 1.6403436765)`，
  缩放仅在派生网格时乘一次 `0.001`。
- 场地至 Unity 的换基为 `Unity(x, y, z) = Field(-y, z, x)`；场地根节点执行一次换基，
  子节点保持 CAD 原始朝向。
- 长度单位统一为米，角度单位为度。

上述矩阵与换基关系同时记录在 `field_geometry.json` 与 `reference/field.json` 中。

---

## 资源生成流程

```
RMUC2027_V1.0.0.stp  (官方 CAD 发布件，毫米)
        │  OCCT 7.8 读取 XCAF，按弦长 2.0 mm 三角化
        ▼
   米制三角网格  ──┬── Blender 4.2.3 导出 ──▶ field_visual_m.fbx（显示）
                   └── 同源写出 ─────────────▶ field_geometry_m.ply（几何核对）
        │
        └── 实例装配信息 ──▶ field_geometry.json ＋ OfficialField.prefab
```

FBX 与 PLY 同源，实例与材质数量一致。预制体使用逐实例原始三角面构建，碰撞采用逐实例静态
非凸 `MeshCollider`，未使用整体凸包近似。

---

## 大文件与 Git LFS

`field_visual_m.fbx`（185 MB）与 `field_geometry_m.ply`（197 MB）超出 GitHub 对普通文件的
100 MB 单文件上限，因此通过 Git LFS 存储，规则见 `.gitattributes`。

克隆前请先安装 Git LFS：

```bash
git lfs install
git clone https://github.com/diaofenyuan/RMUC_2027map_unity.git
```

若已克隆但大文件为指针文本，执行：

```bash
git lfs pull
```

如仅需查看工程结构与文本资产，可跳过 LFS 下载：

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/diaofenyuan/RMUC_2027map_unity.git
```

GitHub 对 Git LFS 设有存储与月流量配额，下载方下载 382 MB 二进制对象会消耗相应流量。

### 文件校验值

| 文件 | SHA-256 |
| --- | --- |
| `field_visual_m.fbx` | `9ee719596d28923248a26bf3f2ccca187f9974bc357860aea9b68bce2a2f6fec` |
| `field_geometry_m.ply` | `794d1736e76f3092f08aa268097fc1cfa3e39cd4d6a034b86b19f72229681076` |

---

## 数据边界与适用范围

以下限制是资源的固有属性，不属于待修复的缺陷：

1. **非规则坐标**：本资源的坐标基准为内部仿真选择，与规则书规定的场地坐标系、实机裁判
   系统坐标系均不保证一致。跨系统对表前必须自行核对锚点。
2. **`map_ready = false`**：该场地未经实机定位精度验收，不得作为建图精度、定位精度或
   融合精度的验收依据。
3. **几何一致性不等于定位精度**：三角面规模、包围盒、锚点偏差等指标只描述资产转换质量与
   同几何求交的一致性，与机器人定位误差无关。
4. **无外部标定**：本仓库不包含相机内参、雷达外参或时间同步信息。`reference/field.json`
   中的传感器参数仅为仿真配置，不得作为实机标定结果使用。
5. **单一退化面**：见[场地数据规格](#场地数据规格)，该面在网格中不存在三角形，依赖该
   局部几何的分析需自行处理。

---

## 来源与许可

- 场地几何来源于 RMUC 官方发布的 `RMUC2027_V1.0.0.stp`，版权归赛事主办方所有。
- 本仓库提供的是该 CAD 的派生资产（三角网格、预制体、场景与配置），仅供赛事相关的
  仿真研究与教学使用。
- **再分发或商业使用前，请自行确认赛事主办方对模型传播的许可条款。** 本仓库不对上游
  许可作出任何承诺或替代。
- 仓库内的工程脚手架、编辑器脚本与配置文件由本仓库维护者编写，未附带开源许可证；
  如需在衍生产品中引用，请通过 Issue 联系维护者。

本仓库不包含原项目代码、ROS 节点、激光雷达插件与模型训练产物。

---

## 版本信息

| 项目 | 值 |
| --- | --- |
| 资源版本 | RMUC2027 V1.0.0 |
| 标定 ID | `sim_rmuc2027_u1_v1` |
| Unity 版本 | 2022.3.62f1 (`4af31df58517`) |
| 三角化工具 | OCCT 7.8 |
| 导出工具 | Blender 4.2.3 |
| 最近更新 | 2026-10-19 |

---

## 反馈

资源导入异常、坐标疑问或使用问题，请提交 Issue 并附上 Unity 版本、控制台日志与复现步骤。
涉及精度或验收结论的问题，请同时说明所依据的坐标基准与参照物。
