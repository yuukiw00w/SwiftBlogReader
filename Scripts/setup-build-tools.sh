#!/bin/bash 

set -euo pipefail

echo "📦 Updating Swift BuildTools package..."

# $0: スクリプト自身のファイルパス
cd "$(dirname "$0")/../BuildTools"

swift package update
swift build -c release

echo "✅ Swift BuildTools is now up to date and built."
