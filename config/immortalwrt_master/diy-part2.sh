#!/bin/bash

#========================================================================================================================
# thomaswxg/amlogic-s9xxx-openwrt
#
# DIY part2
#
# Target:
#   S905 / ARM64 / ImmortalWrt
#
# Custom packages:
#   PassWall
#   OpenClash
#   HomeProxy
#   AdGuard Home
#   Docker
#   Samba
#   TTYD
#
# Fixed:
#   Remove luci-proto-batman-adv because the current target does not
#   provide kmod-batman-adv.
#
# Shadowrocket:
#   External client application.
#   It cannot be compiled into OpenWrt firmware.
#========================================================================================================================


set -e


echo ""
echo "=========================================================="
echo "        ImmortalWrt S905 Custom Package Build"
echo "=========================================================="
echo ""


#========================================================================================================================
# 1. Build information
#========================================================================================================================

echo "=========================================================="
echo " Build information"
echo "=========================================================="

echo ""
echo ">>> OpenWrt source:"
git remote -v || true

echo ""
echo ">>> Current branch:"
git branch --show-current || true

echo ""


#========================================================================================================================
# 2. Install luci-app-amlogic
#========================================================================================================================

echo "=========================================================="
echo " Installing luci-app-amlogic"
echo "=========================================================="

rm -rf package/luci-app-amlogic

git clone \
    --depth=1 \
    -b main \
    https://github.com/ophub/luci-app-amlogic.git \
    package/luci-app-amlogic

if [ ! -d "package/luci-app-amlogic" ]; then
    echo "ERROR: luci-app-amlogic installation failed."
    exit 1
fi

echo "PASS: luci-app-amlogic installed."

echo ""


#========================================================================================================================
# 3. Check PassWall feeds
#========================================================================================================================

echo "=========================================================="
echo " Checking PassWall feeds"
echo "=========================================================="

if grep -q "passwall_packages" feeds.conf.default; then
    echo "PASS: passwall_packages feed found."
else
    echo "WARNING: passwall_packages feed NOT found."
fi

if grep -q "passwall_luci" feeds.conf.default; then
    echo "PASS: passwall_luci feed found."
else
    echo "WARNING: passwall_luci feed NOT found."
fi

echo ""


#========================================================================================================================
# 4. Install PassWall feed packages
#========================================================================================================================

echo "=========================================================="
echo " Installing PassWall feed packages"
echo "=========================================================="

if grep -q "passwall_packages" feeds.conf.default; then
    ./scripts/feeds install -a -p passwall_packages || true
fi

if grep -q "passwall_luci" feeds.conf.default; then
    ./scripts/feeds install -a -p passwall_luci || true
fi

echo "PASS: PassWall feed processing completed."

echo ""


#========================================================================================================================
# 5. Install OpenClash
#========================================================================================================================

echo "=========================================================="
echo " Installing OpenClash"
echo "=========================================================="

rm -rf package/luci-app-openclash
rm -rf /tmp/OpenClash

git clone \
    --depth=1 \
    https://github.com/vernesong/OpenClash.git \
    /tmp/OpenClash

if [ ! -d "/tmp/OpenClash/luci-app-openclash" ]; then
    echo "ERROR: OpenClash package directory not found."
    exit 1
fi

cp -a \
    /tmp/OpenClash/luci-app-openclash \
    package/luci-app-openclash

rm -rf /tmp/OpenClash

if [ ! -d "package/luci-app-openclash" ]; then
    echo "ERROR: OpenClash installation failed."
    exit 1
fi

echo "PASS: OpenClash installed."

echo ""


#========================================================================================================================
# 6. Install HomeProxy
#========================================================================================================================

echo "=========================================================="
echo " Installing HomeProxy"
echo "=========================================================="

rm -rf package/luci-app-homeproxy
rm -rf /tmp/homeproxy

git clone \
    --depth=1 \
    https://github.com/immortalwrt/homeproxy.git \
    /tmp/homeproxy

if [ ! -d "/tmp/homeproxy" ]; then
    echo "ERROR: HomeProxy clone failed."
    exit 1
fi

mkdir -p package/luci-app-homeproxy

