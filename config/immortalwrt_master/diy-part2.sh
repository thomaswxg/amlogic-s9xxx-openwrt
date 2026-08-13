#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: DIY script (After updating feeds — modify the default IP, hostname, theme, add/remove packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source configuration -------------------------------
#
# Set the default LAN IP address
default_ip="192.168.1.1"
ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
# Override default IP if a valid custom IP is provided as the first argument
[[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]] && {
    echo "Modify default IP address to: ${1}"
    sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" package/base-files/*/bin/config_generate
}

# Set the default password for the 'root' user (change empty password to 'password')
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Append source repository information to etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEREPO='github.com/immortalwrt/immortalwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEBRANCH='master'" >>package/base-files/files/etc/openwrt_release

# Configure ccache for build acceleration
# Remove existing ccache settings
sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config
# Apply new ccache configuration
if [[ "${2}" == "true" ]]; then
    echo "CONFIG_DEVEL=y" >>.config
    echo "CONFIG_CCACHE=y" >>.config
    echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >>.config
else
    echo '# CONFIG_DEVEL is not set' >>.config
    echo "# CONFIG_CCACHE is not set" >>.config
    echo 'CONFIG_CCACHE_DIR=""' >>.config
fi
#
# ------------------------------- Main source configuration ends -------------------------------

# ------------------------------- Additional customizations -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone -b main https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Apply patches
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Additional customizations ends -------------------------------
#============================================================================================
# Custom packages
#============================================================================================

echo "=============================================="
echo " Installing custom packages"
echo "=============================================="

# ---------------------------------------------------------
# 1. Update and install PassWall feeds
# ---------------------------------------------------------

echo "Installing PassWall packages..."

./scripts/feeds update passwall_packages
./scripts/feeds update passwall_luci

./scripts/feeds install -a -p passwall_packages
./scripts/feeds install -a -p passwall_luci


# ---------------------------------------------------------
# 2. OpenClash
# ---------------------------------------------------------

echo "Installing OpenClash..."

rm -rf /tmp/OpenClash
rm -rf package/luci-app-openclash

git clone --depth=1 \
    https://github.com/vernesong/OpenClash.git \
    /tmp/OpenClash

cp -a /tmp/OpenClash/luci-app-openclash \
    package/luci-app-openclash

rm -rf /tmp/OpenClash


# ---------------------------------------------------------
# 3. HomeProxy
# ---------------------------------------------------------

echo "Installing HomeProxy..."

rm -rf /tmp/homeproxy
rm -rf package/luci-app-homeproxy

git clone --depth=1 \
    https://github.com/immortalwrt/homeproxy.git \
    /tmp/homeproxy

mkdir -p package/luci-app-homeproxy

cp -a /tmp/homeproxy/* \
    package/luci-app-homeproxy/

rm -rf /tmp/homeproxy


# ---------------------------------------------------------
# 4. Select packages
# ---------------------------------------------------------

echo "Selecting custom packages..."

cat >> .config <<'EOF'

# ==========================================================
# Custom packages
# ==========================================================

# Samba
CONFIG_PACKAGE_samba4-server=y
CONFIG_PACKAGE_luci-app-samba4=y

# TTYD
CONFIG_PACKAGE_ttyd=y
CONFIG_PACKAGE_luci-app-ttyd=y

# PassWall
CONFIG_PACKAGE_luci-app-passwall=y

# OpenClash
CONFIG_PACKAGE_luci-app-openclash=y

# HomeProxy
CONFIG_PACKAGE_luci-app-homeproxy=y

EOF


# ---------------------------------------------------------
# 5. Resolve package dependencies
# ---------------------------------------------------------

echo "Running make defconfig..."

make defconfig


# ---------------------------------------------------------
# 6. Display selected packages
# ---------------------------------------------------------

echo "=============================================="
echo " Selected packages:"
echo "=============================================="

grep -E \
'CONFIG_PACKAGE_(luci-app-passwall|luci-app-openclash|luci-app-homeproxy|luci-app-samba4|samba4-server|luci-app-ttyd|ttyd)=' \
.config || true

echo "=============================================="
echo " Custom packages configuration completed"
echo "=============================================="
