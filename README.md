# SwiftBlogReader

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 概要 (Overview)

SwiftBlogReaderは、[Swift.orgの公式ブログ](https://www.swift.org/blog/)のRSSフィードを取得し、閲覧するためのネイティブアプリです。
iOS、macOS、visionOSなど、複数のAppleプラットフォームで動作します。
Siriやショートカットアプリから新着記事を素早く確認できます。

## ビルドと実行 (Build & Run)

1. リポジトリをクローンします
2. ビルドツールをセットアップします
   プロジェクトで利用しているSwiftFormatやSwiftLintをセットアップします。
   ```bash
   ./Scripts/setup-build-tools.sh
   ```

3. Xcodeでプロジェクトを開きます
   `SwiftBlogReader.xcworkspace` ファイルをXcodeで開いてください。

4. そのままビルド、実行可能です
