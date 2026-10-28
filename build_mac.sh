#!/bin/sh
# Builds dist/BPMtoOSC.app and dist/BPMtoOSC.dmg on macOS (Apple Silicon).
# Needs the .venv from the README section "macOS".
set -eu
cd "$(dirname "$0")"
ROOT=$(pwd)
PY=.venv/bin/python
APP=dist/BPMtoOSC.app
DMG=dist/BPMtoOSC.dmg

if [ ! -x "$PY" ]; then
    echo "No .venv found in $ROOT, see the README section \"macOS\" for setup." >&2
    exit 1
fi

echo "==> Installing PyInstaller"
"$PY" -m pip install -q pyinstaller==6.22.3 pyinstaller-hooks-contrib==2026.9

echo "==> Building $APP"
rm -rf build dist
"$PY" -m PyInstaller --noconfirm --clean BPMtoOSC.spec

echo "==> Checking that no binary links to Homebrew or the venv"
macho_files=$(mktemp)
bad_links=$(mktemp)
trap 'rm -f "$macho_files" "$bad_links"' EXIT
find "$APP" -type f | while read -r f; do
    if file -b "$f" | grep -q Mach-O; then echo "$f"; fi
done > "$macho_files"
while read -r f; do
    # linked libraries (first line is the file itself) and rpaths
    { otool -L "$f" | tail -n +2; otool -l "$f" | awk '/LC_RPATH/ {getline; getline; print}'; } \
        | grep -E "/opt/homebrew|/usr/local/|\.venv|$ROOT" | sed "s|^|$f: |" >> "$bad_links" || true
done < "$macho_files"
if [ -s "$bad_links" ]; then
    cat "$bad_links" >&2
    echo "ERROR: the bundle still references Homebrew or the venv" >&2
    exit 1
fi
echo "    $(wc -l < "$macho_files" | tr -d ' ') Mach-O files, all self-contained"

min_macos=$(while read -r f; do otool -l "$f" | awk '/minos/ {print $2}'; done < "$macho_files" \
    | sort -t. -k1,1n -k2,2n | tail -1)
plist_min=$(/usr/libexec/PlistBuddy -c "Print :LSMinimumSystemVersion" "$APP/Contents/Info.plist")
echo "    highest minimum macOS of the bundled binaries: $min_macos (Info.plist: $plist_min)"
if [ "$min_macos" != "$plist_min" ]; then
    echo "WARNING: update LSMinimumSystemVersion in BPMtoOSC.spec to $min_macos" >&2
fi

echo "==> Signing ad-hoc"
# no hardened runtime (ad-hoc builds can't be notarized), so no audio-input entitlement needed
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"

echo "==> Building $DMG"
stage=build/dmg
rm -rf "$stage"
mkdir -p "$stage"
ditto "$APP" "$stage/BPMtoOSC.app"
ln -s /Applications "$stage/Applications"
hdiutil create -quiet -volname BPMtoOSC -srcfolder "$stage" -ov -format UDZO "$DMG"

echo "==> Done: $APP ($(du -sh "$APP" | cut -f1)), $DMG ($(du -h "$DMG" | cut -f1))"
