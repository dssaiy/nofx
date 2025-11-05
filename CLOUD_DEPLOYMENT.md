# 🚀 NOFX 云服务器部署完整指南

本指南将帮助您在全新的云服务器上从零开始部署 NOFX AI 交易系统。

---

## 📋 服务器要求

### 最低配置
- **CPU**: 2核心
- **内存**: 4GB RAM
- **存储**: 20GB 可用空间
- **系统**: Ubuntu 20.04/22.04 LTS (推荐) 或 Debian 11+

### 推荐配置
- **CPU**: 4核心
- **内存**: 8GB RAM
- **存储**: 50GB SSD
- **系统**: Ubuntu 22.04 LTS

### 网络要求
- 开放端口: 8080 (API), 3000 (Web界面), 22 (SSH)
- 稳定的互联网连接
- 能访问: Binance API, DeepSeek/Qwen API

---

## 🔐 第一步: 服务器初始化 (安全配置)

### 1.1 登录服务器
```bash
# 使用 SSH 登录 (替换为您的服务器 IP)
ssh root@your_server_ip
```

### 1.2 创建非 root 用户 (推荐)
```bash
# 创建新用户 (替换 nofx 为您想要的用户名)
adduser nofx

# 赋予 sudo 权限
usermod -aG sudo nofx

# 切换到新用户
su - nofx
```

### 1.3 配置防火墙
```bash
# 安装 UFW
sudo apt-get update
sudo apt-get install ufw -y

# 允许 SSH (防止被锁定)
sudo ufw allow 22/tcp

# 允许 Web 界面端口
sudo ufw allow 3000/tcp

# 允许 API 端口
sudo ufw allow 8080/tcp

# 启用防火墙
sudo ufw enable

# 查看状态
sudo ufw status
```

---

## 📦 第二步: 安装必要软件

### 2.1 更新系统
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2.2 安装 Docker 和 Docker Compose
```bash
# 安装 Docker (官方脚本)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 刷新组权限 (或重新登录)
newgrp docker

# 验证安装
docker --version
docker compose version

# 测试运行
docker run hello-world
```

**预期输出:**
```
Docker version 24.x.x
Docker Compose version 2.x.x
Hello from Docker!
```

### 2.3 安装 Git
```bash
sudo apt-get install git -y
git --version
```

### 2.4 安装其他工具 (可选但推荐)
```bash
# 安装 vim、curl、wget、jq
sudo apt-get install vim curl wget jq -y

# 安装 htop (系统监控)
sudo apt-get install htop -y
```

---

## 🔽 第三步: 下载项目代码

### 3.1 克隆仓库
```bash
# 进入工作目录
cd ~

# 克隆项目 (替换为实际的仓库地址)
git clone https://github.com/tinkle-community/nofx.git

# 进入项目目录
cd nofx

# 查看当前分支
git branch
```

### 3.2 检查目录结构
```bash
ls -la
# 应该看到: docker-compose.yml, start.sh, config.json.example 等文件
```

---

## ⚙️ 第四步: 配置项目

### 4.1 复制环境变量文件
```bash
cp .env.example .env
```

### 4.2 编辑 .env 文件 (可选)
```bash
vim .env
```

**修改端口 (如需要):**
```bash
# 默认配置
NOFX_BACKEND_PORT=8080
NOFX_FRONTEND_PORT=3000
NOFX_TIMEZONE=Asia/Shanghai
```

### 4.3 复制配置文件模板
```bash
cp config.json.example config.json
```

### 4.4 编辑 config.json (基础配置)
```bash
vim config.json
```

**最小配置示例:**
```json
{
  "admin_mode": true,
  "beta_mode": false,
  "api_server_port": 8080,
  "use_default_coins": true,
  "default_coins": ["BTCUSDT", "ETHUSDT", "SOLUSDT"],
  "leverage": {
    "btc_eth_leverage": 5,
    "altcoin_leverage": 5
  },
  "jwt_secret": "your-secure-random-jwt-secret-key-change-this"
}
```

**⚠️ 重要配置说明:**
- `admin_mode: true` - 管理员模式,无需登录 (生产环境建议设为 false)
- `jwt_secret` - 请务必修改为随机字符串
- `leverage` - 杠杆配置,子账户最高 5x
- **AI 模型和交易员配置通过 Web 界面完成**

### 4.5 生成安全的 JWT 密钥 (推荐)
```bash
# 生成 32 字节随机字符串
openssl rand -base64 32

# 复制输出,替换 config.json 中的 jwt_secret
```

---

## 🚀 第五步: 部署系统

### 5.1 赋予启动脚本执行权限
```bash
chmod +x start.sh
```

### 5.2 首次启动 (构建镜像)
```bash
./start.sh start --build
```

