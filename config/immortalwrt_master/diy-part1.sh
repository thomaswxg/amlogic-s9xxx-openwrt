#!/bin/bash

# ============================================================
# ImmortalWrt custom feeds
# S905 / ARM64
# ============================================================

echo "============================================================"
echo " Adding custom feeds"
echo "============================================================"

# ------------------------------------------------------------
# PassWall packages
# ------------------------------------------------------------

echo "Adding PassWall packages feed..."

grep -q '^src-git passwall_packages ' feeds.conf.default || \
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default


# ------------------------------------------------------------
# PassWall LuCI
# ------------------------------------------------------------

echo "Adding PassWall LuCI feed..."

grep -q '^src-git passwall_luci ' feeds.conf.default || \
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default


# ------------------------------------------------------------
# Show configuration
# ------------------------------------------------------------

echo "============================================================"
echo " Current feeds.conf.default:"
echo "============================================================"

grep -E 'passwall|luci' feeds.conf.default || true

echo "============================================================"
echo " DIY part1 completed"
echo "============================================================"
