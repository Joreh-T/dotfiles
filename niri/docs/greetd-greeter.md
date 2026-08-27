# greetd + noctalia-greeter 部署记录(2026-08-27)

从 GDM3 迁移到 greetd + noctalia-greeter 的完整记录。系统状态 + 排坑结论,重建/排障时先读这里。

## 系统布局

| 组件 | 位置 | 说明 |
|---|---|---|
| greeter 二进制/库/assets | `/opt/greeter-deps/` | 755,greetd 用户可读;含 wlroots 0.20 工具链(见下) |
| greetd 配置 | `/etc/greetd/config.toml` | command 指向 `/opt/greeter-deps/bin/noctalia-greeter-session`,user=`_greetd`(Ubuntu 打包惯例,uid 126) |
| greeter 状态 | `/var/lib/noctalia-greeter/` | greeter.toml + sync.toml;`noctalia msg greeter-sync` 同步壁纸/配色 |
| 切换脚本 | `~/.local/bin/noctalia-greeter-switch` | `switch\|rollback\|status`;源在 dotfiles/bin,setup.sh 链接 |
| 源码 | `~/workspaces/window_mananger_ui/noctalia-greeter` | 本地有 2 个 patch(meson.build stb include + session wrapper LD_LIBRARY_PATH),未建分支提交 |
| display-manager 别名 | `/etc/systemd/system/display-manager.service` | → greetd.service;回滚=指回 gdm.service |
| **getty@tty1** | `systemctl mask getty@tty1.service` | **已 mask,勿恢复!** 见下 |

## 关键坑(按严重程度)

1. **getty@tty1 与 greetd 抢 VT → 登录死循环**(已修复,mask)。
   症状:输密码进桌面 10-30 秒后被弹回 greeter,无限循环。
   机制:greetd 会话占用 tty1 → getty@tty1 退出 → systemd 重启 getty → getty 抢回
   tty1,给会话发 SIGHUP → logind 判会话结束 → greetd 拉新 greeter → 循环。
   Ubuntu 的 GDM 包自己处理了这个互斥,greetd 没有。
   niri 收到 SIGHUP 的证据路径:用带日志的 wrapper(Exec 指向写 /tmp 日志的脚本)抓到。

2. **greetd 下必须用 `niri-session`,不是 `niri --session`**。
   `/usr/share/wayland-sessions/niri.desktop` 的 `Exec=niri-session`(当前状态)。
   - `niri-session` 走 `niri.service` 用户单元 → graphical-session.target +
     xdg-desktop-autostart.target 全链(portal、im-launch 等都靠它)。
   - `niri --session` 只做环境导入,target 链不起来(它们 RefuseManualStart,
     只能由单元依赖拉起),fcitx5/portal 全废。
   - 排查此问题时曾误判 niri-session 是循环根因,实际凶手是 getty(见 1)。

3. **IM 变量(im-config)在 Wayland 下与 fcitx5 冲突**(已修复):
   - `~/.xinputrc` → `run_im none`:掐断 im-config 导出 GTK_IM_MODULE 的链
     (niri-session 的 login shell 会 source /etc/profile.d/im-config_wayland.sh)。
   - `~/.config/autostart/im-launch.desktop` → `Hidden=true`(禁 im-launch autostart)。
   - niri `config.kdl`:`spawn-at-startup "fcitx5"` 直接拉起;environment 块只留
     QT_IM_MODULE + XMODIFIERS(GTK 走 niri 原生 Wayland IM 前端,fcitx5 官方推荐)。
   - 改环境变量类的东西后 `systemctl --user unset-environment GTK_IM_MODULE ...`
     清用户管理器残留(它不会自清)。

4. **构建工具链**(Ubuntu 24.04 noble,参考 `update.sh` 不存在,手动链):
   wlroots 0.20 wrap 全家桶装进 /opt/greeter-deps(wayland 1.26.9/libdrm 2.4.134/
   libdisplay-info/libliftoff/pixman/xkbcommon);noble 的 meson 1.3.2 不够 →
   `~/.local/opt/meson-venv`(venv meson 1.12,软链 ~/.local/bin/meson);
   stb 头手装 /opt/greeter-deps/include/stb/ + meson.build patch;wlroots 间接依赖
   靠 session wrapper 的 LD_LIBRARY_PATH(DT_RUNPATH 不传递)。
   详见记忆 noctalia-daemon-debugging。

## 壁纸轮换改为 systemd timer 调度(2026-08-27)

noctalia 内置 automation 在 shell 启动时强制换一张(还排除当前图),导致
"greeter 显示 X、登录后桌面变 Y"的不和谐。改用 systemd user timer 接管轮换:
- `dotfiles/systemd/user/wallpaper-rotate.{timer,service}`(setup.sh 软链),
  每 2h 整点 `noctalia msg wallpaper-next`(alphabetical 顺序),Persistent 补跑,
  shell 不在时安静失败等下个周期
- `[wallpaper.automation] enabled = false`(内置彻底关闭)
- 效果:换图只因时间到,不因 shell 启动;greeter 与桌面在登录边界永远一致

## greeter 壁纸跟随轮换:零提权轻方案(2026-08-27)

不动 polkit、不用官方 greeter-sync 的拷贝链路。greeter 壁纸路径直接指向
`~/Pictures/Wallpapers/` 里的原图;noctalia 轮换壁纸时由 hook 改
`/var/lib/noctalia-greeter/sync.toml` 的 `path` 行(外科手术式,其余字节不动),
下次 greeter 启动自然读到新图。

