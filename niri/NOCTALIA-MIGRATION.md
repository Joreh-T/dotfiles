# Noctalia v5 适配记录

**日期**: 2026-08-13
**环境**: Ubuntu 24.04.4 LTS · niri 26.04 · 笔记本 Yoga + 两块外接 2560×1440

---

## 一、背景与目标

用户原有一个近乎默认的 niri 配置(Catppuccin 主题,waybar 状态栏)。尝试过 **DankMaterialShell (DMS)** 和 **Noctalia v5** 两个完整桌面 shell,最终选定 **Noctalia v5**:

- **DMS 弃用原因**: 需要 Ubuntu 25 / Qt ≥ 6.6,而系统是 24.04(Qt 6.4)——硬性不兼容。
- **Noctalia 胜出**: 原生 C++/Wayland,无 Qt/Gtk 依赖,目标是 niri 一等公民,一体化提供 bar/启动器/通知/锁屏/剪贴板/壁纸/托盘。

最终用 Noctalia 作为**唯一桌面 shell**,替换了 waybar/fuzzel/dunst/swayidle/swaylock/cliphist/polkit。

---

## 二、关键难点与解法(都踩过坑)

### 1. 构建依赖缺 wireplumber-0.5 ❌→ 补丁降级到 0.4 ✅
- Noctalia v5 构建需要 `wireplumber-0.5` 头文件,Ubuntu 24.04 只有 `wireplumber-0.4`。
- **解法**: 改 `meson.build` 用 `wireplumber-0.4`;`wireplumber_mixer.cpp` 里 3 处 0.5→0.4 API 差异(`wp_core_new` 少一个参数、`wp_core_load_component` 变同步、移除 `_finish`)。

### 2. 缺 `stb_image_resize2.h` ❌→ 仓库内 vendored ✅
- 24.04 的 `libstb-dev` 没有这个新头文件,meson 配置阶段报错。
- **解法**: 从 stb v2.18 把单个头文件 vendor 到 `~/src/noctalia/stb/`,并把 meson 检查指向它。

### 3. 需要 GCC 14 的 `<print>` ❌→ 装 `g++-14` ✅
- 系统默认 gcc-13 无 `<print>`(C++23)。
- **解法**: `apt install g++-14`——它是版本化命令,**不接管默认 gcc-13**,不影响系统其他部分。

### 4. 需要 sdbus-c++ v2 ❌→ 源码构建到隔离前缀 ✅
- Noctalia 用 sdbus-c++ **v2** API(296 处调用),24.04 只有 v1.4.0。
- **解法**: 从源码构建 sdbus-c++ **v2.3.1**,装到隔离前缀 `~/noctalia-deps`(soname `.so.2`,与系统 v1 `.so.1` 不冲突)。Noctalia 通过 RPATH 链接到它,系统其他程序不受影响。

### 5. 需要 libwayland ≥ 1.23 的 `wl_proxy_get_display` ❌→ 补丁单点调用 ✅
- 24.04 的 libwayland 是 1.22,缺这个 API。全树只有 `virtual_keyboard_service.cpp:95` 用了它。
- **解法**: 给 `VirtualKeyboardService` 加 `wl_display*` 成员,由 `bind()` 传入,直接 `wl_display_flush(m_display)`——行为等价。**审查中发现第一版有 bug**(`cleanup()` 把 m_display 置空),修复后复审通过。

### 6. niri spawn 找不到 `noctalia` ❌→ `environment {}` 加 PATH ✅
- **根因**: niri 进程从登录管理器继承 PATH,**不含 `~/.local/bin`**,所以 `spawn "noctalia"` 静默失败(快捷键全无响应)。
- **解法**: `config.kdl` 顶部加 `environment { PATH "..." }`,把 `~/.local/bin` 加进 niri 的 PATH。这是**系统性调试**定位的根因。

### 7. 重启后 waybar 又出现 ❌→ mask systemd 服务 ✅
- **根因**: `/usr/lib/systemd/user/waybar.service` 被发行版预设为 enabled,`WantedBy=graphical-session.target`,每个图形会话自动启动,绕过 niri config。
- **解法**: `systemctl --user mask waybar.service`(创建指向 /dev/null 的链接,彻底阻止自启,可逆)。**对 GNOME 无影响**(GNOME 不用 waybar)。

