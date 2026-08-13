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
# Shadowrocket:
#   External client application.
#   It cannot be compiled into OpenWrt.
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
# 4. Install PassWall feeds
#========================================================================================================================

echo "=========================================================="
echo " Installing PassWall feed packages"
echo "=========================================================="

./scripts/feeds install -a -p passwall_packages || true
./scripts/feeds install -a -p passwall_luci || true

echo "PassWall feed installation completed."

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

if [ -d "/tmp/OpenClash/luci-app-openclash" ]; then

    cp -a \
        /tmp/OpenClash/luci-app-openclash \
        package/luci-app-openclash

else

    echo "ERROR: OpenClash package directory not found."
    exit 1

fi

rm -rf /tmp/OpenClash

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

mkdir -p package/luci-app-homeproxy

cp -a \
    /tmp/homeproxy/* \
    package/luci-app-homeproxy/

rm -rf /tmp/homeproxy

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

echo "PASS: Storage support selected."

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
# 16. Run defconfig
#========================================================================================================================

echo "=========================================================="
echo " Running make defconfig"
echo "=========================================================="

make defconfig

echo ""
echo "PASS: make defconfig completed."

echo ""


#========================================================================================================================
# 17. Verify packages
#========================================================================================================================

echo "=========================================================="
echo " Checking final package configuration"
echo "=========================================================="

echo ""

grep -E \
'^CONFIG_PACKAGE_(luci-app-passwall|luci-app-openclash|luci-app-homeproxy|adguardhome|docker|dockerd|luci-app-dockerman|samba4-server|luci-app-samba4|ttyd|luci-app-ttyd)=' \
.config || true

echo ""


#========================================================================================================================
# 18. Verify package source directories
#========================================================================================================================

echo "=========================================================="
echo " Checking custom package directories"
echo "=========================================================="

if [ -d "package/luci-app-openclash" ]; then
    echo "PASS: OpenClash source exists."
else
    echo "WARNING: OpenClash source missing."
fi

if [ -d "package/luci-app-homeproxy" ]; then
    echo "PASS: HomeProxy source exists."
else
    echo "WARNING: HomeProxy source missing."
fi

if [ -d "package/luci-app-amlogic" ]; then
    echo "PASS: luci-app-amlogic source exists."
else
    echo "WARNING: luci-app-amlogic source missing."
fi

echo ""


#========================================================================================================================
# 19. Shadowrocket
#========================================================================================================================

echo "=========================================================="
echo " Shadowrocket"
echo "=========================================================="

echo ""
echo "Shadowrocket is an external client application."
echo "It cannot be compiled into OpenWrt firmware."
echo ""
echo "OpenWrt side:"
echo "  PassWall"
echo "  OpenClash"
echo "  HomeProxy"
echo ""

#========================================================================================================================
# 20. Final
#========================================================================================================================

echo "=========================================================="
echo " DIY PART2 CONFIGURATION COMPLETED"
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
echo "Shadowrocket:"
echo "  External client - NOT included in firmware."
echo ""

echo "=========================================================="
echo " Ready for OpenWrt compilation"
echo "=========================================================="

exit 0