前提 ACL(一次性,sudo):
- `setfacl -m u:_greetd:x /home/joreh /home/joreh/Pictures` (目录穿越)
- `setfacl -R -m u:_greetd:rX,d:u:_greetd:rX /home/joreh/Pictures/Wallpapers` (读图+新文件默认)
- `setfacl -m u:joreh:rw /var/lib/noctalia-greeter/sync.toml` (hook 就地写;
  属主仍 _greetd,目录不加写权限 → 不能原子替换,就地 open("w") 单次写入)

链路: noctalia `[hooks] wallpaper_changed = ~/.local/bin/greeter-wallpaper-follow`
(dotfiles/bin/ 同名,setup.sh 已链接) → env NOCTALIA_WALLPAPER_PATH/CONNECTOR →
脚本只接受 `~/Pictures/Wallpapers` 内的文件(路径域校验) → 更新
`[appearance.wallpaper]` + `[appearance.wallpapers.<connector>]` 的 path →
幂等(未变不写)。日志 `~/.cache/noctalia/greeter-follow.log`。

注意:
- 只跟随壁纸;配色/布局仍是上次 greeter-sync 的快照,要刷新跑一次
  `noctalia msg greeter-sync`(它会把 path 写回拷贝模式,下次轮换 hook 自动
  接管回直连模式,共存自洽)
- greeter.toml 的 `wallpaper_blur`(背景模糊)独立于壁纸来源,两者叠加生效
- 轮换事件按显示器分别触发(eDP-1/DP-1 各一次),全局 path 始终跟随最新

## 登录背景模糊(2026-08-27,本地功能)

greeter fork 的 `ubuntu-24.04` 分支(commit 51e2cb2)从 noctalia shell 移植了
BlurCache/CachedLayer(greeter 原本只有 blur shader 是完整实现,缓存层是 stub):
壁纸纹理加载后一次性模糊到 <=1024px FBO(2 轮分离高斯),显示模糊纹理。
- 配置键: `/var/lib/noctalia-greeter/greeter.toml` `[appearance] wallpaper_blur`
  = 0.0..1.0(编译默认 0.55,0=关闭);与 password_style 一样独立于 scheme 来源,
  greeter-sync 不会覆盖它
- 重建: `cd ~/workspaces/window_mananger_ui/noctalia-greeter && ninja -C build-release`
  然后 `sudo env PATH=$HOME/.local/opt/meson-venv/bin:$PATH meson install -C build-release`
  (必须 meson install,不能只拷二进制)
- 生效时机: greeter 是登录时才启动的进程,改完下次注销/重启即可见

## greeter-sync(壁纸/配色同步到登录界面)的三层前提(2026-08-27 补全)

1. noctalia 只在 `/usr/bin`、`/usr/local/bin` 找 `noctalia-greeter` 和
   `noctalia-greeter-apply-appearance`(守护进程启动时注册 IPC,找不到则
   `noctalia msg greeter-sync` 报 unknown command)→ 已软链 /opt 真身到 /usr/local/bin。
2. polkit action 必须装: `/usr/share/polkit-1/actions/org.noctalia.greeter.apply-appearance.policy`
   (从 /opt/greeter-deps/share/polkit-1/actions/ 复制,exec.path 已指向 /opt 真身)。
3. 会话内要有 polkit 认证代理,否则 pkexec 退回文本认证而守护进程无 tty →
   noctalia config `polkit_agent = true`(dotfiles 已改)。
验证: `noctalia msg greeter-sync` 返回 ok,`/var/lib/noctalia-greeter/sync.toml` 的
scheme 变 "Synced"、wallpaper-*.png 出现。

## 遗留小问题

- 开机第一个 greeter 实例偶发闪崩(greetd 日志 "greeter exited without creating a
  session"),greetd 自动重启后正常。不影响使用,待上游修复或下次排查。
- greeter 源码的 2 个本地 patch 建议仿 noctalia fork 模式建 `ubuntu-24.04` 分支提交。
- greeter 启动时 amdgpu 报 DMCUB error(每greeter启动~8条,journal可查):wlroots 0.20
  对 renoir 选的缓冲 modifier 不可扫描输出(配套"cannot be scanned out"刷屏),
  功能正常,纯噪音。kernel cmdline `loglevel=3` 已让其不再打印到 tty(journal 仍留);
  根治需上游修 wlroots/greeter modifier 协商。
- niri-session(/usr/local/bin,手动安装)已改"只导入已设置变量"的 import-environment:
  裸调被 systemd 弃用(stderr 警告到 tty),但固定名单又会让 systemctl 对尚不存在
  的 WAYLAND_DISPLAY/DISPLAY 打 "$VAR not set, ignoring" 到 tty1 —— 这俩由 niri
  session 模式启动后自行导入,niri-session 阶段必然为空。现用 for+eval 过滤。
  原版备份 .bak 同目录。niri 升级重装时注意保留此 patch。

## 回滚到 GDM

```bash
noctalia-greeter-switch rollback   # 或: sudo ln -sfn /lib/systemd/system/gdm.service /etc/systemd/system/display-manager.service && sudo reboot
```
GDM3 未卸载,getty@tty1 保持 mask 也不影响 GDM(GDM 用自己的互斥机制)。
