# Extreme GT (WiFi Fix Edition for Realme GT6 / ColorOS 14+)

基于嘟嘟ski & SCENE 制作的 **Extreme GT (4.2.2)** 官方纯原版模块制作的极限精简修复版。

专为 **Realme GT6 (PJD110 / 骁龙 8s Gen 3)** 及搭载高通 **WCN785x (kiwi_v2)** 无线芯片的机型打造，彻底解决原版模块导致的 **"关闭 WiFi 或长时间息屏后 WiFi 硬件假死打不开（必须重启）"** 恶性 Bug。

---

## ⚡ 终极定版策略 (Zero Regression)

本版本摒弃了先前版本对温控文件与配置的激进改动，**100% 保持原版 Extreme GT 的全部温控与快充规则完全不动**：
* ✅ **120W SVOOC 满血秒充**：保留原版全部充电配置文件与温控逻辑，绝不限流。
* ✅ **全局 144Hz 锁帧**：保留全套 display 刷新率与调度配置。
* ✅ **原版激进性能温控**：原版所有的温度伪造与调度配置原封不动。

---

## 🔍 WiFi 假死根因与修复 (Root Cause & Fix)

### 根因：
原版 Extreme GT 在 ColorOS 14+ 下会使高通 WCN785x（PCIe `0000:01:00.0`）在关闭 WiFi 或深度息屏时跌入 PCIe `D3cold` 深度断电状态。再次开启时因缺少底层硬件上电时序，导致 PCIe 链路抛出超时，驱动卡在 `is_driver_recovering 1` 并触发 `CMD_STA_START_FAILURE` 永久锁死。

### 修复：
仅在 `service.sh` 顶部注入硬件级 PCIe 电源常驻控制：
```bash
if [[ -d /sys/bus/pci/devices/0000:01:00.0/power ]]; then
  echo on > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null
fi
```
将网卡总线电源强制锁定在 `on`（常驻活跃 `D0` 态），**从物理层杜绝跌入 D3cold 假死**，真正做到 0 副作用、0 性能损耗、快充满血！

---

## 📦 安装说明

1. 下载 Release 中的 `ExtremeGT_WiFi_Fix_v4.2.2.zip`。
2. 使用 **KernelSU / Magisk / APatch** 刷入并重启设备即可。
