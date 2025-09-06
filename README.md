# Windows 11 セットアップ

このリポジトリは、Windows 11 環境での個人的なアプリケーションセットアップ例をまとめています。

## ファイル構成

- `packages.json`  
  インストールしたいアプリ一覧（wingetのエクスポート形式JSONファイル）
- `export-packages.ps1`  
  現在のPCのインストール済みアプリ一覧を `packages.json` にエクスポートするPowerShellスクリプト
- `install-apps.ps1`  
  `packages.json` を読み込み、wingetで一括インストールするPowerShellスクリプト

## マニュアルインストール

- **VSCode**  
  wingetからインストールするとコンテキストメニュー追加のチェックが省略されるため、インストーラからインストール。

## 一括インストール

PowerShellから以下を実行することで、`packages.json` に記載されたアプリをインストールできます。

```powershell
./install-apps.ps1
```
または直接以下を実行してください：

```powershell
winget import packages.json
```

### 注意事項

- PowerShellスクリプトの実行ポリシーの設定が必要です。
  - 現在のセッションのみ制限を緩和する場合：
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    ```
  - ユーザー全体で変更する場合：
    ```powershell
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    ```
- wingetがインストールされている必要があります。
- `packages.json` の内容は `winget export` で生成されます。

### アプリ一覧のエクスポート方法

インストール済みアプリをエクスポートしたいPCで、PowerShellから以下を実行してください：

```powershell
./export-packages.ps1
```
または直接以下を実行してください：

```powershell
winget export packages.json
```

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
```

## インストール後のセットアップ

### TightVNC Service

- Primary passwordを設定
- Main画面のみ表示用に Extra Portsで 5901: `1920x1080+0+0` を追加

### Docker

- `wsl --update` でWSLを最新に
- `wsl --install` でUbuntuをインストール

#### Docker Ubuntuでssh service設定

- WSL settingsで設定変更
  - ネットワーク
    - ネットワークモード: `Mirrored`
    - ホストアドレスのループバック: `True`
- Ubuntuで設定

  ```bash
  sudo apt update
  sudo apt upgrade -y
  sudo apt install -y openssh-server
  sudo systemctl start ssh
  sudo systemctl status ssh
  sudo systemctl enable ssh
  ```
- Windowsで設定
  - 「ファイアウォールとネットワーク保護」→「詳細設定」→「セキュリティが強化された Windows Defender ファイアウォール」
    - 受信の規則で新しい規則を追加。ポート番号→「TCP」「22」→「接続を許可する」→「プライベート」→名前「WSL ubuntu service」(なんでもいい)
  