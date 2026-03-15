#!/bin/bash
# Magikarp KDE Cursor Theme Builder — multi-size
# Requirements: win2xcur, xcursorgen, python-wand
#   Arch: sudo pacman -S xorg-xcursorgen python-wand

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/magikarp"
THEME_NAME="Magikarp"
BUILD_DIR="/tmp/magikarp_cursor_build"
CURSORS_DIR="$BUILD_DIR/$THEME_NAME/cursors"
TMP_WIN2X="/tmp/magikarp_win2x"
TMP_FRAMES="/tmp/magikarp_frames"

rm -rf "$BUILD_DIR" "$TMP_WIN2X" "$TMP_FRAMES"
mkdir -p "$CURSORS_DIR" "$TMP_WIN2X" "$TMP_FRAMES"

echo "=== Magikarp KDE Cursor Theme Builder ==="
echo ""

declare -A PRIMARY=(
  ["Magikarp Select.ani"]="left_ptr"
  ["Magikarp Help Select.ani"]="question_arrow"
  ["Magikarp Working in Background.ani"]="left_ptr_watch"
  ["Magikarp Busy.ani"]="watch"
  ["Magikarp Precision Select.ani"]="crosshair"
  ["Magikarp Text Select.ani"]="xterm"
  ["Magikarp Handwriting.ani"]="pencil"
  ["Magikarp Unavailable.ani"]="not-allowed"
  ["Magikarp Verticle Resize.ani"]="ns-resize"
  ["Magikarp Horizontal resize.ani"]="ew-resize"
  ["Magikarp Diagonal Resize 1.ani"]="nwse-resize"
  ["Magikarp Diagonal Resize 2.ani"]="nesw-resize"
  ["Magikarp Move.ani"]="move"
  ["Magikarp Alt Select.ani"]="alias"
  ["Magikarp Link Select.ani"]="pointer"
  ["Magikarp location select.ani"]="cell"
  ["Magikarp Person Select.ani"]="default_person"
)

declare -A ALIASES=(
  ["left_ptr"]="arrow default top_left_arrow"
  ["question_arrow"]="help dnd-ask"
  ["left_ptr_watch"]="progress half-busy"
  ["watch"]="wait"
  ["crosshair"]="cross tcross"
  ["xterm"]="text ibeam"
  ["pencil"]=""
  ["not-allowed"]="no-drop forbidden dnd-no-drop"
  ["ns-resize"]="n-resize s-resize size_ver top_side bottom_side v_double_arrow"
  ["ew-resize"]="e-resize w-resize size_hor left_side right_side h_double_arrow"
  ["nwse-resize"]="nw-resize se-resize bd_double_arrow size_fdiag"
  ["nesw-resize"]="ne-resize sw-resize fd_double_arrow size_bdiag"
  ["move"]="all-scroll fleur size_all"
  ["alias"]="dnd-link"
  ["pointer"]="hand hand1 hand2 pointing_hand e29285e634086352946a0e7090d73106"
  ["cell"]="plus"
  ["default_person"]=""
)

# -------------------------------------------------------
# Step 1: .ani → xcursor via win2xcur
# -------------------------------------------------------
echo "Step 1: Converting .ani → xcursor..."

for ani_file in "${!PRIMARY[@]}"; do
  if [ ! -f "$SRC_DIR/$ani_file" ]; then
    echo "  MISSING: $ani_file"
    continue
  fi
  primary="${PRIMARY[$ani_file]}"
  echo "  $ani_file → $primary"
  win2xcur "$SRC_DIR/$ani_file" -o "$TMP_WIN2X"
  stem="${ani_file%.ani}"
  mv "$TMP_WIN2X/$stem" "$TMP_WIN2X/$primary"
done

# -------------------------------------------------------
# Step 2+3: extract frames, rescale with wand, xcursorgen
# -------------------------------------------------------
echo ""
echo "Step 2+3: Extracting frames, rescaling, building xcursors..."

python3 << 'PYEOF'
import sys, os, subprocess
sys.path.insert(0, '/usr/lib/python3.14/site-packages')
from win2xcur.parser import open_blob
from wand.image import Image as WandImage

TMP_WIN2X   = "/tmp/magikarp_win2x"
TMP_FRAMES  = "/tmp/magikarp_frames"
CURSORS_DIR = "/tmp/magikarp_cursor_build/Magikarp/cursors"
SIZES = [32, 48, 64, 96, 128]

for cursor_name in sorted(os.listdir(TMP_WIN2X)):
    xcursor_path = os.path.join(TMP_WIN2X, cursor_name)
    print(f"  Processing: {cursor_name}")

    data = open(xcursor_path, 'rb').read()
    parser = open_blob(data)
    frames = parser.frames

    cfg_lines = []

    for frame_idx, frame in enumerate(frames):
        delay_ms = max(1, int(frame.delay * 1000))

        img_obj   = frame.images[0]
        wand_img  = img_obj.image        # wand Image object
        hx_orig, hy_orig = img_obj.hotspot
        orig_size = wand_img.width       # assume square

        for size in SIZES:
            scale = size / orig_size
            hx = max(0, min(size - 1, round(hx_orig * scale)))
            hy = max(0, min(size - 1, round(hy_orig * scale)))

            # clone and resize with Point (nearest-neighbour) for pixel-art
            with wand_img.clone() as scaled:
                scaled.filter = 'point'
                scaled.resize(size, size)   # two separate ints
                png_path = os.path.join(
                    TMP_FRAMES,
                    f"{cursor_name}_{size}_{frame_idx:03d}.png"
                )
                scaled.save(filename=png_path)

            cfg_lines.append(f"{size} {hx} {hy} {png_path} {delay_ms}")

    cfg_path = os.path.join(TMP_FRAMES, f"{cursor_name}.conf")
    with open(cfg_path, 'w') as f:
        f.write("\n".join(cfg_lines) + "\n")

    out_path = os.path.join(CURSORS_DIR, cursor_name)
    result = subprocess.run(
        ["xcursorgen", cfg_path, out_path],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"    ERROR: {result.stderr.strip()}")
    else:
        print(f"    OK ({len(frames)} frames × {len(SIZES)} sizes)")

print("Done.")
PYEOF

# -------------------------------------------------------
# Step 4: symlinks
# -------------------------------------------------------
echo ""
echo "Step 4: Creating symlinks..."

for primary in "${!ALIASES[@]}"; do
  [ -f "$CURSORS_DIR/$primary" ] || continue
  for alias_name in ${ALIASES[$primary]}; do
    ln -sf "$primary" "$CURSORS_DIR/$alias_name"
  done
done

# -------------------------------------------------------
# Theme metadata
# -------------------------------------------------------
cat > "$BUILD_DIR/$THEME_NAME/cursor.theme" << EOF
[Icon Theme]
Name=$THEME_NAME
Comment=Magikarp cursor theme
EOF

cat > "$BUILD_DIR/$THEME_NAME/index.theme" << EOF
[Icon Theme]
Name=$THEME_NAME
Comment=Magikarp animated cursor theme
Example=left_ptr
EOF

# -------------------------------------------------------
# Package
# -------------------------------------------------------
OUTPUT="$SCRIPT_DIR/${THEME_NAME}.tar.gz"
tar -czf "$OUTPUT" -C "$BUILD_DIR" "$THEME_NAME"

echo ""
echo "=== Done! ==="
echo "Archive: $OUTPUT"
echo ""
echo "Install:"
echo "  tar -xzf $OUTPUT -C ~/.local/share/icons/"
echo "Then: System Settings → Cursors → select '$THEME_NAME'"
