#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# NOFX Cloud Server Auto-Initialization Script
# 自动完成云服务器的初始化配置和项目部署
# Usage: curl -fsSL https://raw.githubusercontent.com/.../cloud-init.sh | bash
#        or: bash cloud-init.sh
#        or: NOFX_AUTO_CONFIRM=yes bash cloud-init.sh
# ═══════════════════════════════════════════════════════════════

set -e  # 遇到错误立即退出

# 检测是否通过管道执行 (自动确认模式)
if [ ! -t 0 ]; then
    NOFX_AUTO_CONFIRM="yes"
fi

# ------------------------------------------------------------------------
# Color Definitions
# ------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------
# Utility Functions
# ------------------------------------------------------------------------
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     🚀 NOFX Cloud Server Auto-Initialization Script      ║"
    echo "║            Automated Deployment Made Easy                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}${BOLD}▶ $1${NC}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${CYAN}  → $1${NC}"
}

# ------------------------------------------------------------------------
# Error Handler
# ------------------------------------------------------------------------
error_exit() {
    print_error "$1"
    echo ""
    print_error "脚本执行失败! 请检查错误信息并重试。"
    exit 1
}

# ------------------------------------------------------------------------
# Check if running as root
# ------------------------------------------------------------------------
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 用户运行此脚本"
        echo "使用: sudo bash cloud-init.sh"
        exit 1
    fi
}

# ------------------------------------------------------------------------
# Detect OS
# ------------------------------------------------------------------------
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    else
        error_exit "无法检测操作系统"
    fi

    print_info "检测到系统: $OS $OS_VERSION"

    if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
        print_warning "此脚本主要为 Ubuntu/Debian 系统设计"
        if [ "$NOFX_AUTO_CONFIRM" = "yes" ]; then
            print_info "自动确认模式: 继续执行"
        else
            read -p "是否继续? (y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
}

# ------------------------------------------------------------------------
# Step 1: System Update and Security Configuration
# ------------------------------------------------------------------------
step1_system_init() {
    print_section "第一步: 系统初始化和安全配置"

    # 1.1 更新系统
    print_step "更新系统软件包..."
    apt-get update -qq || error_exit "系统更新失败"
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq || error_exit "系统升级失败"
    print_success "系统更新完成"

    # 1.2 安装基础工具
    print_step "安装基础工具..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        curl \
        wget \
        git \
        vim \
        htop \
        jq \
        ufw \
        unattended-upgrades \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release || error_exit "基础工具安装失败"
    print_success "基础工具安装完成"

    # 1.3 配置自动安全更新
    print_step "配置自动安全更新..."
    dpkg-reconfigure -plow unattended-upgrades >/dev/null 2>&1
    print_success "自动安全更新已启用"

    # 1.4 配置防火墙
    print_step "配置防火墙规则..."

    # 重置防火墙 (如果之前有配置)
    ufw --force reset >/dev/null 2>&1 || true

    # 允许 SSH (多个常用端口)
    ufw allow 22/tcp comment 'SSH' >/dev/null 2>&1
    ufw allow 2222/tcp comment 'SSH Alternative' >/dev/null 2>&1

    # 允许 Web 界面端口
    ufw allow 3000/tcp comment 'NOFX Web UI' >/dev/null 2>&1

    # 允许 API 端口
    ufw allow 8080/tcp comment 'NOFX API' >/dev/null 2>&1

    # 允许 HTTP/HTTPS (Nginx)
    ufw allow 80/tcp comment 'HTTP' >/dev/null 2>&1
    ufw allow 443/tcp comment 'HTTPS' >/dev/null 2>&1

    # 启用防火墙
    echo "y" | ufw enable >/dev/null 2>&1

    print_success "防火墙配置完成"
    ufw status numbered | grep -E "(22|3000|8080|80|443)" | head -5

    # 1.5 创建非 root 用户 (可选)
    if [ ! -z "$NOFX_USER" ]; then
        print_step "创建用户: $NOFX_USER"

        # 检查用户是否存在
        if id "$NOFX_USER" &>/dev/null; then
            print_warning "用户 $NOFX_USER 已存在,跳过创建"
        else
            # 创建用户 (无需密码,通过 SSH key 登录)
            useradd -m -s /bin/bash "$NOFX_USER" || error_exit "用户创建失败"
            usermod -aG sudo "$NOFX_USER" || error_exit "添加sudo权限失败"

            # 设置密码 (如果提供)
            if [ ! -z "$NOFX_PASSWORD" ]; then
                echo "$NOFX_USER:$NOFX_PASSWORD" | chpasswd
                print_success "用户 $NOFX_USER 创建成功 (密码已设置)"
            else
                print_success "用户 $NOFX_USER 创建成功 (请稍后设置密码)"
            fi

            # 允许 sudo 免密码
            echo "$NOFX_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$NOFX_USER
        fi
    fi
}

