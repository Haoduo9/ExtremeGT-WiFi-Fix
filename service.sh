#!/system/bin/sh
# Extreme GT (WiFi Fix Edition for Realme GT6)
# 针对小六六需求深度定制：
# 1. 核心保留 WiFi 修复：绝不拦截 wlan-therm / xo-therm / wcn_temp / oplus_thermal_ipa（防止高通 kiwi_v2 驱动校准失败与 D3cold 下电假死）
# 2. 核心保留 WiFi 修复：绝不注入 persist.sys.horae.enable=0 与 stop horae（保留系统 PCIe 射频上电调度）
# 3. 其它所有参数全部完全复原原版 Extreme GT：
#    - bat_t 复原为 29500（原版激进电池温控伪装，而非温和的 32000）
#    - shell_t 复原为 33000（原版 33℃ 外壳，而非 35000）
#    - ltepa_ntc、nrpa_ntc 基带射频温控复原回原版伪造 29.5℃
#    - GAUGE_UPDATE 节点强制激活与写入 1000 完整复原

t=29500
bat_t=29500
shell_t=33000

for tz in /sys/class/thermal/*
do
  if [[ -f $tz/temp ]]; then
    case $(cat $tz/type 2>/dev/null) in
      pm8550_gpio03_usr|pm8550vs_g_tz|pm8550b_tz|pm8550vs_c_tz|pa-therm2-sys3)
        echo $t > $tz/emul_temp 2>/dev/null
      ;;
      rear-tof-therm|cam-flash-therm)
        echo $t > $tz/emul_temp 2>/dev/null
      ;;
      batt-therm|usb-therm)
        echo $bat_t > $tz/emul_temp 2>/dev/null
      ;;
      # ⚠️ WiFi 修复核心保全：跳过 wlan-therm, xo-therm, wcn_temp, oplus_thermal_ipa
      # 其它如基带 ltepa_ntc / nrpa_ntc、板温 board_temp / ap_ntc 全部复原原版伪造！
      board_temp|ap_ntc|ltepa_ntc|nrpa_ntc)
        echo $t > $tz/emul_temp 2>/dev/null
      ;;
      shell*)
        echo $shell_t > $tz/emul_temp 2>/dev/null
      ;;
    esac
  fi
done

# 原版外壳温度计算放宽
for i in `seq 0 9`; do
  echo $i $t > /proc/shell-temp 2>/dev/null
done

# 原版 GAUGE_UPDATE 电量计节点干预逻辑（原版复原）
gu=/proc/oplus-votable/GAUGE_UPDATE
if [[ -d $gu ]]; then
  chmod 666 $gu/force_val 2>/dev/null
  echo '1000' > $gu/force_val 2>/dev/null
  chmod 666 $gu/force_active 2>/dev/null
  echo '1' > $gu/force_active 2>/dev/null
fi
