#!/bin/bash

#========================================================================================================================
# ImmortalWrt custom feeds
# S905 / ARM64
#========================================================================================================================

echo "=============================================="
echo " Adding custom feeds"
echo "=============================================="

# ---------------------------------------------------------
# PassWall
# ---------------------------------------------------------
echo "Adding PassWall feeds..."

sed -i '$a src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '$a src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default

# ---------------------------------------------------------
# Show feeds configuration
# ---------------------------------------------------------
echo "=============================================="
echo " Current feeds.conf.default:"
echo "=============================================="

tail -n 20 feeds.conf.default

echo "=============================================="
echo " DIY part1 completed"
echo "=============================================="
