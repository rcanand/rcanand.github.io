---
title: Mac Power User Finder customizations Cheatsheet
date: 2026-06-30
tags:
  - mac
  - finder
  - poweruser
  - cheatsheet
  - ai-generated
excerpt: "Mac Finder is grossly underconfigured by default for power users. These are some (AI generated) tweaks to customize it. Warning: Some are verified, others are not, so review each one carefully before using."
---

This is a list of AI generated power user tricks to customize Mac Finder. 

❗ AI generated - can be risky. Be careful to verify each one and using only after assuring that it is safe and is what you want.
❗ Not all steps apply to everyone - I picked a few and applied them for myself. Others may find other things they like, so keeping most of the AI generated tricks here.

# macOS Finder Power User Cheatsheet

> Commands marked `killall Finder` require a Finder restart to take effect.
> ⚠️ Some legacy `defaults write` keys may be silent no-ops on macOS 26 Tahoe — always verify with `defaults read com.apple.finder`.

---

## Ranked by Power User Utility

---

### 1. Show Hidden Files (dotfiles)
```bash
defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder
```
Toggle on the fly: **`Cmd + Shift + .`** — no restart needed. This is the one toggle you'll use constantly.

---

### 2. Always Show All File Extensions
```bash
defaults write NSGlobalDomain AppleShowAllExtensions -bool true; killall Finder
```
Domain is `NSGlobalDomain`, not `com.apple.finder`. Affects all apps.

---

### 3. Show Full POSIX Path in Window Title
```bash
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true; killall Finder
```
Title bar shows `/Users/you/projects/app/src` instead of just `src`.

---

### 4. Show Path Bar (Bottom Breadcrumb)
```bash
defaults write com.apple.finder ShowPathbar -bool true && killall cfprefsd && sleep 1 && killall Finder
```
Toggle: **`Cmd + Option + P`**. Right-click any segment in the path bar to jump there, open in Terminal, or copy path.

---

### 5. Show Status Bar (Item Count + Disk Space)
```bash
defaults write com.apple.finder ShowStatusBar -bool true; killall Finder
```
Toggle: **`Cmd + /`**

---

