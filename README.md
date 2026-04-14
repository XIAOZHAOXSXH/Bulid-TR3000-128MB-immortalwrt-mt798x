# Build TR3000 128MB ImmortalWrt MT798x

针对 Cudy TR3000 v1 128MB 的 ImmortalWrt 云编译仓库。

上游源码:
- Repo: `https://github.com/padavanonly/immortalwrt-mt798x-6.6.git`
- Branch: `openwrt-24.10-6.6`

当前仓库会在 GitHub Actions 中完成以下工作:
- 按 `cp -f defconfig/mt7981-ax3000.config .config` 的思路生成 `.config`
- 强制切换到 `cudy_tr3000-v1` 设备，也就是 TR3000 128MB 版本
- 关闭 IPv6 编译选项和默认运行时 IPv6 配置
- 预置 Tesla 相关域名黑名单
- 预编译 Android / iPhone USB 共享驱动
- 默认创建 `usb_tether` 接口，并在插入手机后自动绑定到实际 USB 网卡
- 编译完成后把固件和生成出的 `.config` 上传到 Actions Artifact，并同步发布到 Release

## 目录说明

- `.github/workflows/build.yml`: GitHub Actions 云编译流程
- `scripts/generate_config.sh`: 生成 TR3000 128MB 专用 `.config`
- `scripts/apply_custom_files.sh`: 把仓库内 `files/` 注入上游源码
- `scripts/collect_release_files.sh`: 收集固件、buildinfo 和 `.config`
- `files/etc/uci-defaults/99-tr3000-custom`: 首次启动时应用 IPv6 关闭、域名黑名单和 USB 共享接口
- `files/etc/hotplug.d/net/90-usb-tether`: 热插拔自动识别 Android / iPhone USB 共享网卡
- `files/etc/sysctl.d/99-disable-ipv6.conf`: 运行时 IPv6 sysctl 兜底禁用

## 使用方式

1. 推送本仓库内容到 GitHub。
2. 进入 `Actions` 页面。
3. 手动运行 `Build TR3000 128MB ImmortalWrt`。
4. 编译成功后，到 `Releases` 下载固件，或在 `Artifacts` 里下载完整产物和 `.config`。

## 定制说明

### 1. 关闭 IPv6

- 编译阶段写入 `# CONFIG_IPV6 is not set`
- 首次启动时删除 `wan6`、关闭 `dhcpv6 / ra / ndp`
- 防火墙默认启用 `disable_ipv6`
- sysctl 再次禁用 IPv6，避免遗漏

### 2. Tesla 域名黑名单

以下域名会被写入 dnsmasq 地址黑洞，统一解析到 `127.0.0.1`:

- `api-prd.vn.cloud.tesla.cn`
- `hermes-x2-api.prd.vn.cloud.tesla.cn`
- `signaling.vn.cloud.tesla.cn`
- `hermes-prd.vn.cloud.tesla.cn`
- `hermes-stream-prd.vn.cloud.tesla.cn`
- `telemetry-prd.vn.cloud.tesla.cn`
- `telemetry.tesla.cn`
- `apigateway-x2-trigger.tesla.cn`
- `fleet-api.prd.cn.vn.cloud.tesla.cn`
- `firmware.tesla.cn`
- `log.tesla.cn`
- `vehicle-files.prd.cnn1.vn.cloud.tesla.cn`

### 3. 手机 USB 共享

已预置以下驱动:

- `kmod-usb-net-cdc-ether`
- `kmod-usb-net-cdc-ncm`
- `kmod-usb-net-ipheth`
- `kmod-usb-net-rndis`
- `kmod-usb-wdm`
- `kmod-mii`

默认创建 `usb_tether` DHCP 接口，并自动加入 `wan` 防火墙区域。

## 注意

- Workflow 中没有 SSH / tmate 调试步骤。
- Release 使用 GitHub 自带 `GITHUB_TOKEN` 发布。
- 如果你改了 `files/` 或 `scripts/`，重新运行一次 workflow 即可。