# ------------------------------------------------------------------------
# Step 2: Install Docker and Docker Compose
# ------------------------------------------------------------------------
step2_install_docker() {
    print_section "第二步: 安装 Docker 和 Docker Compose"

    # 2.1 检查 Docker 是否已安装
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
        print_warning "Docker 已安装 (版本: $DOCKER_VERSION)"
        if [ "$NOFX_AUTO_CONFIRM" = "yes" ]; then
            print_info "自动确认模式: 跳过 Docker 安装"
            return 0
        else
            read -p "是否重新安装? (y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "跳过 Docker 安装"
                return 0
            fi
        fi
    fi

    # 2.2 安装 Docker
    print_step "下载并安装 Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh || error_exit "下载 Docker 安装脚本失败"
    sh /tmp/get-docker.sh >/dev/null 2>&1 || error_exit "Docker 安装失败"
    rm /tmp/get-docker.sh
    print_success "Docker 安装完成"

    # 2.3 启动 Docker 服务
    print_step "启动 Docker 服务..."
    systemctl enable docker >/dev/null 2>&1
    systemctl start docker >/dev/null 2>&1
    print_success "Docker 服务已启动"

    # 2.4 将用户添加到 docker 组
    if [ ! -z "$NOFX_USER" ]; then
        usermod -aG docker "$NOFX_USER" >/dev/null 2>&1
        print_success "用户 $NOFX_USER 已添加到 docker 组"
    fi

    # 2.5 验证安装
    DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
    COMPOSE_VERSION=$(docker compose version | grep -oP '\d+\.\d+\.\d+' | head -1)

    print_success "Docker 版本: $DOCKER_VERSION"
    print_success "Docker Compose 版本: $COMPOSE_VERSION"

    # 2.6 测试 Docker
    print_step "测试 Docker 运行..."
    if docker run --rm hello-world >/dev/null 2>&1; then
        print_success "Docker 运行测试通过"
    else
        error_exit "Docker 运行测试失败"
    fi
}

