#!/system/bin/sh
# Extreme GT (WiFi Fix Edition for Realme GT6)
# 修复说明：
# 1. 彻底移除对 wlan-therm, xo-therm, wcn_temp, ltepa_ntc 等无线射频温控节点的伪造，防止高通 kiwi_v2 驱动校准失败
# 2. 彻底移除 stop horae 与 persist.sys.horae.enable=0，保留系统对 PCIe 网卡的上电调度
# 3. 彻底移除对 GAUGE_UPDATE 电量计节点的粗暴干预
# 4. 保留 CPU/GPU/外壳温控阈值放宽与防锁频核心逻辑

t=29500
bat_t=32000
shell_t=35000

for tz in /sys/class/thermal/*
do
  if [[ -f $tz/temp ]]; then
    case $(cat $tz/type 2>/dev/null) in
      # 仅针对 CPU、电源芯片、机身表面温控放宽限制
      pm8550_gpio03_usr|pm8550vs_g_tz|pm8550b_tz|pm8550vs_c_tz|pa-therm2-sys3)
        echo $t > $tz/emul_temp 2>/dev/null
      ;;
      rear-tof-therm|cam-flash-therm)
        echo $t > $tz/emul_temp 2>/dev/null
      ;;
      batt-therm|usb-therm)
        echo $bat_t > $tz/emul_temp 2>/dev/null
      ;;
      # ⚠️ 关键修复：绝不拦截 wlan-therm / xo-therm / wcn_temp / oplus_thermal_ipa
      # 让高通无线芯片拥有真实的物理温度反馈，避免 PCIe 驱动崩溃和通道表丢失
      board_temp|ap_ntc)
        echo $t > $tz/emul_temp 2>/dev/null
      ;;
      shell*)
        echo $shell_t > $tz/emul_temp 2>/dev/null
      ;;
    esac
  fi
done

# 放宽外壳温控计算
for i in `seq 0 9`; do
  echo $i $t > /proc/shell-temp 2>/dev/null
done
