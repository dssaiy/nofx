# 🚀 NOFX 云服务器一键部署指南

## ⚡ 超级快速部署 (3分钟完成)

### 方式一: 在线一键执行 (推荐)

登录您的云服务器,执行以下**单行命令**:

```bash
curl -fsSL https://raw.githubusercontent.com/tinkle-community/nofx/dev/scripts/cloud-init.sh | sudo bash
```

**就这么简单!** 🎉

---

### 方式二: 本地脚本执行

如果无法访问 GitHub,可以手动上传脚本:

#### 步骤 1: 上传脚本到服务器
```bash
# 在本地下载脚本
wget https://raw.githubusercontent.com/tinkle-community/nofx/dev/scripts/cloud-init.sh

# 或使用 scp 上传
scp cloud-init.sh root@your_server_ip:/root/
```

#### 步骤 2: 执行脚本
```bash
# SSH 登录服务器
ssh root@your_server_ip

# 赋予执行权限并运行
chmod +x cloud-init.sh
sudo bash cloud-init.sh
```

---

### 方式三: 自定义配置执行

如果需要自定义配置,可以设置环境变量:

```bash
# 设置环境变量
export NOFX_USER="nofx"                    # 创建的用户名
export NOFX_PASSWORD="your_password"       # 用户密码
export NOFX_FRONTEND_PORT="3000"          # Web界面端口
export NOFX_BACKEND_PORT="8080"           # API端口
export NOFX_REPO_BRANCH="dev"             # 仓库分支

# 执行脚本
curl -fsSL https://raw.githubusercontent.com/tinkle-community/nofx/dev/scripts/cloud-init.sh | sudo bash
```

**可选配置环境变量:**

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `NOFX_USER` | 创建的非root用户名 | 不创建 |
| `NOFX_PASSWORD` | 用户密码 | 空 |
| `NOFX_FRONTEND_PORT` | Web界面端口 | 3000 |
| `NOFX_BACKEND_PORT` | API端口 | 8080 |
| `NOFX_REPO_URL` | 仓库地址 | https://github.com/tinkle-community/nofx.git |
| `NOFX_REPO_BRANCH` | 仓库分支 | dev |

---

## 📋 脚本会自动完成什么?

### ✅ 第一步: 系统初始化和安全配置
- 更新系统软件包
- 安装基础工具 (curl, git, vim, htop, jq 等)
- 配置自动安全更新
- 配置防火墙 (开放 22, 3000, 8080, 80, 443 端口)
- 创建非root用户 (可选)

### ✅ 第二步: 安装 Docker 和 Docker Compose
- 自动安装最新版 Docker
- 安装 Docker Compose V2
- 启动 Docker 服务
- 将用户添加到 docker 组
- 验证安装并运行测试

### ✅ 第三步: 克隆项目代码
- 从 GitHub 克隆 NOFX 仓库
- 验证项目结构完整性
- 设置正确的文件权限

### ✅ 第四步: 配置项目文件
- 复制 `.env` 环境变量文件
- 生成 `config.json` 配置文件
- 自动生成随机 JWT 密钥
- 创建必要的工作目录
- 设置文件权限

### ✅ 第五步: 启动服务 (可选)
- 询问是否立即启动服务
- 使用 Docker Compose 构建并启动容器
- 显示访问地址和常用命令

---

## 🎯 脚本执行后的效果

```
╔════════════════════════════════════════════════════════════╗
║          🎉 NOFX 云服务器初始化完成!                    ║
╚════════════════════════════════════════════════════════════╝

📍 安装信息:
   项目目录: /root/nofx
   运行用户: root

🌐 访问地址:
   Web 界面: http://your_server_ip:3000
   API 端点: http://your_server_ip:8080/api/health

🚀 快速启动:
   cd /root/nofx
   ./start.sh start --build

📊 常用命令:
   查看状态: ./start.sh status
   查看日志: ./start.sh logs
   停止服务: ./start.sh stop
   重启服务: ./start.sh restart

🔐 防火墙已开放端口:
   SSH: 22, 2222
   Web: 3000
   API: 8080
   HTTP/HTTPS: 80, 443

📖 下一步:
   1. 访问 Web 界面配置 AI 模型 (DeepSeek/Qwen)
   2. 配置交易所 API (Binance/Hyperliquid/Aster)
   3. 创建交易员并启动自动交易
   4. 监控系统运行状态和决策日志
```

---

## 🔧 手动启动服务 (如果跳过了自动启动)

