#!/bin/bash
# SPDX-License-Identifier: MIT
# Custom private extensions script
#
# 执行约定：本脚本由 Scripts/Packages.sh 在末尾 source，而 WRT-CORE.yml 的
# "Custom Packages" 步骤执行的是 `cd ./wrt/`，因此此处工作目录为 $GITHUB_WORKSPACE/wrt。
# 包目录 = ./package，feeds 目录 = ./feeds。
# 注意：不要沿用旧版仓库的 ../feeds 写法——那是 `cd ./wrt/package/` 时代的路径。

echo "=========================================="
echo " Running Custom PRIVATE.sh Extension Script "
echo "=========================================="

PKG_DIR="./package"

# 1. 移除 HomeProxy 源码以加快构建并跳过冗余资源下载
#    上游 Packages.sh 会把整个 VIKINGFY/packages 仓库克隆到 ./package/packages，
#    其中的 luci-app-homeproxy 需一并清除，故这里做递归查找而非固定路径删除。
HP_DIRS=$(find "$PKG_DIR" ./feeds -maxdepth 4 -type d -iname "luci-app-homeproxy" 2>/dev/null)
if [ -n "$HP_DIRS" ]; then
	while read -r DIR; do
		rm -rf "$DIR"
		echo "Deleted directory: $DIR"
	done <<< "$HP_DIRS"
else
	echo "Not found directory: luci-app-homeproxy"
fi

# 2. 安装 Lucky (官方作者 gdy666/luci-app-lucky，同时包含 lucky 核心与 luci-app-lucky)
echo "Installing Lucky (gdy666/luci-app-lucky)..."
for NAME in "lucky" "luci-app-lucky"; do
	FOUND_DIRS=$(find ./feeds/luci/ ./feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)
	if [ -n "$FOUND_DIRS" ]; then
		while read -r DIR; do
			rm -rf "$DIR"
			echo "Deleted feed directory: $DIR"
		done <<< "$FOUND_DIRS"
	fi
done

git clone --depth=1 --single-branch --branch main "https://github.com/gdy666/luci-app-lucky.git" "$PKG_DIR/tmp-lucky"
if [ -d "$PKG_DIR/tmp-lucky/luci-app-lucky" ]; then
	cp -rf "$PKG_DIR/tmp-lucky/luci-app-lucky" "$PKG_DIR/"
fi
if [ -d "$PKG_DIR/tmp-lucky/lucky" ]; then
	cp -rf "$PKG_DIR/tmp-lucky/lucky" "$PKG_DIR/"
fi
rm -rf "$PKG_DIR/tmp-lucky"
echo "Lucky installed successfully."

echo "=========================================="
echo "PRIVATE.sh completed successfully."
echo "=========================================="
