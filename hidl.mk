# Power HAL
PRODUCT_PACKAGES += \
    android.hardware.power@1.3-impl \
    android.hardware.power@1.3-service

# Wifi
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    android.hardware.wifi.hostapd@1.0 \
    android.hardware.wifi.supplicant@1.1

# GPS HAL
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# GPS force mode
PRODUCT_PROPERTY_OVERRIDES += \
    persist.force.gps.mode=gnss

# Audio HAL
PRODUCT_PACKAGES += \
    android.hardware.audio@5.0-impl \
    android.hardware.audio@5.0-service \
    android.hardware.audio.effect@5.0-impl \
    android.hardware.audio.effect@5.0-service



# Display HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.mapper@2.1-impl

# RenderScript
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# memtrack
PRODUCT_PACKAGES += \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service

# Camera HAL
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-legacy \
    android.hardware.camera.provider@2.4-service

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service

# USB HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.1-service.basic

# Omx
PRODUCT_PACKAGES += \
    android.hardware.media.omx@1.0

# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# Gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

# Vibrator HAL
PRODUCT_PACKAGES += \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service

# ConsumerIr HAL
PRODUCT_PACKAGES += \
    android.hardware.ir@1.0-impl \
    android.hardware.ir@1.0-service

# Light
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service

# LiveDisplay
ifneq ($(wildcard vendor/lineage/.),)
PRODUCT_PACKAGES += vendor.lineage.livedisplay@2.0-service-mediatek
endif

# Sensors HAL
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.2-service.clearkey \
    android.hardware.drm@1.2-service.widevine

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.0-service \
    android.hardware.health@2.0-service.override



# RIL HAL
PRODUCT_PACKAGES += \
    android.hardware.radio@1.0 \
    android.hardware.radio@1.1 \
    android.hardware.radio.deprecated@1.0

# Configstore
PRODUCT_PACKAGES += android.hardware.configstore@1.1-service

# Tether Packages
PRODUCT_PACKAGES += \
    android.hardware.tetheroffload.config@1.0 \
    android.hardware.tetheroffload.control@1.0