# ------------------------------------------------------------------------
# Step 3: Install Git and Clone Repository
# ------------------------------------------------------------------------
step3_clone_repo() {
    print_section "第三步: 克隆 NOFX 项目代码"

    # 3.1 确定安装目录
    if [ ! -z "$NOFX_USER" ]; then
        INSTALL_DIR="/home/$NOFX_USER/nofx"
    else
        INSTALL_DIR="/root/nofx"
    fi

    print_info "安装目录: $INSTALL_DIR"

    # 3.2 检查目录是否已存在
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "目录 $INSTALL_DIR 已存在"
        if [ "$NOFX_AUTO_CONFIRM" = "yes" ]; then
            print_info "自动确认模式: 使用现有目录"
            return 0
        else
            read -p "是否删除并重新克隆? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_step "删除旧目录..."
                rm -rf "$INSTALL_DIR"
            else
                print_info "使用现有目录"
                return 0
            fi
        fi
    fi

    # 3.3 克隆仓库
    print_step "克隆 NOFX 仓库..."

    # 获取仓库 URL (默认或从环境变量)
    REPO_URL=${NOFX_REPO_URL:-"https://github.com/dssaiy/nofx.git"}
    REPO_BRANCH=${NOFX_REPO_BRANCH:-"dev"}

    print_info "仓库地址: $REPO_URL"
    print_info "分支: $REPO_BRANCH"

    if [ ! -z "$NOFX_USER" ]; then
        # 以指定用户身份克隆
        su - "$NOFX_USER" -c "git clone -b $REPO_BRANCH $REPO_URL $INSTALL_DIR" || error_exit "仓库克隆失败"
    else
        git clone -b "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR" || error_exit "仓库克隆失败"
    fi

    print_success "项目代码克隆完成"

    # 3.4 验证项目结构
    if [ -f "$INSTALL_DIR/docker-compose.yml" ] && [ -f "$INSTALL_DIR/start.sh" ]; then
        print_success "项目结构验证通过"
    else
        error_exit "项目结构不完整,请检查仓库"
    fi
}

# ------------------------------------------------------------------------
# Step 4: Configure Project
# ------------------------------------------------------------------------
step4_configure() {
    print_section "第四步: 配置项目文件"

    # 4.1 确定项目目录
    if [ ! -z "$NOFX_USER" ]; then
        INSTALL_DIR="/home/$NOFX_USER/nofx"
    else
        INSTALL_DIR="/root/nofx"
    fi

    cd "$INSTALL_DIR" || error_exit "无法进入项目目录"

    # 4.2 复制环境变量文件
    print_step "配置环境变量文件..."
    if [ ! -f ".env" ]; then
        cp .env.example .env || error_exit "复制 .env 失败"

        # 自定义端口 (如果提供)
        if [ ! -z "$NOFX_FRONTEND_PORT" ]; then
            sed -i "s/NOFX_FRONTEND_PORT=.*/NOFX_FRONTEND_PORT=$NOFX_FRONTEND_PORT/" .env
        fi
        if [ ! -z "$NOFX_BACKEND_PORT" ]; then
            sed -i "s/NOFX_BACKEND_PORT=.*/NOFX_BACKEND_PORT=$NOFX_BACKEND_PORT/" .env
        fi

        print_success ".env 文件创建完成"
    else
        print_warning ".env 文件已存在,跳过"
    fi

    # 4.3 复制配置文件
    print_step "配置 config.json 文件..."
    if [ ! -f "config.json" ]; then
        cp config.json.example config.json || error_exit "复制 config.json 失败"

        # 生成随机 JWT 密钥
        JWT_SECRET=$(openssl rand -base64 32)

        # 更新配置文件
        cat > config.json <<EOF
{
  "admin_mode": true,
  "beta_mode": false,
  "api_server_port": ${NOFX_BACKEND_PORT:-8080},
  "use_default_coins": true,
  "default_coins": ["BTCUSDT", "ETHUSDT", "SOLUSDT", "BNBUSDT", "XRPUSDT", "DOGEUSDT", "ADAUSDT", "HYPEUSDT"],
  "coin_pool_api_url": "",
  "oi_top_api_url": "",
  "max_daily_loss": 10.0,
  "max_drawdown": 20.0,
  "stop_trading_minutes": 60,
  "leverage": {
    "btc_eth_leverage": 5,
    "altcoin_leverage": 5
  },
  "jwt_secret": "$JWT_SECRET",
  "data_k_line_time": "3m"
}
EOF
        print_success "config.json 文件创建完成"
        print_info "JWT 密钥已自动生成: ${JWT_SECRET:0:20}..."
    else
        print_warning "config.json 文件已存在,跳过"
    fi

    # 4.4 设置文件权限
    print_step "设置文件权限..."
    chmod +x start.sh

    if [ ! -z "$NOFX_USER" ]; then
        chown -R "$NOFX_USER:$NOFX_USER" "$INSTALL_DIR"
        print_success "文件权限设置完成 (所有者: $NOFX_USER)"
    else
        print_success "文件权限设置完成"
    fi

    # 4.5 创建必要的目录
    print_step "创建工作目录..."
    mkdir -p decision_logs coin_pool_cache
    if [ ! -z "$NOFX_USER" ]; then
        chown -R "$NOFX_USER:$NOFX_USER" decision_logs coin_pool_cache
    fi
    print_success "工作目录创建完成"
}