### 6. Search Current Folder by Default (Not "This Mac")
```bash
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"; killall Finder
```
`SCcf` = current folder. `SCev` = This Mac (Apple's default). Or set via GUI: **Finder → Settings → Advanced → "When performing a search" → Search the Current Folder**.

---

### 7. Set Default View Mode (List / Column / Icon / Gallery)
```bash
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"; killall Finder
```
View codes: `Nlsv` = List, `clmv` = Column, `icnv` = Icon, `glyv` = Gallery.
> ⚠️ This sets the *default for new windows*. Existing folders remember their own view via `.DS_Store`. To force globally, see #19 (nuke `.DS_Store` files).

---

### 8. Keep Folders on Top When Sorting by Name
```bash
defaults write com.apple.finder _FXSortFoldersFirst -bool true; killall Finder
```
Or GUI: **Finder → Settings → Advanced → "Keep folders on top: In windows when sorting by name"**. Also has a separate checkbox for Desktop.

---

### 9. Copy File Path to Clipboard (Native — No Automator Needed)
**`Cmd + Option + C`** — copies POSIX path of selected item(s).
Or: **hold Option + right-click** → "Copy [filename] as Pathname".
Or: drag file/folder from Finder into Terminal (auto-escaped path).

---

### 10. Go to Any Path (Including Hidden Folders)
**`Cmd + Shift + G`** — type any POSIX path: `~/.ssh`, `/usr/local/bin`, `~/Library/Caches`. Supports tab-completion.

---

### 11. Reveal ~/Library Folder
```bash
chflags nohidden ~/Library
```
No `killall` needed. Also accessible via **Go → Go to Folder (`Cmd+Shift+G`) → `~/Library`**.

---

### 12. Reveal /Volumes Folder
```bash
sudo chflags nohidden /Volumes
```

---

### 13. Disable .DS_Store on Network Volumes
```bash
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
```

---

### 14. Disable .DS_Store on USB Volumes *(new — verified)*
```bash
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
```
This key exists and is confirmed in multiple dotfile repos (Mathias Bynens, nickytonline).

---

### 15. Disable Extension Change Warning
```bash
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false; killall Finder
```
Stops the "Are you sure you want to change the extension?" dialog.

---

### 16. Disable Empty Trash Warning
```bash
defaults write com.apple.finder WarnOnEmptyTrash -bool false; killall Finder
```
Also: **`Cmd + Option + Shift + Delete`** empties trash with no confirmation dialog (one-time, no setting change).

---

### 17. Allow Quitting Finder via Cmd+Q
```bash
defaults write com.apple.finder QuitMenuItem -bool true; killall Finder
```
Adds "Quit Finder" to the Finder menu. Quitting hides desktop icons until Finder relaunches.

---

### 18. Disable All Finder Animations (Snappier Navigation)
```bash
defaults write com.apple.finder DisableAllAnimations -bool true; killall Finder
```
Disables window open/close animations, Get Info animations, etc.

---

### 19. Force ALL Folders to Use Your Default View (Nuke .DS_Store)
```bash
# Step 1: Set your desired view options in Finder → Cmd+J → "Use as Defaults"
# Step 2: Delete all .DS_Store files so every folder falls back to defaults:
find ~ -name .DS_Store -delete 2>/dev/null
# and/or target specific folders/volumes
# find ~/Projects ~/Documents ~/Desktop -name .DS_Store -delete 2>/dev/null
killall Finder
```
> ⚠️ Aggressive — wipes per-folder view memories everywhere. Every folder will now use your default view style. On macOS 15 Sequoia+, the "Use as Defaults" button propagates more reliably than older versions, so this nuke may be less necessary.
> ⚠️ Also: changes the modified time on all folders that had .DS_Store in it, so use ONLY if ok with that.
> ⚠️ Dont use / instead of ~ : Using / will require sudo, will wipe out everything but can take a very long time, depending on your external volumes, etc.

---

### 20. Column Auto-Resize to Fit Filenames *(new — verified macOS 26.1+)*
**macOS 26.1 Tahoe+:** View → Show View Options (in Column View) → check **"Resize columns to fit filenames"**. This is a universal setting for all column view windows.

**macOS 13 Ventura – 15 Sequoia (hidden setting):**
```bash
defaults write com.apple.finder _FXEnableColumnAutoSizing -bool YES; killall Finder
```
> ⚠️ Known limitation: only resizes based on *currently visible* filenames, not the longest in the entire folder. Doesn't dynamically resize when scrolling.

---

### 21. Expand All "Get Info" Panes by Default
```bash
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true; killall Finder
```
Get Info window opens with General, Open With, and Sharing & Permissions sections all expanded.

---

### 22. Auto-Open Finder Window When Volume Is Mounted
```bash
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true; killall Finder
```

---

### 23. Set New Finder Window Target (Home Folder Example)
```bash
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
killall Finder
```
`PfDe` = Desktop. `PfLo` = custom path (use with `NewWindowTargetPath`). Or set via GUI: **Finder → Settings → General → "New Finder windows show"**.

---

### 24. Show Desktop Items (Drives, Servers, Media)
```bash
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
killall Finder
```
Or GUI: **Finder → Settings → General → "Show these items on the desktop"**.

---

### 25. Expand Save/Open Dialogs by Default
```bash
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForOpenMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
```
All save/open/print dialogs open in expanded (full) view.

---

### 26. Enable Spring-Loaded Folders
```bash
defaults write com.apple.finder SpringloadingEnabled -bool true; killall Finder
```
Drag a file onto a folder, hover, and the folder springs open. Also set delay via GUI: **Finder → Settings → General → Spring-loading delay**.

---

### 27. Disable Window Zoom Animation
```bash
defaults write com.apple.finder AnimateWindowZoom -bool false; killall Finder
```

---

### 28. Show Alternating Row Stripes in List View
```bash
defaults write com.apple.finder FXListViewStripes -boolean true; killall Finder
```

---

### 29. Control Which Columns Show in Search Results
```bash
defaults write com.apple.finder SearchViewSettings.ListViewSettings.columns.version.visible -boolean true
defaults write com.apple.finder SearchViewSettings.ListViewSettings.columns.size.visible -boolean true
defaults write com.apple.finder SearchViewSettings.ListViewSettings.columns.comments.visible -boolean true
killall Finder
```

---

### 30. Sidebar Icon Size (Small / Medium / Large)
```bash
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1  # Small
# -int 2 = Medium (default)
# -int 3 = Large
killall Finder
```

---

### 31. Set List View Column Order, Width & Visibility via AppleScript
AppleScript can control columns, widths, sort direction, and visibility — but **only for the currently open window**. To apply to many folders, you must script a loop (see #32).

```applescript
tell application "Finder"
    activate
    tell list view options of the front Finder window
        set properties to {calculates folder sizes:true, shows icon preview:false, ¬
            icon size:small icon, text size:12, uses relative dates:true, sort column:name column}
        
        tell column name column
            set properties to {index:1, sort direction:normal, width:280}
        end tell
        tell column size column
            set properties to {index:2, sort direction:normal, width:72, visible:true}
        end tell
        tell column modification date column
            set properties to {index:3, sort direction:normal, width:120, visible:true}
        end tell
        tell column creation date column
            set properties to {index:4, sort direction:normal, width:120, visible:true}
        end tell
        tell column kind column
            set properties to {index:5, sort direction:normal, width:120, visible:true}
        end tell
        tell column label column
            set properties to {index:6, sort direction:normal, width:72, visible:false}
        end tell
        tell column version column
            set properties to {index:7, sort direction:normal, width:72, visible:false}
        end tell
        tell column comment column
            set properties to {index:8, sort direction:normal, width:240, visible:false}
        end tell
    end tell
    tell the front Finder window
        set current view to list view
    end tell
end tell
```
> ⚠️ Changing `index` (column order) works but may require navigating away and back to see the change render. Column `width` must be between minimum and maximum values enforced by Finder. Some columns like "Date Added" and "Date Last Opened" are not accessible via AppleScript's list view options — use System Events UI scripting for those.

---

### 32. Apply List View Settings Recursively to All Subfolders (AppleScript)
Save as `apply-list-view.applescript`, adjust column settings in `resetFinderWindow()`, then run from Script Editor with the target folder open in Finder:

```applescript
set shortDelay to 0.2
set mediumDelay to 0.5

tell application "Finder"
    set targetFolder to target of front Finder window
    try
        set theSubfolders to every folder of the entire contents of targetFolder
        if class of theSubfolders is not list then set theSubfolders to theSubfolders as list
    on error
        set theSubfolders to {}
    end try
end tell

set theFolders to (targetFolder as list) & theSubfolders
set progress total steps to (count of theFolders)
set progress completed steps to 0

repeat with aFolder in theFolders
    tell application "Finder" to set the target of Finder window 1 to aFolder
    resetFinderWindow()
    set progress completed steps to (progress completed steps) + 1
end repeat

on resetFinderWindow()
    tell application "Finder"
        tell front Finder window
            set current view to list view
        end tell
        tell application "System Events" to tell process "Finder"
            delay shortDelay
            tell menu item "Show View Options" of menu of menu bar item "View" of menu bar 1 to if exists then click
            delay mediumDelay
            repeat with boxName in {"Date Modified", "Date Created", "Date Last Opened", "Date Added", "Size", "Kind", "Version", "Comments", "Tags"}
                if boxName is in {"Date Modified", "Date Created", "Size", "Kind"} then
                    tell checkbox boxName of group 1 of window 1 to if value is 0 then click
                else
                    tell checkbox boxName of group 1 of window 1 to if value is 1 then click
                end if
            end repeat
            delay mediumDelay
            tell menu item "Hide View Options" of menu of menu bar item "View" of menu bar 1 to if exists then click
            delay mediumDelay
        end tell
        tell front Finder window
            set options to its list view options
        end tell
        tell options
            set properties of column name column to {index:1, width:280}
            set properties of column size column to {index:2, width:72}
            set properties of column modification date column to {index:3, width:120}
            set properties of column creation date column to {index:4, width:120}
            set properties of column kind column to {index:5, width:120}
            set properties of column label column to {index:6, width:0}
            set properties of column version column to {index:7, width:0}
            set properties of column comment column to {index:8, width:0}
        end tell
    end tell
end resetFinderWindow
```
> ⚠️ Slow for large directory trees — Finder must open each folder. Best run on specific project directories, not your entire home folder.

---

### 33. Create Smart Folders with Raw mdfind Queries
Smart Folders are `.savedSearch` plist files in `~/Library/Saved Searches/`. The Finder GUI supports a "Raw Query" criteria that lets you embed `mdfind`-style Spotlight Query Language:

1. **Finder → File → New Smart Folder** (`Cmd + Option + N`)
2. Click **`+`** to add criteria, then click the first dropdown → **Other...**
3. Search for **"Raw query"** and select it
4. Enter any `mdfind`-compatible query, e.g.:
   - `kMDItemFSCreationDate > $time.now(-300)` — files created in last 5 min
   - `kMDItemContentType == "com.adobe.pdf" && kMDItemFSSize > 1000000` — PDFs > 1MB
   - `kMDItemUserTags == "Red"` — files tagged Red
5. Click **Save**, name it, check "Add to Sidebar"

> ⚠️ Hold **Option (⌥)** while criteria are visible to change `+` into `…`, which lets you add "Any of the following are true" (OR logic) groups.
> ⚠️ There is **no undo** in Smart Folder editing — changes apply immediately. Duplicate `.savedSearch` files before modifying complex ones.

---

### 34. mdfind — Spotlight Search from the Shell
```bash
# Basic content search
mdfind "search term"

# Filename-only search
mdfind -name "config"

# Search within specific directory
mdfind -onlyin ~/Projects "kMDItemContentType == 'com.adobe.pdf'"

# Live-updating results (ctrl-C to stop)
mdfind -live "kMDItemFSCreationDate > $time.now(-60)"

# Count only
mdfind -count "kMDItemUserTags == 'Red'"

# Files modified in last 3 days in home folder
mdfind -onlyin ~ 'kMDItemFSContentChangeDate >= $time.today(-3)'

# All folders with "doc" in name
mdfind 'kind:folder' -name doc

# Tagged Red AND is a folder
mdfind 'kMDItemUserTags == "Red" && kMDItemContentType == "public.folder"'

# All images
mdfind 'kMDItemContentType == "public.image"'
```
Key attributes: `kMDItemDisplayName`, `kMDItemFSName`, `kMDItemFSSize`, `kMDItemFSCreationDate`, `kMDItemFSContentChangeDate`, `kMDItemContentType`, `kMDItemKind`, `kMDItemUserTags`, `kMDItemTextContent`
Modifiers: `c` = case-insensitive, `d` = diacritic-insensitive, `w` = word-based. Example: `kMDItemDisplayName ==[c] "steve"`
Use `mdls /path/to/file` to see all available metadata attributes for a specific file.

---

### 35. Create "Copy Full Path" Quick Action (Automator)
1. **Automator → New → Quick Action**
2. Set "Workflow receives current: **files or folders** in **Finder.app**"
3. Add **"Run Shell Script"** action. Set shell to `/bin/zsh`, pass input "as arguments":
   ```bash
   printf '%s\n' "$@" | pbcopy
   ```
4. Save as "Copy Full Path"
5. Right-click any file in Finder → **Quick Actions → Copy Full Path**

---

### 36. Create "Open in Terminal" Quick Action (Automator)
1. **Automator → New → Quick Action**
2. Set "Workflow receives current: **folders** in **Finder.app**"
3. Add **"Run AppleScript"** action:
   ```applescript
   on run {input, parameters}
       repeat with theItem in input
           set thePath to POSIX path of theItem
           tell application "Terminal"
               activate
               do script "cd " & quoted form of thePath
           end tell
       end repeat
       return input
   end run
   ```
4. Save as "Open in Terminal"
5. Assign keyboard shortcut: **System Settings → Keyboard → Keyboard Shortcuts → Services → Files and Folders → Open in Terminal**

---

### 37. Shortcuts App Quick Actions (Alternative to Automator)
The Shortcuts app (macOS 12+) can also create Quick Actions:
1. Open **Shortcuts** → create new shortcut
2. Click **Details (ⓘ)** → check **"Use as Quick Action"** → check **Finder**
3. Build workflow with drag-and-drop actions
4. Enable in **System Settings → Privacy & Security → Extensions → Finder**

> ⚠️ Some users report Shortcuts-based Quick Actions don't always appear in Finder's right-click menu, while Automator-based ones reliably do. For Finder-specific actions, Automator is currently more reliable.

---

### 38. Custom Keyboard Shortcuts for Any Finder Menu Item
**System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts → +**
- App: **Finder**
- Menu Title: exact name as it appears in the menu (e.g., "New Smart Folder", "Go to Folder", "Compress")
- Assign any available key combo

---

### 39. Custom Finder Toolbar
**Finder → View → Customize Toolbar** (`Cmd + Option + ;`):
- Add: **Path** (breadcrumb dropdown), **New Folder**, **Delete**, **Connect**, **Get Info**, **Quick Look**
- Drag-reorder, remove defaults you don't use

---

### 40. Open Folders in Tabs Instead of New Windows
**Finder → Settings → General → "Open folders in tabs instead of new windows"** ✓
- `Cmd + T` — new tab
- `Cmd + Shift + T` — new tab with same folder
- `Cmd + W` — close tab
- `Window → Merge All Windows` — combine multiple windows into tabs

---

### 41. Key Keyboard Shortcuts Reference

| Shortcut                        | Action                                                               |
| ------------------------------- | -------------------------------------------------------------------- |
| `Cmd + Shift + .`               | Toggle hidden files                                                  |
| `Cmd + Option + C`              | Copy path to clipboard                                               |
| `Cmd + Shift + G`               | Go to folder (type any path)                                         |
| `Cmd + Option + N`              | New Smart Folder                                                     |
| `Cmd + Option + P`              | Toggle path bar                                                      |
| `Cmd + /`                       | Toggle status bar                                                    |
| `Cmd + Shift + P`               | Toggle preview pane                                                  |
| `Cmd + J`                       | Show View Options                                                    |
| `Cmd + 1/2/3/4`                 | Icon / List / Column / Gallery view                                  |
| `Cmd + Option + I`              | Inspector (persistent Get Info — updates as selection changes)       |
| `Cmd + Option + Y`              | Quick Look slideshow                                                 |
| `Space`                         | Quick Look preview                                                   |
| `Cmd + Option + V`              | Move (instead of copy) — "cut and paste"                             |
| `Cmd + Shift + N`               | New folder                                                           |
| `Cmd + Option + Shift + N`      | New folder with selection                                            |
| `Cmd + Delete`                  | Move to Trash                                                        |
| `Cmd + Shift + Delete`          | Empty Trash                                                          |
| `Cmd + Option + Shift + Delete` | Empty Trash (no confirmation)                                        |
| `Cmd + Up`                      | Go to parent folder                                                  |
| `Cmd + Ctrl + Up`               | Open parent in new window/tab                                        |
| `Cmd + Down`                    | Open selected item                                                   |
| `Cmd + [` / `Cmd + ]`           | Back / Forward                                                       |
| `Cmd + click window title`      | Breadcrumb dropdown of enclosing folders                             |
| `Return`                        | Rename selected file                                                 |
| `Cmd + D`                       | Duplicate                                                            |
| `Cmd + Ctrl + A`                | Make alias                                                           |
| `Cmd + Shift + C/D/H/O/U/I/K`   | Computer / Desktop / Home / Documents / Utilities / iCloud / Network |
| `Cmd + Option + L`              | Downloads folder                                                     |
| `Cmd + Shift + R`               | AirDrop window                                                       |
| `Cmd + T`                       | New tab                                                              |
| `Cmd + Option + T`              | Toggle toolbar                                                       |
| `Cmd + Option + S`              | Toggle sidebar                                                       |
| `Cmd + Option + D`              | Toggle Dock                                                          |

---

### 42. Reset All Finder Settings to Defaults
```bash
defaults delete com.apple.finder
killall Finder
```
Nuclear option — wipes every customization. Finder restarts with factory defaults.

---

### 43. Verify Current Settings
```bash
# Read all Finder preferences
defaults read com.apple.finder

# Read a specific key
defaults read com.apple.finder FXPreferredViewStyle

# Read global domain settings
defaults read NSGlobalDomain AppleShowAllExtensions
```

---

### 44. Verify Which defaults Keys Actually Exist
```bash
# Full plist as XML
defaults read com.apple.finder > ~/finder_prefs.txt

# Or convert plist to XML directly
plutil -convert xml1 -o - ~/Library/Preferences/com.apple.finder.plist
```
Only keys you've modified appear in the plist. Keys that are no-ops won't show up after `killall Finder` if macOS ignored them.

---

### 45. macOS 26 Tahoe Column View Bug Warning
If you're on macOS 26 Tahoe and use **Column View** with scroll bars set to "Always Show":
- The horizontal scroll bar covers the column resize handles at the bottom of each column
- macOS 26.3 partially fixed this (shortened vertical scrollers) but the horizontal bar still overlaps filenames
- Workaround: set scroll bars to "When scrolling" in System Settings → Accessibility → Display → Scroll bars
- Or: hide path bar + status bar (the bug doesn't occur without them)

---
