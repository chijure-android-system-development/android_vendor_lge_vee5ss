# BoardConfigVendor.mk — LG L5 II (vee5ss)
# Incluido automáticamente por el build system cuando existe.

# WiFi — driver como módulo kernel (wlan.ko), interfaz nl80211
BOARD_WLAN_DEVICE           := MT6620
WPA_SUPPLICANT_VERSION      := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_mt66xx
BOARD_HOSTAPD_DRIVER        := NL80211
BOARD_HOSTAPD_PRIVATE_LIB   := lib_driver_cmd_mt66xx
WIFI_DRIVER_MODULE_PATH     := /system/lib/modules/wlan.ko
WIFI_DRIVER_MODULE_NAME     := wlan

# Bluetooth — MT6620 combo via UART
BOARD_HAVE_BLUETOOTH        := true
BOARD_HAVE_BLUETOOTH_MTK    := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/lge/vee5ss/bluetooth
