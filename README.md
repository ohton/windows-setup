# Windows 11 セットアップ

このリポジトリは、Windows 11 環境での個人的なアプリケーションセットアップ手順・設定例をまとめています。

## ファイル構成

- `packages.json`  
  管理対象のアプリ一覧（wingetのエクスポート形式JSONファイル）
- `clear-winget-cache.ps1`  
  wingetのインストーラキャッシュを確認・削除するPowerShellスクリプト

---

## 1. アプリケーションのインストール

### 一括インストール（初回セットアップ）

PowerShellまたはWindows Terminalから以下を実行することで、`packages.json` に記載されたアプリを一括インストールできます。  
（`--accept-source-agreements` や `--accept-package-agreements` を付与することで、ライセンス確認等のプロンプトを自動承諾できます）

```powershell
winget import -i packages.json --accept-source-agreements --accept-package-agreements
```

> **Note**: コマンドを直接実行するため、PowerShellスクリプトの実行ポリシー（ExecutionPolicy）の変更は不要です。

### マニュアルインストール

- **VSCode**  
  wingetからインストールするとコンテキストメニュー追加（「Code で開く」など）のチェックが省略されるため、公式サイトのインストーラからインストールします。

---

## 2. アプリケーションの更新とピン留め（pin）

日常的な更新は一括アップグレードで行い、自動更新を避けたいアプリにはピン留め（`winget pin`）を活用します。

### 一括アップグレード

インストール済みアプリを最新バージョンに一括更新します：

```powershell
winget upgrade --all --accept-source-agreements --accept-package-agreements
```

### 特定パッケージの更新スキップ（ピン留め / pin）

特定バージョンで固定したいパッケージや、意図しない自動更新を防ぎたいパッケージはピン留めして一括更新対象から除外します。

- **パッケージをピン留め（更新スキップ）**:
  ```powershell
  winget pin add <PackageIdentifier>
  ```
  *(例: `winget pin add Microsoft.Git`)*

- **完全に更新をブロックする場合（`--blocking`）**:  
  通常のピン留めは `winget upgrade <PackageIdentifier>` と明示指定した際に更新されてしまいますが、ピンを解除するまで更新自体を完全に禁止したい場合は `--blocking` を指定します。
  ```powershell
  winget pin add <PackageIdentifier> --blocking
  ```

- **バージョン範囲を指定して固定する場合**:
  ```powershell
  winget pin add <PackageIdentifier> -v "2.*"
  ```

- **ピン留め一覧の確認**:
  ```powershell
  winget pin list
  ```

- **ピン留めの解除**:
  ```powershell
  winget pin remove <PackageIdentifier>
  ```

- **全ピン留めのリセット**:
  ```powershell
  winget pin reset
  ```

- **ピン留めを無視してすべて強制更新したい場合**:
  ```powershell
  winget upgrade --all --include-pinned
  ```

---

## 3. アプリ一覧のエクスポート（バックアップ / 同期）

現在のPCにインストールされているアプリ一覧を `packages.json` にエクスポートします：

```powershell
winget export -o packages.json
```

必要に応じて不要なアプリをJSONから除外してコミットしてください。

---

## 4. キャッシュクリーンアップ

wingetがダウンロードしたインストーラ等のキャッシュを確認・削除するスクリプトです。

```powershell
./clear-winget-cache.ps1
```

確認なしで即座に削除する場合：

```powershell
./clear-winget-cache.ps1 -Force
```

このスクリプトは以下の場所のキャッシュをチェックします：
- `LocalAppData\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalCache`
- `LocalAppData\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\TempState`
- `%TEMP%\WinGet`

※ PowerShellスクリプトの実行が制限されている場合は、事前に現在のセッションで実行ポリシーを緩和してください：
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## 5. インストール後のセットアップ

### TightVNC Service

- Primary passwordを設定
- Main画面のみ表示用に Extra Portsで `5901: 1920x1080+0+0` を追加

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