**预期输出:**
```
[INFO] 使用 Docker Compose 命令: docker compose
[SUCCESS] Docker 和 Docker Compose 已安装
[SUCCESS] 环境变量文件存在
[SUCCESS] 配置文件存在
[INFO] 正在启动 NOFX AI Trading System...
[INFO] 重新构建镜像...
Creating nofx-backend  ... done
Creating nofx-frontend ... done
[SUCCESS] 服务已启动！
[INFO] Web 界面: http://localhost:3000
[INFO] API 端点: http://localhost:8080
```

### 5.3 检查服务状态
```bash
./start.sh status
```

**预期输出:**
```
[INFO] 服务状态:
NAME                COMMAND                  SERVICE      STATUS
nofx-backend        "./nofx"                 backend      running
nofx-frontend       "nginx -g 'daemon of…"   frontend     running
```

### 5.4 查看实时日志
```bash
# 查看所有日志
./start.sh logs

# 只查看后端日志
./start.sh logs backend

# 只查看前端日志
./start.sh logs frontend
```

---

## 🌐 第六步: 访问 Web 界面

### 6.1 本地访问 (测试)
```bash
# 在服务器上测试
curl http://localhost:3000
curl http://localhost:8080/api/health
```

### 6.2 远程访问

**方式 1: 直接通过 IP 访问 (临时测试用)**
```
http://your_server_ip:3000
```

**方式 2: 配置域名 + Nginx (推荐生产环境)**

#### 安装 Nginx
```bash
sudo apt-get install nginx -y
```

#### 配置反向代理
```bash
sudo vim /etc/nginx/sites-available/nofx
```

**Nginx 配置内容:**
```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为您的域名或 IP

    # 前端
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 启用站点
```bash
# 创建符号链接
sudo ln -s /etc/nginx/sites-available/nofx /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx

# 开启 HTTP 端口
sudo ufw allow 80/tcp
```

**现在可以通过域名访问:**
```
http://your-domain.com
```

---

## 🔐 第七步: 配置 HTTPS (可选但推荐)

### 7.1 安装 Certbot
```bash
sudo apt-get install certbot python3-certbot-nginx -y
```

### 7.2 获取 SSL 证书
```bash
# 自动配置 HTTPS
sudo certbot --nginx -d your-domain.com

# 按提示输入邮箱和同意条款
```

### 7.3 配置自动续期
```bash
# 测试自动续期
sudo certbot renew --dry-run

# 查看定时任务 (certbot 自动添加)
sudo systemctl status certbot.timer
```

### 7.4 开启 HTTPS 端口
```bash
sudo ufw allow 443/tcp
```

**现在可以通过 HTTPS 访问:**
```
https://your-domain.com
```

---

## 🎯 第八步: 通过 Web 界面配置交易员

### 8.1 访问 Web 界面
打开浏览器访问: `http://your-domain.com` (或 `http://your_server_ip:3000`)

### 8.2 配置 AI 模型
1. 点击 **"AI模型配置"** 按钮
2. 启用 DeepSeek 或 Qwen (或两者)
3. 输入您的 API 密钥:
   - DeepSeek: `sk-xxxxxxxxxx`
   - Qwen: `sk-xxxxxxxxxx`
4. 点击 **"保存配置"**

### 8.3 配置交易所
1. 点击 **"交易所配置"** 按钮
2. 选择交易所 (Binance/Hyperliquid/Aster)
3. 输入 API 凭证:
   - Binance: API Key + Secret Key
   - Hyperliquid: Private Key + Wallet Address
   - Aster: User + Signer + Private Key
4. 点击 **"保存配置"**

### 8.4 创建交易员
1. 点击 **"创建交易员"** 按钮
2. 填写信息:
   - 选择 AI 模型 (已配置的)
   - 选择交易所 (已配置的)
   - 设置初始余额 (用于计算盈亏)
   - 输入交易员名称
3. 点击 **"创建交易员"**

### 8.5 启动交易
1. 在交易员列表中找到您的交易员
2. 点击 **"启动"** 按钮
3. 系统开始自动交易!

---

## 📊 第九步: 监控和管理

### 9.1 查看实时日志
```bash
# 查看交易决策日志
./start.sh logs backend

# 持续监控 (Ctrl+C 退出)
./start.sh logs -f
```

### 9.2 查看系统状态
```bash
# 查看容器状态
./start.sh status

# 查看资源使用
docker stats

# 查看磁盘使用
df -h
```

### 9.3 重启服务
```bash
# 重启所有服务
./start.sh restart

# 只重启后端
docker compose restart backend

# 只重启前端
docker compose restart frontend
```

### 9.4 停止服务
```bash
# 停止服务 (保留数据)
./start.sh stop

# 停止并删除容器 (保留数据)
docker compose down

# 完全清理 (删除所有数据)
./start.sh clean
```

---

## 🛡️ 第十步: 安全加固 (推荐生产环境)

### 10.1 修改 SSH 端口
```bash
sudo vim /etc/ssh/sshd_config

# 修改端口 (例如改为 2222)
Port 2222

# 禁用 root 登录
PermitRootLogin no

# 重启 SSH
sudo systemctl restart sshd

# 更新防火墙
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

### 10.2 配置自动更新
```bash
sudo apt-get install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 10.3 限制 API 访问 (仅本地)
编辑 `docker-compose.yml`:
```yaml
services:
  backend:
    ports:
      - "127.0.0.1:8080:8080"  # 只允许本地访问
```

