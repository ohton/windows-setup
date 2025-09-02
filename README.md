
# Windows 11 ソフトウェア自動インストールセットアップ（winget export/import 方式）

このリポジトリは、Windows 11環境でwingetの `export`/`import` 機能を使い、PowerShellからソフトウェアを一括インストールするためのセットアップ例です。

## ファイル構成
- `packages.json` : インストールしたいアプリ一覧（wingetのエクスポート形式JSONファイル）
- `export-packages.ps1` : 現在のPCのインストール済みアプリ一覧を `packages.json` にエクスポートするPowerShellスクリプト
- `install-apps.ps1` : `packages.json` を読み込み、wingetで一括インストールするPowerShellスクリプト

## 使い方
### 1. アプリ一覧のエクスポート
インストール済みアプリをエクスポートしたいPCで、PowerShellから以下を実行：
```powershell
./export-packages.ps1
```
（または直接 `winget export packages.json` を実行）

### 2. 新しいPCで一括インストール
エクスポートした `packages.json` を新しいPCにコピーし、PowerShellから以下を実行：
```powershell
./install-apps.ps1
```
（または直接 `winget import packages.json` を実行）

## 注意事項
- wingetがインストールされている必要があります。
- 管理者権限での実行を推奨します。
- `packages.json` の内容は `winget export` で生成されます。

## 例
`packages.json` の例（抜粋）：
```json
[
   {
      "PackageIdentifier": "Microsoft.Edge",
      "Version": "latest"
   },
   {
      "PackageIdentifier": "Google.Chrome",
      "Version": "latest"
   }
]
