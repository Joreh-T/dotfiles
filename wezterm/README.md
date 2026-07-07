# Wezterm

[Wezterm](https://wezterm.org/) Configurations

## Key Bindings Configuration

Below is a detailed guide to your current WezTerm key bindings.

### 👑 Leader Key (Prefix Key)
* **`Alt + Space`**: Trigger Leader Key

---

### 🌟 Common & General Shortcuts
**Tabs & Panes**
* **`Alt + t`**: Spawn a new Tab
* **`Alt + w`**: Close the current Tab
* **`Alt + q`**: Close the current Pane
* **`Alt + [` / `Alt + ]`**: Switch to the previous/next Tab
* **`Alt + 1` ~ `Alt + 9`**: Switch to Tabs 1 through 9
* **`Ctrl + Alt + p`**: Move the current Pane to a new Window

**Copy & Paste**
* **`Ctrl + Shift + c`**: Copy to Clipboard
* **`Ctrl + Shift + v`**: Paste from Clipboard
* **`Middle Mouse Button`**: Paste from Clipboard
* **`Double/Triple Left Click`**: Copy and clear selection

**Terminal Operations**
* **`Delete`**: Clear viewport (Injects blank lines and sends CTRL-L)
* **`Ctrl + Shift + p`**: Open Command Palette
* **`Alt + n`**: Open Launcher (Fuzzy launch menu items)

**Interface & View**
* **Font Size**: `Ctrl + =` (Increase), `Ctrl + -` (Decrease), `Ctrl + 0` (Reset)
* **Opacity**: `Alt + =` (Increase), `Alt + -` (Decrease), `Alt + 0` (Reset)
* **Scrollback**:
  * **`Shift + ↑/↓`**: Scroll by line
  * **`Shift + PageUp/PageDown`**: Scroll by page
  * **`Shift + Home/End`**: Scroll to top/bottom

---

### 🕹️ Pane Focus Switching (Vim-like)
* **`Ctrl + Shift + ↑/↓/←/→`** or **`Ctrl + Shift + k/j/h/l`**: Switch focus to the Up/Down/Left/Right Pane

---

### 🚀 Leader Key Actions (Press `Alt + Space`, then the following key)
**General Actions**
* **`w`**: Close current Pane
* **`q`**: Quit Application
* **`z`**: Toggle Pane Zoom state (Maximize/Restore)
* **`-`**: Split Pane Vertically (Top/Bottom)
* **`\`**: Split Pane Horizontally (Left/Right)
* **`/`**: Open Search mode
* **`v`**: Activate Copy Mode
* **`d`**: Show Debug Overlay
* **`,`**: Rename current Tab title
* **`Shift + $`**: Rename current Workspace/Session

**Workspaces & Menus**
* **`l`**: Switch to previous Workspace
* **`s`**: Show Workspace list
* **`t`**: Show Tab list
* **`c`**: Show Launcher (Launch menu items)
* **`h`**: Open Command Palette

---

### 🔑 Key Tables (Modes)
Trigger specific operation modes via the Leader Key. Once in a mode, press single keys to execute actions (Press `Enter` or `Esc` to exit the mode):

**1. Move Mode - `Leader + m`**
* **`r`**: Rotate Panes counter-clockwise
* **`s`**: Quick select Pane (Pane Select)
* **`Shift + ←/→`**: Move the current Tab's position relative to others

**2. Resize Mode - `Leader + r`**
* **`↑/↓/←/→`**: Adjust the size of the current Pane in the corresponding direction

**3. Copy Mode - `Leader + y`**
* **`b`**: Copy the current Pane's buffer
* **`p`**: Copy the current Pane's text
* **`l`**: Quick select and copy a line
* **`r`**: Quick select with Regex (Supports one-click extraction and copying of IP addresses, MAC addresses, Emails, URLs, etc.)

**4. Open Mode - `Leader + o`**
* **`u`**: Extract URLs in the terminal and quickly open them in the browser

---

### 🖱️ Other Mouse Shortcuts
* **`Shift + Left Click`**: Open the link at the mouse cursor
* **`Mouse Wheel`**: Scroll 5 lines at a time

