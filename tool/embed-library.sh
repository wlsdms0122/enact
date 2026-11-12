#!/bin/bash
# Writes `lib/` into a Swift source, so the module a scenario uses arrives
# with the binary: `Enact.yaml`, Enact's library, `Enact.interface.warpt`, the
# types the binary declares beside it, and `Native.interface.warpt`, the
# natives the library calls.
#
# The files are the source; this is a copy of them. `EnactVocabularyTests`
# holds the two to being the same texts, so a file edited without running
# this is a red test.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
library="$root/lib/Enact.yaml"
types="$root/lib/Enact.interface.warpt"
natives="$root/lib/Native.interface.warpt"
written="$root/package/Sources/EnactWarp/Vocabulary/Library.swift"

quoted() {
    /usr/bin/sed -e 's/\\/\\\\/g' -e 's/"""/\\"\\"\\"/g' -e 's/^/        /' "$1"
}

{
    echo "//"
    echo "//  Library.swift"
    echo "//  EnactWarp"
    echo "//"
    echo "//  Written by tool/embed-library.sh. Edit lib/ and run it again."
    echo "//"
    echo ""
    echo "import Foundation"
    echo ""
    echo "// The texts of \`lib/\`, as they stand in the repository."
    echo "enum Library {"
    echo "    // \`lib/Enact.yaml\`"
    echo "    static let text = \"\"\""
    quoted "$library"
    echo "        \"\"\""
    echo "    "
    echo "    // \`lib/Enact.interface.warpt\`"
    echo "    static let types = \"\"\""
    quoted "$types"
    echo "        \"\"\""
    echo "    "
    echo "    // \`lib/Native.interface.warpt\`"
    echo "    static let natives = \"\"\""
    quoted "$natives"
    echo "        \"\"\""
    echo "}"
} > "$written"

echo "$written"