### 8. 登录弹 "Disconnected Network" 通知 ❌→ 禁用 nm-applet autostart ✅
- **根因**: `nm-applet`(NetworkManager 托盘)通过 `/etc/xdg/autostart/nm-applet.desktop` 自启,登录瞬间网络未就绪误报通知。**不是 Noctalia 发的**。
- **解法**: 在 `~/.config/autostart/nm-applet.desktop` 放用户级覆盖(`Hidden=true`),禁用其自启。GNOME 自带网络指示器,不需要 nm-applet,**对 GNOME 无影响**。

---

## 三、最终配置清单

### niri —— `~/.config/niri/config.kdl`
- `environment { PATH }`: 加 `~/.local/bin`,让 spawn 能找到 noctalia
- 三屏输出:
  - `eDP-1`(内置 2880×1800)→ scale 1.75
  - `DP-1`(USB-C 外接 2560×1440)→ scale 1
  - `DP-2`(坞 HDMI 外接 2560×1440)→ scale 1
- spawn-at-startup: 仅 `noctalia`(绝对路径)+ dbus 环境更新
- 快捷键: `Mod+Space`/`Mod+D` → Noctalia 启动器;`Super+Alt+L` → Noctalia 锁屏
- 原有: 圆角、阴影、动画、prefer-no-csd、gaps 10

### Noctalia —— `~/.config/noctalia/config.toml`
- 主题: `builtin = "Noctalia"`(默认配色,用户选择保持)
- bar: thickness 44, widget_spacing 10, scale 1.3(图标调大)

### 隔离工具链(不污染系统)
- `~/noctalia-deps/`: sdbus-c++ v2.3.1 隔离安装(头文件+libs+pkg-config)
- `~/.local/bin/noctalia`: 编译产物(27MB)
- `~/src/noctalia`: 源码 + 补丁

### 系统级覆盖(记录在案)
- `systemctl --user mask waybar.service` → waybar 不自动启动
- `~/.config/autostart/nm-applet.desktop` (Hidden=true) → nm-applet 不自启
- 详见 `docs/autostart-overrides.md`

---

## 四、git 提交记录(本次适配)

```
46c2a24 docs: record autostart overrides (nm-applet, waybar)
e903fba fix(niri): add ~/.local/bin to PATH via environment block (root cause)
971d32b feat(niri): bind Mod+Space/Mod+D to noctalia launcher, Super+Alt+L to lock
e1b08ad feat(niri): noctalia sole shell — remove dunst/swayidle/cliphist/polkit spawns
c98eb2a feat(niri): noctalia sole bar (absolute path), remove waybar spawn
a9b2134 fix(niri): external monitors scale 1.0
cd7276a feat(niri): 3-monitor config (eDP-1 1.75, DP-1/DP-2 1.25→1.0)
026cbd2 feat(noctalia): catppuccin config + niri autostart (later reverted to default theme)
34aa542 chore: record noctalia build deps
65f023a docs: noctalia adoption plan
```

---

## 五、回滚方式

- **还原配置**: `git -C ~/.config/niri checkout pre-noctalia`(回到 Catppuccin waybar 版)
- **卸载 Noctalia**: 删 `~/.local/bin/noctalia`、`~/.config/noctalia/`、`~/noctalia-deps/`、`~/src/noctalia/`
- **恢复 waybar**: `systemctl --user unmask waybar.service`
- **恢复 nm-applet**: 删 `~/.config/autostart/nm-applet.desktop`
- **还原默认编译器**: `apt remove g++-14`(默认 gcc-13 从未被改动)

---

## 六、遗留 / 可选项

- **壁纸**: Noctalia 默认壁纸在生效;用户可选 `noctalia msg wallpaper-set` 或 `Mod+Y` 换壁纸
- **外接屏高刷**: DP-1/DP-2 支持 144Hz,当前跑 60Hz,需要可加 mode
- **主题切换**: 改 `config.toml` 的 `builtin`(Catppuccin/Ayu/Nord 等),热重载生效
- **nm-applet**: 若以后需要其网络托盘,删掉覆盖文件即可恢复
