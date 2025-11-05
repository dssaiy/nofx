# 🛠️ NOFX 本地開發部署指南

## 📋 目錄

1. [概述](#概述)
2. [環境準備](#環境準備)
3. [安裝依賴](#安裝依賴)
4. [配置項目](#配置項目)
5. [啟動開發環境](#啟動開發環境)
6. [開發工作流](#開發工作流)
7. [常見問題](#常見問題)
8. [調試技巧](#調試技巧)

---

## 概述

本指南專為**本地開發和學習**設計,幫助您在本地環境中運行 NOFX 項目,方便代碼修改和調試。

### 為什麼選擇本地部署?

✅ **適合學習**: 可以直接修改代碼,立即看到效果
✅ **方便調試**: 使用 IDE 斷點調試,更容易理解代碼邏輯
✅ **快速迭代**: 無需重新構建 Docker 鏡像
✅ **完全控制**: 可以自由修改任何配置和代碼

### 本地 vs Docker 部署對比

| 特性 | 本地部署 | Docker 部署 |
|-----|---------|------------|
| **學習難度** | 需要理解各組件配置 | 一鍵啟動,開箱即用 |
| **開發調試** | ✅ 極佳 (IDE 斷點調試) | ⚠️ 需要進入容器 |
| **環境隔離** | ❌ 依賴本地環境 | ✅ 完全隔離 |
| **啟動速度** | ✅ 快速 (秒級) | ⚠️ 較慢 (需構建鏡像) |
| **資源佔用** | ✅ 較低 | ⚠️ 較高 |
| **生產部署** | ❌ 不推薦 | ✅ 推薦 |

---

## 環境準備

### 系統要求

- **操作系統**: Linux, macOS, Windows (WSL2)
- **內存**: 建議 4GB+
- **磁盤空間**: 至少 2GB

### 必需軟件

#### 1. Go 語言環境 (1.21+)

**檢查是否已安裝:**
```bash
go version
```

**安裝方法:**

**macOS:**
```bash
# 使用 Homebrew
brew install go

# 或手動下載
# 訪問 https://golang.org/dl/
# 下載 .pkg 文件並安裝
```

**Ubuntu/Debian:**
```bash
# 添加 Go 官方 PPA
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt update
sudo apt install golang-go

# 或手動安裝
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
```

**Windows (WSL2):**
```bash
# 在 WSL2 Ubuntu 中執行
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
```

**驗證安裝:**
```bash
go version  # 應顯示 go1.21 或更高版本
```

---

#### 2. Node.js 環境 (18+)

**檢查是否已安裝:**
```bash
node --version
npm --version
```

**安裝方法:**

**macOS:**
```bash
# 使用 Homebrew
brew install node

# 或使用 nvm (推薦)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
```

**Ubuntu/Debian:**
```bash
# 使用 NodeSource 倉庫 (推薦)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 或使用 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
```

**Windows (WSL2):**
```bash
# 使用 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
```

**驗證安裝:**
```bash
node --version  # 應顯示 v18.x.x 或更高
npm --version   # 應顯示 9.x.x 或更高
```

---

#### 3. TA-Lib 技術指標庫

**為什麼需要 TA-Lib?**
NOFX 使用 TA-Lib 計算技術指標 (RSI, MACD, EMA 等),這是核心功能的依賴庫。

**安裝方法:**

**macOS:**
```bash
brew install ta-lib
```

**Ubuntu/Debian:**
```bash
# 方法 1: 使用 apt (如果可用)
sudo apt-get update
sudo apt-get install libta-lib0-dev

# 方法 2: 從源代碼編譯 (如果 apt 沒有這個包)
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/
./configure --prefix=/usr
make
sudo make install
cd ..
rm -rf ta-lib ta-lib-0.4.0-src.tar.gz
```

**Windows (WSL2):**
```bash
# 在 WSL2 Ubuntu 中執行
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/
./configure --prefix=/usr
make
sudo make install
cd ..
rm -rf ta-lib ta-lib-0.4.0-src.tar.gz
```

**驗證安裝:**
```bash
# 檢查庫文件是否存在
ls /usr/lib/libta_lib* || ls /usr/local/lib/libta_lib*
```

如果看到類似 `libta_lib.so` 或 `libta_lib.a` 的文件,說明安裝成功。

---

#### 4. Git 版本控制

**檢查是否已安裝:**
```bash
git --version
```

**安裝方法:**

**macOS:**
```bash
brew install git
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install git
```

**驗證安裝:**
```bash
git --version  # 應顯示 git version 2.x.x
```

---

### 可選工具 (推薦)

#### IDE/編輯器

**Go 後端開發:**
- **GoLand** (JetBrains,商業軟件,功能最強大)
- **VS Code** + Go 擴展 (免費,推薦)
  ```bash
  # 安裝 VS Code
  # 然後安裝 Go 擴展: ms-vscode.go
  ```

**前端開發:**
- **WebStorm** (JetBrains,商業軟件)
- **VS Code** + React 擴展 (免費,推薦)

#### 調試工具

```bash
# 安裝 delve (Go 調試器)
go install github.com/go-delve/delve/cmd/dlv@latest

# 安裝 air (Go 熱重載工具,可選)
go install github.com/cosmtrek/air@latest
```

---

## 安裝依賴

### 1. 克隆項目

```bash
# 克隆您 fork 的倉庫
git clone https://github.com/dssaiy/nofx.git
cd nofx

# 或克隆原倉庫
# git clone https://github.com/tinkle-community/nofx.git
# cd nofx
```

### 2. 安裝後端依賴

```bash
# 下載 Go 模塊依賴
go mod download

# 驗證依賴安裝
go mod verify
```

**常見問題:**
- 如果下載很慢,可以配置 Go 模塊代理:
  ```bash
  go env -w GOPROXY=https://goproxy.cn,direct
  ```

### 3. 安裝前端依賴

```bash
cd web
npm install

# 如果 npm install 很慢,可以使用國內鏡像
npm install --registry=https://registry.npmmirror.com
```

**如果遇到依賴錯誤:**
```bash
# 清除 npm 緩存並重試
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### 4. 驗證依賴完整性

```bash
# 返回項目根目錄
cd ..

# 嘗試構建後端 (檢查是否有編譯錯誤)
go build -o nofx main.go

# 如果看到 nofx 可執行文件,說明後端依賴正常
ls -lh nofx

# 檢查前端
cd web
npm run build

# 如果看到 dist 目錄,說明前端依賴正常
ls -lh dist
```

---

## 配置項目

### 1. 創建環境變量文件

```bash
# 返回項目根目錄
cd ..

# 複製環境變量模板
cp .env.example .env
```

### 2. 編輯 .env 文件

```bash
nano .env  # 或使用您喜歡的編輯器
```

**基本配置:**
```env
# 後端 API 端口
NOFX_BACKEND_PORT=8080

# 前端 Web 端口
NOFX_FRONTEND_PORT=3000

# 日誌級別 (development 模式下建議 debug)
LOG_LEVEL=debug

# 數據庫路徑 (默認使用 SQLite)
DATABASE_PATH=./config.db
```

### 3. 創建配置文件

```bash
# 複製配置模板
cp config.json.example config.json

# 編輯配置文件
nano config.json
```

**基本 config.json 配置:**
```json
{
  "admin_mode": true,
  "beta_mode": false,
  "api_server_port": 8080,
  "use_default_coins": true,
  "default_coins": [
    "BTCUSDT",
    "ETHUSDT",
    "SOLUSDT",
    "BNBUSDT",
    "XRPUSDT",
    "DOGEUSDT",
    "ADAUSDT",
    "HYPEUSDT"
  ],
  "coin_pool_api_url": "",
  "oi_top_api_url": "",
  "max_daily_loss": 10.0,
  "max_drawdown": 20.0,
  "stop_trading_minutes": 60,
  "leverage": {
    "btc_eth_leverage": 5,
    "altcoin_leverage": 5
  },
  "jwt_secret": "請使用下面命令生成隨機密鑰",
  "data_k_line_time": "3m"
}
```

**生成 JWT 密鑰:**
```bash
# 生成隨機密鑰
openssl rand -base64 32

# 複製輸出的密鑰,替換 config.json 中的 jwt_secret 值
```

### 4. 準備 AI API 密鑰

您需要準備以下至少一個 AI 服務的 API 密鑰:

#### DeepSeek (推薦新手)

1. 訪問: https://platform.deepseek.com
2. 註冊並完成郵箱驗證
3. 充值餘額 (建議 $20-50 用於測試)
4. 創建 API Key
5. 保存密鑰 (格式: `sk-xxxxxxxxxx`)

**費用**: 約 $0.14 / 1M tokens (非常便宜)

#### Qwen (阿里雲通義千問)

1. 訪問: https://dashscope.console.aliyun.com
2. 註冊阿里雲賬號
3. 開通 DashScope 服務
4. 創建 API Key
5. 保存密鑰

**注意**: 可能需要中國大陸手機號註冊

### 5. 準備交易所 API (可選,用於實盤)

如果只是學習代碼,可以跳過此步驟。如果要實際測試交易:

#### Binance API

1. 訪問: https://www.binance.com
2. 註冊並完成 KYC
3. 開通合約賬戶
4. 創建 API Key (啟用 Futures 權限)
5. 保存 API Key 和 Secret Key
6. **重要**: 設置 IP 白名單

#### Hyperliquid (去中心化)

1. 準備 MetaMask 錢包
2. 導出私鑰 (移除 `0x` 前綴)
3. 在 https://hyperliquid.xyz 充值

---

## 啟動開發環境

### 方案 A: 標準啟動 (兩個終端窗口)

#### 終端 1: 啟動後端

```bash
# 在項目根目錄
# 構建程序 (首次或代碼修改後)
go build -o nofx main.go

# 啟動後端
./nofx
```

**你應該看到:**
```
╔════════════════════════════════════════════════════════════╗
║    🤖 AI多模型交易系統 - 支持 DeepSeek & Qwen                  ║
╚════════════════════════════════════════════════════════════╝

🌐 API服務器啟動在 http://localhost:8080
```

**保持此終端運行!**

#### 終端 2: 啟動前端

```bash
# 打開新終端
cd nofx/web

# 啟動開發服務器
npm run dev
```

**你應該看到:**
```
  VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
```

**保持此終端運行!**

#### 訪問 Web 界面

打開瀏覽器訪問: **http://localhost:3000**

---

### 方案 B: 使用 tmux (一個終端窗口,推薦)

```bash
# 安裝 tmux (如果未安裝)
# macOS: brew install tmux
# Ubuntu: sudo apt-get install tmux

# 創建 tmux 會話
tmux new -s nofx

# 分割窗口 (水平分割)
# 按 Ctrl+B 然後按 %

# 左側窗口: 啟動後端
go build -o nofx main.go && ./nofx

# 切換到右側窗口
# 按 Ctrl+B 然後按 → (右箭頭)

# 右側窗口: 啟動前端
cd web && npm run dev

# 退出 tmux (不關閉程序)
# 按 Ctrl+B 然後按 D

# 重新連接 tmux
tmux attach -t nofx
```

---

### 方案 C: 使用熱重載 (開發時推薦)

#### 安裝 air (Go 熱重載工具)

```bash
go install github.com/cosmtrek/air@latest

# 確保 air 在 PATH 中
export PATH=$PATH:$(go env GOPATH)/bin
```

#### 創建 air 配置文件

```bash
# 在項目根目錄創建 .air.toml
cat > .air.toml <<'EOF'
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/nofx main.go"
  bin = "tmp/nofx"
  full_bin = "./tmp/nofx"
  include_ext = ["go"]
  exclude_dir = ["web", "tmp", "vendor", "docs"]
  include_dir = []
  exclude_file = []
  delay = 1000
  stop_on_error = true

[color]
  main = "magenta"
  watcher = "cyan"
  build = "yellow"
  runner = "green"

[log]
  time = false

[misc]
  clean_on_exit = true
EOF
```

#### 啟動熱重載開發環境

**終端 1: 後端 (使用 air)**
```bash
air
```

**終端 2: 前端 (已自帶熱重載)**
```bash
cd web
npm run dev
```

**優勢**: 修改 Go 代碼後,air 會自動重新編譯並重啟,無需手動操作!

---

## 開發工作流

### 1. 通過 Web 界面配置

訪問 http://localhost:3000 後:

#### Step 1: 配置 AI 模型

1. 點擊 "AI模型配置" 按鈕
2. 啟用 DeepSeek 或 Qwen
3. 輸入 API Key
4. 點擊 "保存配置"

#### Step 2: 配置交易所

1. 點擊 "交易所配置" 按鈕
2. 選擇 Binance/Hyperliquid/Aster
3. 輸入 API 憑證
4. 點擊 "保存配置"

#### Step 3: 創建交易員

1. 點擊 "創建交易員" 按鈕
2. 選擇 AI 模型
3. 選擇交易所
4. 設置初始餘額 (建議 1000 USDT)
5. 輸入交易員名稱
6. 點擊 "創建"

#### Step 4: 啟動交易

- 找到創建的交易員卡片
- 點擊 "Start" 按鈕
- 查看實時日誌和性能數據

---

### 2. 代碼修改流程

#### 修改後端代碼

```bash
# 1. 停止當前後端 (Ctrl+C)

# 2. 修改代碼 (使用您的 IDE)
# 例如: nano main.go

# 3. 重新編譯
go build -o nofx main.go

# 4. 重啟後端
./nofx
```

**使用 air 時**: 保存文件後自動重啟,無需手動操作!

#### 修改前端代碼

```bash
# Vite 已自帶熱重載
# 直接修改 web/src 中的代碼
# 保存後瀏覽器會自動刷新
```

---

### 3. 查看日誌

#### 後端日誌

**終端輸出**: 實時查看後端運行日誌

**決策日誌文件**:
```bash
# 查看最新決策日誌
ls -lt decision_logs/

# 查看特定交易員的日誌
cat decision_logs/<trader_id>/decision_<timestamp>.json | jq
```

#### 前端日誌

**瀏覽器控制台**:
- 打開瀏覽器
- 按 F12 打開開發者工具
- 查看 Console 標籤

---

### 4. 調試技巧

#### Go 後端調試

**使用 delve 調試器:**

```bash
# 安裝 delve
go install github.com/go-delve/delve/cmd/dlv@latest

# 啟動調試模式
dlv debug main.go

# 在 delve 中設置斷點
(dlv) break main.main
(dlv) continue
```

**在 VS Code 中調試:**

創建 `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch Package",
      "type": "go",
      "request": "launch",
      "mode": "debug",
      "program": "${workspaceFolder}/main.go"
    }
  ]
}
```

按 F5 開始調試,可以設置斷點單步執行。

#### React 前端調試

**在 VS Code 中:**

安裝 "Debugger for Chrome" 擴展

創建 `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}/web/src"
    }
  ]
}
```

**在瀏覽器中:**

使用 React Developer Tools 擴展:
- Chrome: https://chrome.google.com/webstore (搜索 React Developer Tools)
- Firefox: https://addons.mozilla.org (搜索 React Developer Tools)

---

### 5. 測試流程

#### 後端單元測試

```bash
# 運行所有測試
go test ./...

# 運行特定包的測試
go test ./trader

# 查看測試覆蓋率
go test -cover ./...

# 生成覆蓋率報告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

#### 前端測試

```bash
cd web

# 運行測試
npm test

# 查看覆蓋率
npm test -- --coverage
```

---

## 常見問題

### 1. 編譯錯誤: TA-Lib not found

**錯誤信息:**
```
# github.com/markcheno/go-talib
ld: library not found for -lta_lib
```

**解決方案:**
```bash
# macOS
brew install ta-lib

# Ubuntu/Debian
sudo apt-get install libta-lib0-dev

# 從源碼安裝 (如果上述方法失敗)
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/
./configure --prefix=/usr
make
sudo make install
```

---

### 2. 後端端口被佔用

**錯誤信息:**
```
bind: address already in use
```

**解決方案:**

```bash
# 查找佔用端口的進程
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# 終止進程
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# 或修改端口
# 編輯 .env 文件,修改 NOFX_BACKEND_PORT=8081
```

---

### 3. 前端無法連接後端

**錯誤信息 (瀏覽器控制台):**
```
Failed to fetch
Network Error
```

**排查步驟:**

1. **確認後端正在運行:**
   ```bash
   curl http://localhost:8080/api/health
   # 應返回: {"status":"ok"}
   ```

2. **檢查端口配置:**
   ```bash
   # 檢查 .env 文件
   cat .env | grep PORT

   # 檢查前端 API 配置
   cat web/src/config/api.ts
   ```

3. **檢查防火墻:**
   ```bash
   # 確保端口未被防火墻阻擋
   sudo ufw allow 8080  # Ubuntu
   ```

---

### 4. Go 模塊下載失敗

**錯誤信息:**
```
go: downloading ... connection timeout
```

**解決方案:**

```bash
# 配置 Go 模塊代理 (中國大陸用戶)
go env -w GOPROXY=https://goproxy.cn,direct

# 或使用其他代理
go env -w GOPROXY=https://goproxy.io,direct

# 重新下載
go mod download
```

---

### 5. npm install 失敗

**錯誤信息:**
```
npm ERR! code ECONNRESET
npm ERR! network timeout
```

**解決方案:**

```bash
# 使用國內鏡像
npm config set registry https://registry.npmmirror.com

# 清除緩存並重試
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# 如果仍然失敗,使用 yarn
npm install -g yarn
yarn install
```

---

### 6. AI API 超時或失敗

**錯誤信息 (後端日誌):**
```
DeepSeek API request timeout
```

**排查步驟:**

1. **檢查 API Key:**
   - 確認密鑰正確
   - 檢查賬戶餘額

2. **檢查網絡:**
   ```bash
   # 測試 DeepSeek API 連接
   curl -X POST https://api.deepseek.com/v1/chat/completions \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "deepseek-chat",
       "messages": [{"role": "user", "content": "Hello"}]
     }'
   ```

3. **增加超時時間:**
   - 編輯代碼,增加 HTTP 客戶端超時設置

---

### 7. 數據庫錯誤

**錯誤信息:**
```
database is locked
unable to open database file
```

**解決方案:**

```bash
# 檢查數據庫文件權限
ls -l config.db

# 修復權限
chmod 644 config.db

# 如果數據庫損壞,刪除並重新初始化
rm config.db
# 重啟後端,會自動創建新數據庫
./nofx
```

---

## 調試技巧

### 1. 啟用詳細日誌

編輯 `.env` 文件:
```env
LOG_LEVEL=debug  # 改為 debug 模式
```

重啟後端,會看到更詳細的日誌輸出。

---

### 2. 使用 curl 測試 API

```bash
# 測試健康檢查
curl http://localhost:8080/api/health

# 獲取交易員列表
curl http://localhost:8080/api/traders

# 獲取賬戶信息
curl "http://localhost:8080/api/account?trader_id=YOUR_TRADER_ID"

# 查看倉位
curl "http://localhost:8080/api/positions?trader_id=YOUR_TRADER_ID"
```

---

### 3. 查看決策 JSON 完整內容

```bash
# 找到最新決策文件
ls -lt decision_logs/<trader_id>/ | head -1

# 使用 jq 美化輸出
cat decision_logs/<trader_id>/decision_<timestamp>.json | jq

# 查看 AI 推理過程
cat decision_logs/<trader_id>/decision_<timestamp>.json | jq '.chain_of_thought'

# 查看市場數據
cat decision_logs/<trader_id>/decision_<timestamp>.json | jq '.market_data'
```

---

### 4. 監控系統資源

```bash
# 查看 Go 程序資源佔用
top -p $(pgrep nofx)

# 查看內存使用
ps aux | grep nofx

# 查看網絡連接
netstat -anp | grep nofx
```

---

### 5. Git 工作流

```bash
# 創建功能分支
git checkout -b feature/my-new-feature

# 提交修改
git add .
git commit -m "feat: add new feature"

# 推送到遠程
git push origin feature/my-new-feature

# 創建 Pull Request
# 訪問 GitHub 倉庫頁面,點擊 "New Pull Request"
```

---

## 下一步

恭喜! 您已經成功設置了本地開發環境。

**建議學習路線:**

1. **閱讀源碼**:
   - `main.go` - 程序入口
   - `trader/` - 交易員邏輯
   - `market/` - 市場數據獲取
   - `decision/` - AI 決策流程

2. **修改配置**:
   - 調整決策週期
   - 修改風險參數
   - 添加新的交易對

3. **添加功能**:
   - 新增技術指標
   - 改進 AI 提示詞
   - 優化風控邏輯

4. **貢獻代碼**:
   - Fork 倉庫
   - 提交 Pull Request
   - 參與社區討論

---

## 參考資源

- **項目文檔**: [docs/](docs/)
- **架構文檔**: [docs/architecture/](docs/architecture/)
- **API 文檔**: [docs/api/](docs/api/)
- **故障排除**: [docs/guides/TROUBLESHOOTING.md](docs/guides/TROUBLESHOOTING.md)
- **Telegram 社區**: https://t.me/nofx_dev_community

---

**祝您學習愉快,享受 AI 交易系統開發的樂趣! 🚀**
