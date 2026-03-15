# 🐟 Magikarp Cursor Theme
 
A pixel-art cursor theme for Linux/KDE based on Magikarp from Pokémon.  
All cursors are animated and available in multiple sizes: **32 × 32, 48 × 48, 64 × 64, 96 × 96, 128 × 128 px**.

![preview](https://github.com/user-attachments/assets/f4dec633-30ed-4d31-b58a-ccfcf583e9a5)

---

## Installation
 
### Option A — download release (recommended)
 
1. Download `Magikarp.tar.gz` from the Releases page
2. Extract to your icons directory:
   ```bash
   tar -xzf Magikarp.tar.gz -C ~/.local/share/icons/
   ```
3. Open **System Settings → Cursors** and select **Magikarp**
 
### Option B — build from source
 
#### Requirements
 
```bash
sudo pacman -S xorg-xcursorgen python-wand   # Arch / KDE
pip install win2xcur
```
 
#### Build
 
```bash
git clone https://github.com/YOUR_USERNAME/magikarp-cursor
cd magikarp-cursor
chmod +x build_magikarp_cursor.sh
./build_magikarp_cursor.sh
```
 
The script outputs `~/Downloads/Magikarp.tar.gz`. Install as in Option A.

---

## Cursors included
 
| Cursor | X11 name |
|--------|----------|
| Select | `left_ptr` |
| Help Select | `question_arrow` |
| Working in Background | `left_ptr_watch` |
| Busy | `watch` |
| Precision Select | `crosshair` |
| Text Select | `xterm` |
| Handwriting | `pencil` |
| Unavailable | `not-allowed` |
| Vertical Resize | `ns-resize` |
| Horizontal Resize | `ew-resize` |
| Diagonal Resize ↘ | `nwse-resize` |
| Diagonal Resize ↗ | `nesw-resize` |
| Move | `move` |
| Alt Select | `alias` |
| Link Select | `pointer` |
| Location Select | `cell` |
| Person Select | `default_person` 

---

## Credits

Original: https://www.rw-designer.com/cursor-set/magikarp

Packaged for Linux/KDE using [win2xcur](https://github.com/quantum5/win2xcur)
