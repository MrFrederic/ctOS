# ctOS Lock Screen — KDE Plasma Port

A native **KDE Plasma Shell lock screen** built from the ctOS Quickshell greeter.
It reuses the visual QML components almost 1:1 while replacing all Quickshell-specific
back-ends (authentication, window management, system data) with their KDE equivalents.

---

## Package layout

```
ctos.lockscreen/
├── metadata.json                          KDE package manifest (KPackageStructure: Plasma/Shell)
└── contents/
    └── lockscreen/
        ├── LockScreen.qml                 Root entry point (role: lockscreenmainscript)
        ├── LockScreenUi.qml               Visual UI wrapper (child of LockScreen.qml)
        └── components/
            ├── Theme.qml                  Colour palette (replaces common/Theme.qml singleton)
            ├── Config.qml                 Font + hardcoded defaults (replaces greeter/config/Settings.qml)
            ├── Accents.qml                Corner accent marks (ported from common/components/)
            ├── Disclaimer.qml
            ├── DeviceId.qml
            ├── FieldGroup.qml             Password field + auth state wiring
            ├── IdentityCard.qml
            ├── MainLayout.qml             Full-screen layout orchestrator
            ├── PasswordField.qml
            ├── Spinner.qml
            ├── Splash.qml                 ctOS intro animation
            ├── Status.qml                 Battery / env info (Plasma DataEngine)
            ├── Surface.qml                Animated border container
            ├── Time.qml                   Clock (Timer + JS Date, replaces SystemClock)
            └── Typewriter.qml
        └── resources/                     SVGs and images copied from greeter/resources/
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| KDE Plasma 6 | kscreenlocker 6.x required |
| `plasma5support` | Needed by `Status.qml` for battery info (`org.kde.plasma.plasma5support`) |
| JetBrainsMono Nerd Font | Used throughout the UI. Install via your package manager or from [Nerd Fonts](https://www.nerdfonts.com/). On Arch: `nerd-fonts-jetbrains-mono` |

---

## Installation & testing

### 1 — Symlink the theme into the KDE local share directory

Run from **inside** the `kde-lockscreen/` directory:

```bash
mkdir -p ~/.local/share/plasma/shells
ln -s "$(pwd)/ctos.lockscreen" ~/.local/share/plasma/shells/ctos.lockscreen
```

Verify KDE can see it:

```bash
kpackagetool6 --list --type Plasma/Shell | grep ctos
# Expected output:
# ctos.lockscreen
```

### 2 — Test the lock screen in a safe window (no real lock!)

```bash
/usr/lib/kscreenlocker_greet --testing --shell ctos.lockscreen
```

This opens the lock screen UI **without actually locking your session**.
In `--testing` mode the `authenticator` object is a stub — typing any password and
pressing Enter will trigger `onSucceeded()` so you can verify animations end-to-end.

### 3 — Apply as the live lock screen theme

> ⚠️  Test thoroughly in step 2 before enabling live — a broken lock screen theme can
> lock you out of your session.

```bash
# Plasma 6
kwriteconfig6 --file kscreenlockerrc --group Greeter --key QmlPath \
    ~/.local/share/plasma/shells/ctos.lockscreen/contents/lockscreen/LockScreen.qml
# Then test with a real lock:
loginctl lock-session
```

Or via **System Settings → Colors & Themes → Global Theme → Lock Screen**.

---

## Customisation

Open `components/Config.qml` to change:

| Property | Default | Description |
|---|---|---|
| `fontFamily` | `"JetBrainsMono Nerd Font"` | Font used throughout |
| `animationsEnabled` | `true` | Set `false` to skip all reveal animations |
| `fakeIdentity` | `{id, class, fullName}` | Identity card panel content |
| `fakeStatus` | `{env, node}` | Status panel fallback values |

Open `components/Theme.qml` to tweak the colour palette.

---

## Architecture differences from the Quickshell version

| Quickshell | KDE Port | File |
|---|---|---|
| `Quickshell.Singleton` | `QtObject` (one instance per component) | `Theme.qml`, `Config.qml` |
| `SystemClock` | `Timer` + `new Date()` | `Time.qml` |
| `UPower.devices` | `org.kde.plasma.plasma5support` `DataSource` | `Status.qml` |
| `AuthManager.respond()` | `authenticator.respond()` + `startAuthenticating()` | `LockScreen.qml` |
| `AuthManager.state` signals | `authState` int property passed down | `LockScreen.qml` → `LockScreenUi` → `MainLayout` → `FieldGroup` |
| `WlSessionLock` / window wrappers | Plain `Item` with magic props (kscreenlocker provides the surface) | `LockScreen.qml` |
| `TerminalManager` log output | **Removed** (not relevant for a lock screen) | — |
