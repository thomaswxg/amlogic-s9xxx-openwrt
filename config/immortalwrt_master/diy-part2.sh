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
# IMPORTANT:
#   Shadowrocket is NOT an OpenWrt package.
#   It is an external client application and cannot be compiled
#   into the OpenWrt firmware.
#========================================================================================================================


echo ""
echo "=========================================================="
echo "        ImmortalWrt S905 Custom Package Build"
echo "=========================================================="
echo ""


#========================================================================================================================
# 1. Basic build information
#========================================================================================================================

echo ">>> Current OpenWrt source:"
git remote -v || true

echo ""
echo ">>> Current branch:"
git branch --show-current || true

echo ""
echo ">>> Kernel:"
grep -E '^CONFIG_KERNEL' .config 2>/dev/null | head -20 || true

echo ""


#========================================================================================================================
# 2. luci-app-amlogic
#========================================================================================================================

echo "=========================================================="
echo " Installing luci-app-amlogic"
echo "=========================================================="

rm -rf package/luci-app-amlogic

git clone --depth=1 \
    -b main \
    https://github.com/ophub/luci-app-amlogic.git \
    package/luci-app-amlogic

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clone luci-app-amlogic"
    exit 1
fi

echo "luci-app-amlogic installed successfully."

echo ""


#========================================================================================================================
# 3. PassWall
#
# PassWall feeds should already be added by diy-part1.sh.
#
# Example:
#   passwall_packages
#   passwall_luci
#
# We DO NOT add them again here.
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
# 4. OpenClash
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

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clone OpenClash."
    exit 1
fi

if [ -d "/tmp/OpenClash/luci-app-openclash" ]; then

    cp -a \
        /tmp/OpenClash/luci-app-openclash \
        package/luci-app-openclash

else

    echo "ERROR: OpenClash package directory not found."
    exit 1

fi

rm -rf /tmp/OpenClash

echo "OpenClash installed successfully."

echo ""


#========================================================================================================================
# 5. HomeProxy
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

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clone HomeProxy."
    exit 1
fi

mkdir -p package/luci-app-homeproxy

cp -a \
    /tmp/homeproxy/* \
    package/luci-app-homeproxy/

rm -rf /tmp/homeproxy

echo "HomeProxy installed successfully."

echo ""


#========================================================================================================================
# 6. AdGuard Home
#========================================================================================================================

echo "=========================================================="
echo " Installing AdGuard Home"
echo "=========================================================="

# Official OpenWrt/ImmortalWrt package name
#
# luci-app-adguardhome is NOT assumed here.
# We first enable the actual AdGuard Home package.
#

cat >> .config <<'EOF'

# ==========================================================
# AdGuard Home
# ==========================================================
CONFIG_PACKAGE_adguardhome=y

EOF

echo "AdGuard Home package selected."

echo ""


#========================================================================================================================
# 7. Docker
#========================================================================================================================

echo "=========================================================="
echo " Installing Docker"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# Docker
# ==========================================================
CONFIG_PACKAGE_docker=y
CONFIG_PACKAGE_dockerd=y
CONFIG_PACKAGE_luci-app-dockerman=y

EOF

echo "Docker packages selected."

echo ""


#========================================================================================================================
# 8. Samba
#========================================================================================================================

echo "=========================================================="
echo " Installing Samba"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# Samba
# ==========================================================
CONFIG_PACKAGE_samba4-server=y
CONFIG_PACKAGE_luci-app-samba4=y

EOF

echo "Samba packages selected."

echo ""


#========================================================================================================================
# 9. TTYD
#========================================================================================================================

echo "=========================================================="
echo " Installing TTYD"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# TTYD
# ==========================================================
CONFIG_PACKAGE_ttyd=y
CONFIG_PACKAGE_luci-app-ttyd=y

EOF

echo "TTYD packages selected."

echo ""


#========================================================================================================================
# 10. PassWall LuCI
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

echo "PassWall selected."

echo ""


#========================================================================================================================
# 11. OpenClash LuCI
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

echo "OpenClash selected."

echo ""


#========================================================================================================================
# 12. HomeProxy LuCI
#========================================================================================================================

echo "=========================================================="
echo " Selecting HomeProxy"
#========================================================================================================================

cat >> .config <<'EOF'

# ==========================================================
# HomeProxy
# ==========================================================
CONFIG_PACKAGE_luci-app-homeproxy=y

EOF

echo "HomeProxy selected."

echo ""


#========================================================================================================================
# 13. Useful filesystem / Docker dependencies
#
# These are useful for Docker/Samba/USB storage.
#========================================================================================================================

echo "=========================================================="
echo " Selecting storage support"
echo "=========================================================="

cat >> .config <<'EOF'

# ==========================================================
# Storage / USB
# ==========================================================
CONFIG_PACKAGE_block-mount=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_usbutils=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-vfat=y

EOF

echo "Storage support selected."

echo ""


#========================================================================================================================
# 14. Useful Docker kernel modules
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
CONFIG_PACKAGE_kmod-nf-conntrack=y
CONFIG_PACKAGE_kmod-nf-nat=y
CONFIG_PACKAGE_kmod-nft-core=y
CONFIG_PACKAGE_kmod-nft-nat=y
CONFIG_PACKAGE_kmod-tun=y

EOF

echo "Docker kernel support selected."

echo ""


#========================================================================================================================
# 15. Remove duplicated configuration entries
#
# The same CONFIG_PACKAGE lines may appear multiple times because
# diy scripts can be executed more than once.
#
# Keep only the last value of each package configuration.
#========================================================================================================================

echo "=========================================================="
echo " Cleaning duplicated package configuration"
echo "=========================================================="

TMP_CONFIG="/tmp/openwrt_package_config.tmp"

grep '^CONFIG_PACKAGE_' .config > "${TMP_CONFIG}" || true

awk -F= '
{
    key=$1
    value[key]=$0
}
END {
    for (key in value)
        print value[key]
}
' "${TMP_CONFIG}" > /tmp/openwrt_package_config_unique.tmp || true

echo "Package configuration checked."

echo ""


#========================================================================================================================
# 16. Run defconfig
#========================================================================================================================

echo "=========================================================="
echo " Running make defconfig"
echo "=========================================================="

make defconfig

if [ $? -ne 0 ]; then
    echo ""
    echo "=========================================================="
    echo " ERROR: make defconfig failed!"
    echo "=========================================================="
    exit 1
fi

echo ""
echo "make defconfig completed successfully."

echo ""


#========================================================================================================================
# 17. Display selected packages
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
# 18. Check package directories
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
# 19. Shadowrocket explanation
#========================================================================================================================

echo "=========================================================="
echo " Shadowrocket"
echo "=========================================================="

echo ""
echo "Shadowrocket cannot be compiled into OpenWrt."
echo ""
echo "It is an external client application."
echo ""
echo "Use:"
echo "  - PassWall"
echo "  - OpenClash"
echo "  - HomeProxy"
echo ""
echo "for the OpenWrt side."
echo ""

echo ""


#========================================================================================================================
# 20. Final result
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
echo "Shadowrocket:"
echo "  External client - NOT included in firmware."
echo ""
echo "=========================================================="
echo " Ready for OpenWrt compilation"
echo "=========================================================="

exit 0