# ------------------------------------------------------------------------
# Optional: Start Services
# ------------------------------------------------------------------------
step5_start_services() {
    print_section "第五步: 启动服务 (可选)"

    # 确定项目目录
    if [ ! -z "$NOFX_USER" ]; then
        INSTALL_DIR="/home/$NOFX_USER/nofx"
    else
        INSTALL_DIR="/root/nofx"
    fi

    cd "$INSTALL_DIR" || error_exit "无法进入项目目录"

    echo ""
    print_warning "是否现在启动 NOFX 服务?"
    print_info "如果选择'否',您可以稍后手动启动:"
    print_info "  cd $INSTALL_DIR"
    print_info "  ./start.sh start --build"
    echo ""

    if [ "$NOFX_AUTO_CONFIRM" = "yes" ]; then
        print_info "自动确认模式: 跳过服务启动"
        print_info "请稍后手动启动服务"
        return 0
    fi

    read -p "现在启动服务? (y/n): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "正在启动服务 (首次启动需要构建镜像,请耐心等待)..."

        if [ ! -z "$NOFX_USER" ]; then
            su - "$NOFX_USER" -c "cd $INSTALL_DIR && ./start.sh start --build"
        else
            ./start.sh start --build
        fi

        print_success "服务启动完成!"

        # 获取实际端口
        FRONTEND_PORT=$(grep "^NOFX_FRONTEND_PORT=" .env | cut -d'=' -f2 | tr -d ' "'"'" || echo "3000")
        BACKEND_PORT=$(grep "^NOFX_BACKEND_PORT=" .env | cut -d'=' -f2 | tr -d ' "'"'" || echo "8080")

        echo ""
        print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        print_success "  NOFX 服务已成功启动!"
        print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        SERVER_IP=$(curl -s ifconfig.me || echo "your_server_ip")
        print_info "Web 界面: http://$SERVER_IP:$FRONTEND_PORT"
        print_info "API 端点: http://$SERVER_IP:$BACKEND_PORT"
        echo ""
        print_info "查看日志: cd $INSTALL_DIR && ./start.sh logs"
        print_info "停止服务: cd $INSTALL_DIR && ./start.sh stop"
        echo ""
    else
        print_info "已跳过服务启动"
    fi
}