```bash
# 进入项目目录
cd /root/nofx  # 或 /home/your_user/nofx

# 启动服务 (首次需要构建)
./start.sh start --build

# 查看服务状态
./start.sh status

# 查看实时日志
./start.sh logs
```

---

## 🌐 通过 Web 界面配置

### 1. 访问 Web 界面
打开浏览器访问: `http://your_server_ip:3000`

### 2. 配置 AI 模型
- 点击 **"AI模型配置"**
- 启用 DeepSeek 或 Qwen
- 输入 API 密钥
- 保存配置

**如何获取 API 密钥:**
- **DeepSeek**: https://platform.deepseek.com
- **Qwen**: https://dashscope.console.aliyun.com

### 3. 配置交易所
- 点击 **"交易所配置"**
- 选择交易所 (Binance/Hyperliquid/Aster)
- 输入 API 凭证
- 保存配置

**如何获取 API 凭证:**
- **Binance**: 账户 → API 管理 → 创建 API (启用期货权限)
- **Hyperliquid**: MetaMask 导出私钥
- **Aster**: https://www.asterdex.com/en/api-wallet

### 4. 创建交易员
- 点击 **"创建交易员"**
- 选择 AI 模型 (已配置)
- 选择交易所 (已配置)
- 设置初始余额
- 输入交易员名称
- 创建并启动

---

## 🛡️ 安全建议

### 1. 修改 SSH 端口 (可选)
```bash
sudo vim /etc/ssh/sshd_config
# 修改: Port 2222
sudo systemctl restart sshd
sudo ufw allow 2222/tcp
```

### 2. 配置域名和 HTTPS
```bash
# 安装 Nginx 和 Certbot
sudo apt-get install nginx certbot python3-certbot-nginx -y

# 配置域名
sudo vim /etc/nginx/sites-available/nofx
# (参考 CLOUD_DEPLOYMENT.md 中的 Nginx 配置)

# 获取 SSL 证书
sudo certbot --nginx -d your-domain.com
```

### 3. 启用认证 (生产环境)
编辑 `config.json`:
```json
{
  "admin_mode": false,  // 关闭管理员模式
  "beta_mode": true     // 启用内测模式
}
```

### 4. 定期备份
```bash
# 备份重要数据
tar -czf ~/nofx_backup_$(date +%Y%m%d).tar.gz \
    ~/nofx/config.db \
    ~/nofx/decision_logs/ \
    ~/nofx/config.json
```

---

## ❓ 常见问题

### Q1: 脚本执行失败怎么办?
**A:** 查看错误信息,可能的原因:
- 网络连接问题 (无法访问 GitHub/Docker Hub)
- 系统版本不支持 (建议使用 Ubuntu 20.04+)
- 权限不足 (需要 root 权限)

**解决方案:**
```bash
# 检查网络
ping github.com
ping get.docker.com

# 手动安装 Docker
curl -fsSL https://get.docker.com | sh

# 手动克隆仓库
git clone https://github.com/tinkle-community/nofx.git
```

### Q2: 如何查看详细日志?
```bash
cd /root/nofx
./start.sh logs backend  # 查看后端日志
./start.sh logs frontend # 查看前端日志
```

### Q3: 如何重启服务?
```bash
cd /root/nofx
./start.sh restart
```

### Q4: 如何更新到最新版本?
```bash
cd /root/nofx
./start.sh update
```

### Q5: 如何完全卸载?
```bash
# 停止服务
cd /root/nofx
./start.sh stop

# 删除项目目录
rm -rf /root/nofx

# 卸载 Docker (可选)
sudo apt-get remove docker docker-engine docker.io containerd runc
```

---

## 📚 更多帮助

- **完整部署文档**: `CLOUD_DEPLOYMENT.md`
- **项目 README**: `README.md`
- **GitHub Issues**: https://github.com/tinkle-community/nofx/issues
- **Telegram 社区**: https://t.me/nofx_dev_community

---

## ⚡ 快速命令速查表

```bash
# 一键部署
curl -fsSL https://raw.githubusercontent.com/tinkle-community/nofx/dev/scripts/cloud-init.sh | sudo bash

# 启动服务
cd /root/nofx && ./start.sh start --build

# 查看状态
./start.sh status

# 查看日志
./start.sh logs

# 停止服务
./start.sh stop

# 重启服务
./start.sh restart

# 更新系统
./start.sh update
```

---

🎉 **享受 AI 自动交易的乐趣!**

⚠️ **风险提示**: 加密货币交易有风险,建议小额测试,投资需谨慎!
