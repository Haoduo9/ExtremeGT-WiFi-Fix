# Extreme GT (WiFi Fix Edition for Realme GT6 / ColorOS 14+)

本仓库为基于嘟嘟ski & SCENE 制作的 **Extreme GT (4.2.2)** 模块的深度优化修复版本。

专门针对 **Realme GT6 (PJD110 / 骁龙 8s Gen 3)** 及搭载高通 **WCN785x (kiwi_v2)** 无线芯片的机型，彻底修复原版模块导致的 **"WiFi 反复开关或息屏后假死打不开（必须重启）"** 恶性 Bug。

---

## 🔍 问题根因分析 (Root Cause)

原版 Extreme GT 模块为了追求极致去除温控与防锁帧，采用了以下两处致命操作：
1. **强制禁用系统供电守护服务 `horae`**：
   在 `system.prop` 中注入 `persist.sys.horae.enable=0`。在 ColorOS 14+ 体系下，`horae` 深度参与了外设与 PCIe 射频供电管理。当用户手动关闭 WiFi 或息屏触发深度下电时，高通 WCN785x 芯片直接跌入 PCIe `D3cold` 状态；再次开启时，由于缺失 `horae` 的上电调度，PCIe 链路抛出超时异常（`Data Link Layer Link Active not set in 1000 msec`），驱动卡死在 `is_driver_recovering 1`，系统 WiFi HAL 抛出 `CMD_STA_START_FAILURE` 并永久锁死在 `DisabledState`。
2. **粗暴拦截全量热敏探头**：
   在 `service.sh` 中强行将 `/sys/class/thermal/*` 下的 `wlan-therm`、`xo-therm`、`wcn_temp` 全部锁死为伪造的 29.5℃，导致高通 `kiwi_v2` 驱动在重新初始化和通道表匹配时获取参数失败（`power attr and opm attr is null`）。

---

## 🛠️ 本修复版改动 (Fixes)

1. **移除对 `horae` 的禁用**：
   - 清理 `system.prop` 中的 `persist.sys.horae.enable=0`，保证系统外设供电调度链条完整。
2. **精细化温控放宽**：
   - 彻底剔除对无线射频与晶振温控（`wlan-therm`、`xo-therm`、`wcn_temp`、`oplus_thermal_ipa`）的假数据伪造，保留真实的物理温度反馈，杜绝底层驱动崩溃。
   - 移除对 `/proc/oplus-votable/GAUGE_UPDATE` 电量计节点的暴力干预。
3. **保留全部性能与温控精髓**：
   - ✅ `/vendor/etc/display/thermallevel_to_fps.xml`：1~10 档全部锁定 **144Hz 满血刷新率**。
   - ✅ 快充温控放宽：SVOOC、PPS、PD 高功率快充阶段温控线提升 50℃，满血快充更持久。
   - ✅ 游戏防降频：保留王者荣耀及各类主流游戏的高温限频放宽。
   - ✅ 关闭系统级 `aging_thermal` 性能衰减机制。

---

## 📦 安装与使用

1. 在 Release 页面下载 `ExtremeGT_WiFi_Fix_v4.2.2.zip`。
2. 使用 **KernelSU / Magisk / APatch** 刷入该模块。
3. 重启手机即可享受满血 144Hz 性能，同时彻底告别 WiFi 假死！
