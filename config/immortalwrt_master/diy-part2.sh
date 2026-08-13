#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: DIY script (After updating feeds — modify the default IP, hostname, theme, add/remove packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

set -e

echo "============================================================"
echo " ImmortalWrt S905 custom firmware"
echo " PassWall + OpenClash + HomeProxy + AdGuard Home"
echo " Samba + TTYD"
echo "============================================================"

# ============================================================
# 1. Default LAN IP
# ============================================================

default_ip="192.168.1.1"

ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"

if [[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]]; then

    echo "Modify default IP address to: ${1}"

    sed -i \
    "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" \
    package/base-files/*/bin/config_generate

fi


# ============================================================
# 2. Set root password
# ============================================================

echo "Setting root password..."

sed -i \
's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' \
package/base-files/files/etc/shadow


# ============================================================
# 3. OpenWrt release information
# ============================================================

echo "Updating OpenWrt release information..."

sed -i \
"s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" \
package/base-files/files/etc/openwrt_release

echo "DISTRIB_SOURCEREPO='github.com/immortalwrt/immortalwrt'" \
>> package/base-files/files/etc/openwrt_release

echo "DISTRIB_SOURCECODE='immortalwrt'" \
>> package/base-files/files/etc/openwrt_release

echo "DISTRIB_SOURCEBRANCH='master'" \
>> package/base-files/files/etc/openwrt_release


# ============================================================
# 4. ccache
# ============================================================

echo "Configuring ccache..."

sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config

if [[ "${2}" == "true" ]]; then

    echo "CONFIG_DEVEL=y" >> .config
    echo "CONFIG_CCACHE=y" >> .config
    echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >> .config

else

    echo '# CONFIG_DEVEL is not set' >> .config
    echo '# CONFIG_CCACHE is not set' >> .config
    echo 'CONFIG_CCACHE_DIR=""' >> .config

fi


# ============================================================
# 5. luci-app-amlogic
# ============================================================

echo "Installing luci-app-amlogic..."

rm -rf package/luci-app-amlogic

git clone \
--depth=1 \
-b main \
https://github.com/ophub/luci-app-amlogic.git \
package/luci-app-amlogic


# ============================================================
# 6. PassWall
# ============================================================

echo "============================================================"
echo " Installing PassWall"
echo "============================================================"

./scripts/feeds update passwall_packages
./scripts/feeds update passwall_luci

./scripts/feeds install -a -p passwall_packages
./scripts/feeds install -a -p passwall_luci


# ============================================================
# 7. OpenClash
# ============================================================

echo "============================================================"
echo " Installing OpenClash"
echo "============================================================"

rm -rf package/luci-app-openclash

git clone \
--depth=1 \
https://github.com/vernesong/OpenClash.git \
/tmp/OpenClash

cp -a \
/tmp/OpenClash/luci-app-openclash \
package/luci-app-openclash

rm -rf /tmp/OpenClash


# ============================================================
# 8. HomeProxy
# ============================================================

echo "============================================================"
echo " Installing HomeProxy"
echo "============================================================"

rm -rf package/luci-app-homeproxy

git clone \
--depth=1 \
https://github.com/immortalwrt/homeproxy.git \
/tmp/homeproxy

mkdir -p package/luci-app-homeproxy

cp -a \
/tmp/homeproxy/* \
package/luci-app-homeproxy/

rm -rf /tmp/homeproxy


# ============================================================
# 9. AdGuard Home
# ============================================================

echo "============================================================"
echo " Installing AdGuard Home"
echo "============================================================"

# AdGuard Home is provided by the OpenWrt packages feed.
# We only select the package here.

# ============================================================
# 10. Select packages
# ============================================================

echo "============================================================"
echo " Selecting custom packages"
echo "============================================================"

cat >> .config <<'EOF'

# ==========================================================
# Custom packages for S905
# ==========================================================

# ----------------------------------------------------------
# Samba
# ----------------------------------------------------------

CONFIG_PACKAGE_samba4-server=y
CONFIG_PACKAGE_luci-app-samba4=y

# ----------------------------------------------------------
# TTYD
# ----------------------------------------------------------

CONFIG_PACKAGE_ttyd=y
CONFIG_PACKAGE_luci-app-ttyd=y

# ----------------------------------------------------------
# PassWall
# ----------------------------------------------------------

CONFIG_PACKAGE_luci-app-passwall=y

# ----------------------------------------------------------
# OpenClash
# ----------------------------------------------------------

CONFIG_PACKAGE_luci-app-openclash=y

# ----------------------------------------------------------
# HomeProxy
# ----------------------------------------------------------

CONFIG_PACKAGE_luci-app-homeproxy=y

# ----------------------------------------------------------
# AdGuard Home
# ----------------------------------------------------------

CONFIG_PACKAGE_adguardhome=y

EOF


# ============================================================
# 11. Resolve dependencies
# ============================================================

echo "============================================================"
echo " Running make defconfig"
echo "============================================================"

make defconfig


# ============================================================
# 12. Show selected packages
# ============================================================

echo "============================================================"
echo " Selected custom packages"
echo "============================================================"

grep -E \
'CONFIG_PACKAGE_(luci-app-passwall|luci-app-openclash|luci-app-homeproxy|adguardhome|luci-app-samba4|samba4-server|luci-app-ttyd|ttyd)=' \
.config || true


echo "============================================================"
echo " DIY part2 completed successfully"
echo "============================================================"