cp -a \
    /tmp/homeproxy/* \
    package/luci-app-homeproxy/

rm -rf /tmp/homeproxy

if [ ! -d "package/luci-app-homeproxy" ]; then
    echo "ERROR: HomeProxy installation failed."
    exit 1
fi

echo "PASS: HomeProxy installed."

echo ""


#========================================================================================================================
# 7. Select PassWall
#========================================================================================================================

echo "=========================================================="
echo " Selecting PassWall"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# PassWall
# ==========================================================
CONFIG_PACKAGE_luci-app-passwall=y

EOF

echo "PASS: PassWall selected."

echo ""


#========================================================================================================================
# 8. Select OpenClash
#========================================================================================================================

echo "=========================================================="
echo " Selecting OpenClash"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# OpenClash
# ==========================================================
CONFIG_PACKAGE_luci-app-openclash=y

EOF

echo "PASS: OpenClash selected."

echo ""


#========================================================================================================================
# 9. Select HomeProxy
#========================================================================================================================

echo "=========================================================="
echo " Selecting HomeProxy"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# HomeProxy
# ==========================================================
CONFIG_PACKAGE_luci-app-homeproxy=y

EOF

echo "PASS: HomeProxy selected."

echo ""


#========================================================================================================================
# 10. Select AdGuard Home
#========================================================================================================================

echo "=========================================================="
echo " Selecting AdGuard Home"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# AdGuard Home
# ==========================================================
CONFIG_PACKAGE_adguardhome=y

EOF

echo "PASS: AdGuard Home selected."

echo ""


#========================================================================================================================
# 11. Select Docker
#========================================================================================================================

echo "=========================================================="
echo " Selecting Docker"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# Docker
# ==========================================================
CONFIG_PACKAGE_docker=y
CONFIG_PACKAGE_dockerd=y
CONFIG_PACKAGE_luci-app-dockerman=y

EOF

echo "PASS: Docker selected."

echo ""


#========================================================================================================================
# 12. Select Samba
#========================================================================================================================

echo "=========================================================="
echo " Selecting Samba"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# Samba
# ==========================================================
CONFIG_PACKAGE_samba4-server=y
CONFIG_PACKAGE_luci-app-samba4=y

EOF

echo "PASS: Samba selected."

echo ""


#========================================================================================================================
# 13. Select TTYD
#========================================================================================================================

echo "=========================================================="
echo " Selecting TTYD"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# TTYD
# ==========================================================
CONFIG_PACKAGE_ttyd=y
CONFIG_PACKAGE_luci-app-ttyd=y

EOF

echo "PASS: TTYD selected."

echo ""


#========================================================================================================================
# 14. USB / Storage support
#
# Your S905 box has USB 2.0.
# These packages are useful for USB storage and Samba/Docker data.
#========================================================================================================================

echo "=========================================================="
echo " Selecting USB / Storage support"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# USB / Storage
# ==========================================================
CONFIG_PACKAGE_block-mount=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_usbutils=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-vfat=y

EOF

echo "PASS: USB / Storage support selected."

echo ""


#========================================================================================================================
# 15. Docker kernel support
#========================================================================================================================

echo "=========================================================="
echo " Selecting Docker kernel support"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# Docker kernel support
# ==========================================================
CONFIG_PACKAGE_kmod-veth=y
CONFIG_PACKAGE_kmod-br-netfilter=y
CONFIG_PACKAGE_kmod-tun=y

EOF

echo "PASS: Docker kernel support selected."

echo ""


#========================================================================================================================
# 16. IMPORTANT FIX
#
# The previous build failed because:
#
#   luci-proto-batman-adv
#       requires
#   kmod-batman-adv
#
# but:
#
#   kmod-batman-adv
#
# is not available in the generated package repository for this target.
#
# We do not need Batman-adv for this S905 router.
#
# Therefore remove both entries from .config if they exist.
#========================================================================================================================

echo "=========================================================="
echo " Removing unsupported Batman-adv packages"
echo "=========================================================="

sed -i '/^CONFIG_PACKAGE_luci-proto-batman-adv=/d' .config
sed -i '/^CONFIG_PACKAGE_kmod-batman-adv=/d' .config

echo "PASS: Batman-adv packages removed from configuration."

echo ""


#========================================================================================================================
# 17. Run make defconfig
#========================================================================================================================

echo "=========================================================="
echo " Running make defconfig"
echo "=========================================================="

make defconfig

echo ""
echo "PASS: make defconfig completed."

echo ""


#========================================================================================================================
# 18. Remove Batman-adv again after defconfig
#
# make defconfig may regenerate dependency selections.
# Therefore check and remove them again.
#========================================================================================================================

echo "=========================================================="
echo " Re-checking Batman-adv packages"
echo "=========================================================="

sed -i '/^CONFIG_PACKAGE_luci-proto-batman-adv=/d' .config
sed -i '/^CONFIG_PACKAGE_kmod-batman-adv=/d' .config

echo "PASS: Batman-adv configuration cleaned."

echo ""


#========================================================================================================================
# 19. Run defconfig one final time
#========================================================================================================================

echo "=========================================================="
echo " Running final make defconfig"
echo "=========================================================="

make defconfig

echo ""
echo "PASS: Final make defconfig completed."

echo ""


#========================================================================================================================
# 20. Verify Batman-adv is not selected
#========================================================================================================================

echo "=========================================================="
echo " Verifying Batman-adv configuration"
echo "=========================================================="

if grep -q '^CONFIG_PACKAGE_luci-proto-batman-adv=y' .config; then
    echo "ERROR: luci-proto-batman-adv is still enabled."
    exit 1
fi

if grep -q '^CONFIG_PACKAGE_kmod-batman-adv=y' .config; then
    echo "ERROR: kmod-batman-adv is still enabled."
    exit 1
fi

echo "PASS: Batman-adv packages are disabled."

echo ""


#========================================================================================================================
# 21. Display final selected packages
#========================================================================================================================

echo "=========================================================="
echo " Final selected packages"
echo "=========================================================="

echo ""

grep -E \
'^CONFIG_PACKAGE_(luci-app-passwall|luci-app-openclash|luci-app-homeproxy|adguardhome|docker|dockerd|luci-app-dockerman|samba4-server|luci-app-samba4|ttyd|luci-app-ttyd)=' \
.config || true

echo ""


#========================================================================================================================
# 22. Check package source directories
#========================================================================================================================

echo "=========================================================="
echo " Checking custom package directories"
echo "=========================================================="

if [ -d "package/luci-app-openclash" ]; then
    echo "PASS: OpenClash source exists."
else
    echo "ERROR: OpenClash source missing."
    exit 1
fi

if [ -d "package/luci-app-homeproxy" ]; then
    echo "PASS: HomeProxy source exists."
else
    echo "ERROR: HomeProxy source missing."
    exit 1
fi

if [ -d "package/luci-app-amlogic" ]; then
    echo "PASS: luci-app-amlogic source exists."
else
    echo "ERROR: luci-app-amlogic source missing."
    exit 1
fi

echo ""


#========================================================================================================================
# 23. Display kernel information
#========================================================================================================================

echo "=========================================================="
echo " Kernel configuration"
echo "=========================================================="

grep -E '^CONFIG_KERNEL' .config 2>/dev/null | head -20 || true

echo ""


#========================================================================================================================
# 24. Shadowrocket explanation
#========================================================================================================================

echo "=========================================================="
echo " Shadowrocket"
echo "=========================================================="

echo ""
echo "Shadowrocket is an external client application."
echo "It cannot be compiled into OpenWrt firmware."
echo ""
echo "OpenWrt side:"
echo ""
echo "  PassWall"
echo "  OpenClash"
echo "  HomeProxy"
echo ""

#========================================================================================================================
# 25. Final result
#========================================================================================================================

echo "=========================================================="
echo "       DIY PART2 CONFIGURATION COMPLETED"
echo "=========================================================="

echo ""
echo "Enabled applications:"
echo ""
echo "  [1] PassWall"
echo "  [2] OpenClash"
echo "  [3] HomeProxy"
echo "  [4] AdGuard Home"
echo "  [5] Docker"
echo "  [6] Samba"
echo "  [7] TTYD"
echo ""
echo "Removed unsupported:"
echo ""
echo "  [X] luci-proto-batman-adv"
echo "  [X] kmod-batman-adv"
echo ""
echo "Shadowrocket:"
echo "  External client - NOT included in firmware."
echo ""

echo "=========================================================="
echo " Ready for OpenWrt compilation"
echo "=========================================================="

exit 0