### 10.4 启用 2FA 认证
在 `config.json` 中:
```json
{
  "admin_mode": false,  # 关闭管理员模式
  "beta_mode": true     # 启用内测模式 (需要邀请码)
}
```

---

## 📦 数据备份

### 11.1 备份重要数据
```bash
# 创建备份目录
mkdir -p ~/backups

# 备份数据库和日志
tar -czf ~/backups/nofx_backup_$(date +%Y%m%d_%H%M%S).tar.gz \
    ~/nofx/config.db \
    ~/nofx/decision_logs/ \
    ~/nofx/config.json

# 列出备份
ls -lh ~/backups/
```

### 11.2 自动备份脚本
```bash
# 创建备份脚本
vim ~/backup_nofx.sh
```

**脚本内容:**
```bash
#!/bin/bash
BACKUP_DIR=~/backups
NOFX_DIR=~/nofx
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/nofx_backup_$DATE.tar.gz \
    $NOFX_DIR/config.db \
    $NOFX_DIR/decision_logs/ \
    $NOFX_DIR/config.json

# 只保留最近 7 天的备份
find $BACKUP_DIR -name "nofx_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: nofx_backup_$DATE.tar.gz"
```

**设置定时任务:**
```bash
chmod +x ~/backup_nofx.sh

# 编辑 crontab
crontab -e

# 添加每天凌晨 3 点自动备份
0 3 * * * ~/backup_nofx.sh >> ~/backup.log 2>&1
```

---

## 🔄 更新系统

### 12.1 拉取最新代码
```bash
cd ~/nofx
git pull
```

### 12.2 重新构建并启动
```bash
./start.sh start --build
```

### 12.3 快速更新命令
```bash
./start.sh update
```

---

## 🐛 常见问题排查

### 问题 1: 端口被占用
```bash
# 查看端口占用
sudo lsof -i :3000
sudo lsof -i :8080

# 杀死占用进程
sudo kill -9 <PID>
```

### 问题 2: Docker 权限错误
```bash
# 确保用户在 docker 组
sudo usermod -aG docker $USER

# 重新登录或刷新组
newgrp docker
```

### 问题 3: 容器无法启动
```bash
# 查看详细日志
docker compose logs backend
docker compose logs frontend

# 重新构建镜像
docker compose build --no-cache
docker compose up -d
```

### 问题 4: 无法访问 Web 界面
```bash
# 检查容器状态
docker compose ps

# 检查防火墙
sudo ufw status

# 测试本地连接
curl http://localhost:3000
```

### 问题 5: API 健康检查失败
```bash
# 手动测试 API
curl http://localhost:8080/api/health

# 查看后端日志
docker compose logs backend

# 检查数据库文件
ls -lh config.db
```

---

## 📈 性能优化建议

### 1. 调整 Docker 资源限制
编辑 `docker-compose.yml`:
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

### 2. 启用日志轮换
已在 `docker-compose.yml` 中配置:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 3. 定期清理 Docker 资源
```bash
# 清理未使用的镜像
docker image prune -a

# 清理未使用的卷
docker volume prune

# 清理所有未使用资源 (谨慎使用)
docker system prune -a
```

---

## 🆘 获取帮助

- **GitHub Issues**: https://github.com/tinkle-community/nofx/issues
- **官方文档**: 项目 README.md
- **Telegram 社区**: https://t.me/nofx_dev_community

---

## ✅ 部署检查清单

- [ ] 服务器初始化完成 (创建用户、配置防火墙)
- [ ] Docker 和 Docker Compose 已安装
- [ ] 项目代码已克隆
- [ ] .env 文件已配置
- [ ] config.json 已配置基础设置
- [ ] Docker 容器成功启动
- [ ] 可以访问 Web 界面 (http://your_server_ip:3000)
- [ ] API 健康检查通过 (http://your_server_ip:8080/api/health)
- [ ] Nginx 反向代理已配置 (可选)
- [ ] HTTPS 证书已配置 (可选)
- [ ] AI 模型已配置 (通过 Web 界面)
- [ ] 交易所已配置 (通过 Web 界面)
- [ ] 交易员已创建并启动
- [ ] 数据备份脚本已配置
- [ ] 监控和日志查看正常

---

🎉 **恭喜! 您已成功在云服务器上部署 NOFX AI 交易系统!**

**下一步:**
1. 通过 Web 界面配置 AI 模型和交易所
2. 创建交易员并开始测试
3. 监控系统运行状态和交易决策
4. 定期备份重要数据
5. 根据需要调整策略和参数

**⚠️ 风险提示:**
- 请使用小额资金测试 (建议 100-500 USDT)
- 持续监控系统运行状态
- 定期查看 AI 决策日志
- 注意账户余额变化
- 加密货币交易有风险,投资需谨慎!