# ------------------------------------------------------------------------
# Final Summary
# ------------------------------------------------------------------------
print_summary() {
    # 确定项目目录
    if [ ! -z "$NOFX_USER" ]; then
        INSTALL_DIR="/home/$NOFX_USER/nofx"
    else
        INSTALL_DIR="/root/nofx"
    fi

    # 获取端口配置
    if [ -f "$INSTALL_DIR/.env" ]; then
        FRONTEND_PORT=$(grep "^NOFX_FRONTEND_PORT=" "$INSTALL_DIR/.env" | cut -d'=' -f2 | tr -d ' "'"'" || echo "3000")
        BACKEND_PORT=$(grep "^NOFX_BACKEND_PORT=" "$INSTALL_DIR/.env" | cut -d'=' -f2 | tr -d ' "'"'" || echo "8080")
    else
        FRONTEND_PORT="3000"
        BACKEND_PORT="8080"
    fi

    SERVER_IP=$(curl -s ifconfig.me || echo "your_server_ip")

    echo ""
    echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║          🎉 NOFX 云服务器初始化完成!                    ║${NC}"
    echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📍 安装信息:${NC}"
    echo -e "   项目目录: ${YELLOW}$INSTALL_DIR${NC}"
    if [ ! -z "$NOFX_USER" ]; then
        echo -e "   运行用户: ${YELLOW}$NOFX_USER${NC}"
    fi
    echo ""
    echo -e "${CYAN}${BOLD}🌐 访问地址:${NC}"
    echo -e "   Web 界面: ${GREEN}http://$SERVER_IP:$FRONTEND_PORT${NC}"
    echo -e "   API 端点: ${GREEN}http://$SERVER_IP:$BACKEND_PORT/api/health${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}🚀 快速启动:${NC}"
    echo -e "   ${YELLOW}cd $INSTALL_DIR${NC}"
    echo -e "   ${YELLOW}./start.sh start --build${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📊 常用命令:${NC}"
    echo -e "   查看状态: ${YELLOW}./start.sh status${NC}"
    echo -e "   查看日志: ${YELLOW}./start.sh logs${NC}"
    echo -e "   停止服务: ${YELLOW}./start.sh stop${NC}"
    echo -e "   重启服务: ${YELLOW}./start.sh restart${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}🔐 防火墙已开放端口:${NC}"
    echo -e "   SSH: 22, 2222"
    echo -e "   Web: ${FRONTEND_PORT}"
    echo -e "   API: ${BACKEND_PORT}"
    echo -e "   HTTP/HTTPS: 80, 443"
    echo ""
    echo -e "${CYAN}${BOLD}📖 下一步:${NC}"
    echo -e "   1. 访问 Web 界面配置 AI 模型 (DeepSeek/Qwen)"
    echo -e "   2. 配置交易所 API (Binance/Hyperliquid/Aster)"
    echo -e "   3. 创建交易员并启动自动交易"
    echo -e "   4. 监控系统运行状态和决策日志"
    echo ""
    echo -e "${YELLOW}${BOLD}⚠️  重要提示:${NC}"
    echo -e "   - 首次访问需要配置 AI 模型和交易所"
    echo -e "   - 建议小额资金测试 (100-500 USDT)"
    echo -e "   - 定期查看决策日志和账户状态"
    echo -e "   - 生产环境请配置 HTTPS 和域名"
    echo ""
    echo -e "${GREEN}${BOLD}完整部署文档: $INSTALL_DIR/CLOUD_DEPLOYMENT.md${NC}"
    echo ""
}

# ------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------
main() {
    # 显示横幅
    print_banner

    # 检查是否为 root
    check_root

    # 检测操作系统
    detect_os

    # 显示配置信息
    echo ""
    print_info "初始化配置:"
    print_info "  创建用户: ${NOFX_USER:-跳过}"
    print_info "  前端端口: ${NOFX_FRONTEND_PORT:-3000}"
    print_info "  后端端口: ${NOFX_BACKEND_PORT:-8080}"
    print_info "  仓库地址: ${NOFX_REPO_URL:-https://github.com/dssaiy/nofx.git}"
    print_info "  仓库分支: ${NOFX_REPO_BRANCH:-dev}"
    echo ""

    if [ "$NOFX_AUTO_CONFIRM" = "yes" ]; then
        print_info "自动确认模式: 开始初始化"
    else
        read -p "开始初始化? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "已取消初始化"
            exit 0
        fi
    fi

    # 记录开始时间
    START_TIME=$(date +%s)

    # 执行各个步骤
    step1_system_init
    step2_install_docker
    step3_clone_repo
    step4_configure
    step5_start_services

    # 记录结束时间
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    # 显示总结
    print_summary

    print_success "总耗时: ${DURATION} 秒"
}

# ------------------------------------------------------------------------
# Execute
# ------------------------------------------------------------------------
main "$@"
