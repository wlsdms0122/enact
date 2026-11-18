#!/usr/bin/env bash
#
# set-up.sh: provides the idb libraries the Digit module builds against.
#
#   tool/set-up.sh           build if missing, no-op otherwise (once per checkout)
#   tool/set-up.sh --force   rebuild unconditionally (after an Xcode update or a pin bump)
#
# Xcode is the only thing it needs. idb builds its libraries package with its own
# build.sh, which generates the Xcode project with XcodeGen, so XcodeGen is built
# from source at a pinned tag and put on that script's PATH.
#
# What ships is one file. idb's libraries are static archives, so the linker copies
# them into `enact`. Two things in the libraries package would undo that, and
# neither is taken:
#   - the `*Stub.xcframework` dynamic stand-ins for the private frameworks. Package.swift
#     weak-links the private frameworks themselves instead;
#   - `Resources/`, the guest helpers looked for beside the executable. The one
#     helper Digit needs, the iOS guest bridge, is linked into the executable as a
#     section (Package.swift) and written out by Digit when it is first needed.
#
# package/Frameworks/ is not committed. These binaries are pinned to the toolchain
# that produced them, so a checked-in copy would be unreadable on a machine running
# a different Xcode. Building locally means each machine bakes them with its own
# toolchain, so a Swift version mismatch cannot arise. Reproducibility rests on the
# pins below.
set -euo pipefail

# ── Pins (change only for a deliberate resync) ──────────────────────
IDB_GIT_URL="${IDB_GIT_URL:-https://github.com/facebook/idb.git}"
IDB_REF="${IDB_REF:-6e4663d72e9c39c45412153c873897baf34fcf9a}"
XCODEGEN_GIT_URL="${XCODEGEN_GIT_URL:-https://github.com/yonaskolb/XcodeGen.git}"
XCODEGEN_REF="${XCODEGEN_REF:-2.46.0}"

# The libraries Digit imports and every archive they link, as the package's
# manifest.json lists them, plus IDBPrivateHeaders, whose headers are the private
# framework modules those libraries' interfaces import.
LIBRARIES=(
  IDBPrivateHeaders
  FBControlCoreObjC
  FBControlCore
  SimulatorIPC
  FBSimulatorBridgeProtocol
  FBSimulatorControl
  FBSimulatorServices
  FBSimulatorAX
  FBVideoCore
  FBSimulatorVideo
)
# The guest FBSimulatorServices and FBSimulatorAX run inside an iOS simulator.
BRIDGE=SimulatorFrameworkBridge-iOS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="$(cd "$SCRIPT_DIR/../package" && pwd)"
DEST="$PKG_DIR/Frameworks"
# Scratch for the clones and the build, made here and removed on the way out.
# It is deliberately not overridable: this path gets deleted, and a caller
# pointing it somewhere of their own would be handing that over to be removed.
SCRATCH="$(mktemp -d)"
WORK="$SCRATCH/idb"
trap 'rm -rf "$SCRATCH"' EXIT

FORCE=false
case "${1:-}" in
  "") ;;
  --force) FORCE=true ;;
  *) echo "error: unknown argument '$1' (only --force)"; exit 1 ;;
esac

# What the libraries were baked with. They are tied to that toolchain, so a
# different one means what is on disk cannot be read even though it is present.
STAMP="$DEST/.built-with"
CURRENT="$(xcrun swift --version 2>&1 | head -1)|$IDB_REF|$XCODEGEN_REF"

# ── Nothing to do when already built with this toolchain ────────────
if [ "$FORCE" = false ]; then
  ready=true
  for library in "${LIBRARIES[@]}"; do
    [ -d "$DEST/$library.xcframework" ] || ready=false
  done
  [ -f "$DEST/$BRIDGE" ] || ready=false
  [ -f "$STAMP" ] && [ "$(cat "$STAMP")" = "$CURRENT" ] || ready=false
  if [ "$ready" = true ]; then
    echo "Libraries already built with this toolchain, nothing to do"
    exit 0
  fi
fi

echo "idb      : $IDB_GIT_URL @ $IDB_REF"
echo "xcodegen : $XCODEGEN_GIT_URL @ $XCODEGEN_REF"
echo "toolchain: $(xcode-select -p)   ($(xcrun swift --version 2>&1 | head -1))"
echo "work dir : $WORK"
echo "dest     : $DEST"

# ── 1) XcodeGen at the pinned tag ───────────────────────────────────
XCODEGEN_WORK="$SCRATCH/xcodegen"
mkdir -p "$XCODEGEN_WORK"; cd "$XCODEGEN_WORK"
git init -q
git remote add origin "$XCODEGEN_GIT_URL"
git fetch --depth 1 origin tag "$XCODEGEN_REF"
git checkout -q "$XCODEGEN_REF"
swift build -c release --product xcodegen
XCODEGEN_BIN="$XCODEGEN_WORK/.build/release"

# ── 2) Shallow clone at the pinned revision ─────────────────────────
mkdir -p "$WORK"; cd "$WORK"
git init -q
git remote add origin "$IDB_GIT_URL"
git fetch --depth 1 origin "$IDB_REF"
git checkout -q FETCH_HEAD

# ── 3) The libraries package ────────────────────────────────────────
export PATH="$XCODEGEN_BIN:$PATH"
./build.sh build libraries
./build.sh build library-package
PACKAGE="$WORK/Build/LibraryPackage"

# ── 4) What Digit links ─────────────────────────────────────────────
mkdir -p "$DEST"
for library in "${LIBRARIES[@]}"; do
  [ -d "$PACKAGE/$library.xcframework" ] || {
    echo "error: missing from the libraries package: $library.xcframework"; exit 1; }
  rm -rf "$DEST/$library.xcframework"
  cp -R "$PACKAGE/$library.xcframework" "$DEST/"
done
# Copied as it is: the guest is signed for the simulator.
cp "$PACKAGE/Resources/$BRIDGE" "$DEST/$BRIDGE"

printf '%s' "$CURRENT" > "$STAMP"

echo ""
echo "done:"
du -sh "$DEST"/*.xcframework "$DEST/$BRIDGE"
echo ""
echo "next: (cd $PKG_DIR && swift build && swift test)"
