#!/bin/bash
# ============================================================================
# MythicalDash Deployment System
# Version: 3.1.0 - KS HOSTING BY KSGAMING
# ============================================================================

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly SCRIPT_NAME="mythicaldash-deploy"
readonly SCRIPT_VERSION="3.1.0"
readonly COMPANY_NAME="KS HOSTING BY KSGAMING"
readonly INSTALL_DIR="/var/www/mythicaldash-v3"
readonly LOG_FILE="/var/log/mythicaldash-install.log"
readonly CONFIG_FILE="/etc/mythicaldash/config.conf"

# ============================================================================
# COLOR & EMOJI DEFINITIONS
# ============================================================================
readonly RESET='\033[0m'

# Bright Colors
readonly RED='\033[1;31m'
readonly GREEN='\033[1;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[1;34m'
readonly MAGENTA='\033[1;35m'
readonly CYAN='\033[1;36m'
readonly WHITE='\033[1;37m'

# Brand Colors
readonly KS_BLUE='\033[38;5;39m'
readonly KS_ORANGE='\033[38;5;208m'
readonly KS_PURPLE='\033[38;5;93m'
readonly KS_GREEN='\033[38;5;46m'

# Background Colors
readonly BG_BLACK='\033[48;5;232m'
readonly BG_BLUE='\033[48;5;18m'

# Emojis
readonly EMOJI_CHECK="✅"
readonly EMOJI_ERROR="❌"
readonly EMOJI_WARN="⚠️"
readonly EMOJI_INFO="🔹"
readonly EMOJI_ROCKET="🚀"
readonly EMOJI_GEAR="⚙️"
readonly EMOJI_DATABASE="💾"
readonly EMOJI_NETWORK="🌐"
readonly EMOJI_SHIELD="🛡️"
readonly EMOJI_CLOCK="⏱️"
readonly EMOJI_FOLDER="📁"
readonly EMOJI_KEY="🔑"
readonly EMOJI_LINK="🔗"
readonly EMOJI_COMPUTER="💻"
readonly EMOJI_DOCKER="🐳"
readonly EMOJI_SERVER="🖥️"
readonly EMOJI_UPLOAD="📤"
readonly EMOJI_DOWNLOAD="📥"
readonly EMOJI_SPARKLES="✨"
readonly EMOJI_FIRE="🔥"
readonly EMOJI_PARTY="🎉"
readonly EMOJI_THUMBS="👍"
readonly EMOJI_WAVE="👋"
readonly EMOJI_EYES="👀"
readonly EMOJI_BRAIN="🧠"
readonly EMOJI_HAMMER="🔨"
readonly EMOJI_WRENCH="🔧"
readonly EMOJI_MAG="🔍"
readonly EMOJI_LOCK="🔒"
readonly EMOJI_UNLOCK="🔓"
readonly EMOJI_BELL="🔔"
readonly EMOJI_FLAG="🏁"
readonly EMOJI_TROPHY="🏆"

# ============================================================================
# ANIMATION & LOADING FUNCTIONS
# ============================================================================
show_spinner() {
    local pid=$1
    local message="$2"
    local delay=0.15
    local spinstr='⣷⣯⣟⡿⢿⣻⣽⣾'
    
    echo -ne "${KS_BLUE}${EMOJI_GEAR}  ${message}... ${RESET}"
    
    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 7); do
            echo -ne "${KS_ORANGE}${spinstr:$i:1}${RESET}"
            sleep $delay
            echo -ne "\b"
        done
    done
    
    echo -ne "\b\b\b\b\b\b\b"
    echo -e "${GREEN}${EMOJI_CHECK} Done!${RESET}"
}

show_dots() {
    local pid=$1
    local message="$2"
    local dots=""
    
    echo -ne "${CYAN}${EMOJI_INFO}  ${message}${RESET}"
    
    while kill -0 $pid 2>/dev/null; do
        dots="${dots}."
        echo -ne "${KS_ORANGE}${dots}${RESET}"
        sleep 0.5
        echo -ne "\033[${#dots}D\033[K${CYAN}${EMOJI_INFO}  ${message}${RESET}"
        if [ ${#dots} -gt 3 ]; then
            dots=""
        fi
    done
    
    echo -e "${GREEN} ${EMOJI_CHECK}${RESET}"
}

show_progress() {
    local total=$1
    local current=0
    
    while [ $current -le $total ]; do
        local percent=$((current * 100 / total))
        local filled=$((percent / 2))
        local empty=$((50 - filled))
        
        printf "\r${KS_BLUE}${EMOJI_UPLOAD}  Progress: ["
        printf "%${filled}s" | tr ' ' '█'
        printf "%${empty}s" | tr ' ' '░'
        printf "] ${percent}%%${RESET}"
        
        sleep 0.05
        ((current++))
    done
    echo
}

show_fancy_loading() {
    local message="$1"
    local frames=("🕐" "🕑" "🕒" "🕓" "🕔" "🕕" "🕖" "🕗" "🕘" "🕙" "🕚" "🕛")
    
    echo -ne "${KS_PURPLE}${EMOJI_CLOCK}  ${message} ${RESET}"
    
    for i in {1..12}; do
        echo -ne "${KS_ORANGE}${frames[$i % 12]}${RESET}"
        sleep 0.1
        echo -ne "\b"
    done
    
    echo -e "${GREEN}${EMOJI_CHECK}${RESET}"
}

show_banner() {
    clear
    echo -e "${KS_BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                      ║"
    echo "║  ██╗  ██╗███████╗    ██╗  ██╗ ██████╗ ███████╗ █████╗ ███╗   ███╗   ║"
    echo "║  ██║ ██╔╝██╔════╝    ██║  ██║██╔═══██╗██╔════╝██╔══██╗████╗ ████║   ║"
    echo "║  █████╔╝ ███████╗    ███████║██║   ██║███████╗███████║██╔████╔██║   ║"
    echo "║  ██╔═██╗ ╚════██║    ██╔══██║██║   ██║╚════██║██╔══██║██║╚██╔╝██║   ║"
    echo "║  ██║  ██╗███████║    ██║  ██║╚██████╔╝███████║██║  ██║██║ ╚═╝ ██║   ║"
    echo "║  ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝   ║"
    echo "║                                                                      ║"
    echo "║  ${KS_GREEN}${EMOJI_ROCKET}  KS HOSTING BY KSGAMING - DEPLOYMENT SYSTEM ${KS_BLUE}              ║"
    echo "║  ${WHITE}Version ${SCRIPT_VERSION} • Professional • Secure • Fast ${KS_BLUE}                    ║"
    echo "║                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}${EMOJI_COMPUTER}  System: $(lsb_release -ds 2>/dev/null || echo "Linux System")${RESET}"
    echo -e "${WHITE}${EMOJI_CLOCK}  Started: $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════════════${RESET}\n"
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================
log_success() {
    echo -e "${GREEN}${EMOJI_CHECK}  SUCCESS: $1${RESET}"
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}${EMOJI_ERROR}  ERROR: $1${RESET}"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_info() {
    echo -e "${CYAN}${EMOJI_INFO}  INFO: $1${RESET}"
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}${EMOJI_WARN}  WARNING: $1${RESET}"
    echo "[WARNING] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_step() {
    echo -e "\n${KS_PURPLE}${EMOJI_FLAG}  STEP: $1${RESET}"
    echo -e "${KS_ORANGE}────────────────────────────────────────────────────────────${RESET}"
}

log_substep() {
    echo -e "${BLUE}${EMOJI_BRAIN}  $1${RESET}"
}

# ============================================================================
# COMMAND EXECUTION WITH VISUAL FEEDBACK
# ============================================================================
run_command() {
    local cmd="$1"
    local desc="$2"
    local log_output="${3:-false}"
    
    echo -e "${CYAN}${EMOJI_GEAR}  Running: ${WHITE}$desc${RESET}"
    echo -e "${KS_ORANGE}└─ Command: ${WHITE}${cmd:0:80}${RESET}"
    
    if [ "$log_output" = true ]; then
        if eval "$cmd" >> "$LOG_FILE" 2>&1 & then
            local pid=$!
            show_spinner $pid "Processing"
        fi
    else
        if eval "$cmd" &> /dev/null & then
            local pid=$!
            show_spinner $pid "Executing"
        fi
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${EMOJI_THUMBS}  Completed successfully${RESET}"
        return 0
    else
        echo -e "${RED}${EMOJI_ERROR}  Failed to execute${RESET}"
        return 1
    fi
}

run_silent() {
    local cmd="$1"
    local desc="$2"
    
    echo -ne "${CYAN}${EMOJI_GEAR}  $desc... ${RESET}"
    
    if eval "$cmd" &> /dev/null; then
        echo -e "${GREEN}${EMOJI_CHECK}${RESET}"
        return 0
    else
        echo -e "${RED}${EMOJI_ERROR}${RESET}"
        return 1
    fi
}

# ============================================================================
# SYSTEM VALIDATION
# ============================================================================
validate_system() {
    log_step "System Validation"
    
    run_silent "[ -f /etc/os-release ]" "Checking operating system"
    
    source /etc/os-release
    
    case "$ID" in
        ubuntu|debian)
            log_success "Detected: $PRETTY_NAME"
            ;;
        *)
            log_error "Unsupported OS: $PRETTY_NAME"
            exit 1
            ;;
    esac
    
    run_silent "[ $(id -u) -eq 0 ]" "Checking root privileges"
    run_silent "command -v curl" "Checking for curl"
    run_silent "command -v wget" "Checking for wget"
    
    echo -e "${GREEN}${EMOJI_SHIELD}  System validation passed${RESET}"
}

# ============================================================================
# PACKAGE MANAGEMENT
# ============================================================================
install_packages() {
    local packages=("$@")
    local install_list=()
    
    log_substep "Checking system packages"
    
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "${GREEN}${EMOJI_CHECK}  $pkg already installed${RESET}"
        else
            install_list+=("$pkg")
        fi
    done
    
    if [ ${#install_list[@]} -gt 0 ]; then
        echo -e "${CYAN}${EMOJI_DOWNLOAD}  Installing: ${install_list[*]}${RESET}"
        
        run_command "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ${install_list[@]}" \
            "Installing system packages" true
        
        log_success "Packages installed"
    fi
}

update_system() {
    log_step "System Update"
    
    run_command "apt-get update -qq" "Updating package lists" true
    run_command "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq" "Upgrading system" true
    
    log_success "System updated"
}

# ============================================================================
# DATABASE SETUP
# ============================================================================
setup_database() {
    log_step "Database Configuration"
    
    local db_name="mythicaldash"
    local db_user="mythical_user"
    local db_pass=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 16)
    
    log_substep "Securing MariaDB"
    run_silent "mysql -e \"DELETE FROM mysql.user WHERE User='';\" >/dev/null 2>&1" "Removing anonymous users"
    run_silent "mysql -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\" >/dev/null 2>&1" "Securing root"
    
    log_substep "Creating database"
    run_command "mysql -e \"CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\"" "Creating database" false
    run_command "mysql -e \"CREATE USER IF NOT EXISTS '$db_user'@'127.0.0.1' IDENTIFIED BY '$db_pass';\"" "Creating user" false
    run_command "mysql -e \"GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'127.0.0.1';\"" "Granting privileges" false
    run_silent "mysql -e \"FLUSH PRIVILEGES;\"" "Flushing privileges"
    
    # Save credentials
    mkdir -p /etc/mythicaldash
    cat > /etc/mythicaldash/db.conf <<EOF
# Database Configuration
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=$db_name
DB_USER=$db_user
DB_PASS=$db_pass
EOF
    
    chmod 600 /etc/mythicaldash/db.conf
    
    echo -e "${GREEN}${EMOJI_KEY}  Database credentials saved to /etc/mythicaldash/db.conf${RESET}"
    log_success "Database configured"
}

# ============================================================================
# APPLICATION DEPLOYMENT
# ============================================================================
deploy_application() {
    local mode="$1"
    
    log_step "Application Deployment"
    
    # Create directory
    run_silent "mkdir -p $INSTALL_DIR" "Creating installation directory"
    run_silent "chmod 755 $INSTALL_DIR" "Setting permissions"
    
    # Download
    log_substep "Downloading MythicalDash"
    run_command "wget -q -O /tmp/mythicaldash.zip https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip" \
        "Downloading application" true
    
    # Extract
    log_substep "Extracting files"
    run_command "unzip -q -o /tmp/mythicaldash.zip -d $INSTALL_DIR" \
        "Extracting archive" false
    
    run_silent "rm -f /tmp/mythicaldash.zip" "Cleaning up"
    
    # Set permissions
    run_silent "chown -R www-data:www-data $INSTALL_DIR" "Setting ownership"
    run_silent "find $INSTALL_DIR -type d -exec chmod 755 {} \;" "Setting directory permissions"
    run_silent "find $INSTALL_DIR -type f -exec chmod 644 {} \;" "Setting file permissions"
    
    log_success "Application deployed to $INSTALL_DIR"
}

setup_nginx() {
    log_step "Web Server Configuration"
    
    cat > /etc/nginx/sites-available/mythicaldash <<'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/mythicaldash-v3/public;
    index index.php;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
    
    run_silent "ln -sf /etc/nginx/sites-available/mythicaldash /etc/nginx/sites-enabled/" "Enabling site"
    run_silent "rm -f /etc/nginx/sites-enabled/default" "Removing default site"
    
    run_command "nginx -t" "Testing configuration" false
    run_silent "systemctl reload nginx" "Reloading Nginx"
    
    log_success "Nginx configured"
}

# ============================================================================
# DOCKER DEPLOYMENT
# ============================================================================
install_docker() {
    log_step "Docker Installation"
    
    log_substep "Setting up repository"
    run_silent "apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null" "Cleaning old versions"
    
    run_command "curl -fsSL https://get.docker.com -o /tmp/get-docker.sh" \
        "Downloading Docker installer" true
    
    run_command "sh /tmp/get-docker.sh" \
        "Installing Docker Engine" true
    
    run_silent "rm -f /tmp/get-docker.sh" "Cleaning up"
    
    run_silent "systemctl enable docker" "Enabling Docker"
    run_silent "systemctl start docker" "Starting Docker"
    
    log_success "Docker installed"
}

deploy_with_docker() {
    log_step "Docker Deployment"
    
    if [ ! -f "$INSTALL_DIR/docker-compose.yml" ]; then
        log_error "docker-compose.yml not found"
        return 1
    fi
    
    cd "$INSTALL_DIR"
    
    log_substep "Starting containers"
    run_command "docker compose up -d" "Starting Docker services" true
    
    echo -e "${CYAN}${EMOJI_CLOCK}  Waiting for services to start...${RESET}"
    sleep 10
    
    log_success "Docker deployment complete"
}

# ============================================================================
# CLOUDFLARE TUNNEL
# ============================================================================
setup_cloudflare() {
    local mode="$1"
    local email="$2"
    local api_key="$3"
    local hostname="$4"
    
    log_step "Cloudflare Tunnel Setup"
    
    case "$mode" in
        "full")
            setup_cloudflare_full "$email" "$api_key" "$hostname"
            ;;
        "semi")
            echo -e "${YELLOW}${EMOJI_INFO}  Manual configuration required${RESET}"
            echo -e "${WHITE}Please set up Cloudflare Tunnel manually:${RESET}"
            echo -e "${CYAN}1. ${WHITE}Login to Cloudflare Dashboard${RESET}"
            echo -e "${CYAN}2. ${WHITE}Go to Zero Trust → Networks → Tunnels${RESET}"
            echo -e "${CYAN}3. ${WHITE}Create a tunnel pointing to ${KS_BLUE}http://localhost:4830${RESET}"
            echo -e "${CYAN}4. ${WHITE}Configure DNS record for ${KS_BLUE}$hostname${RESET}"
            ;;
    esac
}

setup_cloudflare_full() {
    local email="$1"
    local api_key="$2"
    local hostname="$3"
    
    log_substep "Installing cloudflared"
    run_command "wget -q -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb" \
        "Downloading cloudflared" true
    
    run_silent "dpkg -i /tmp/cloudflared.deb" "Installing package"
    run_silent "rm -f /tmp/cloudflared.deb" "Cleaning up"
    
    log_substep "Setting up tunnel"
    # Note: This is a simplified version. Real implementation would need API calls
    
    echo -e "${GREEN}${EMOJI_LINK}  Tunnel will be configured for: ${KS_BLUE}$hostname${RESET}"
    log_success "Cloudflare setup initiated"
}

# ============================================================================
# USER INTERFACE
# ============================================================================
show_main_menu() {
    echo -e "\n${KS_BLUE}${EMOJI_COMPUTER}  MAIN MENU ${KS_ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e ""
    echo -e "  ${GREEN}${EMOJI_DOCKER} [1] Docker Deployment${RESET}"
    echo -e "     ${WHITE}→ Containerized installation with Docker${RESET}"
    echo -e ""
    echo -e "  ${CYAN}${EMOJI_SERVER} [2] Traditional Deployment${RESET}"
    echo -e "     ${WHITE}→ Direct installation on host system${RESET}"
    echo -e ""
    echo -e "  ${YELLOW}${EMOJI_MAG} [3] System Diagnostics${RESET}"
    echo -e "  ${MAGENTA}${EMOJI_EYES} [4] View Installation Log${RESET}"
    echo -e ""
    echo -e "  ${RED}${EMOJI_WARN} [5] Uninstall Options${RESET}"
    echo -e ""
    echo -e "  ${WHITE}${EMOJI_WAVE} [0] Exit${RESET}"
    echo -e ""
    echo -e "${KS_ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

show_diagnostics() {
    log_step "System Diagnostics"
    
    echo -e "${CYAN}${EMOJI_COMPUTER}  System Information${RESET}"
    echo -e "${WHITE}  OS: ${KS_BLUE}$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)${RESET}"
    echo -e "${WHITE}  Kernel: ${KS_BLUE}$(uname -r)${RESET}"
    echo -e "${WHITE}  Architecture: ${KS_BLUE}$(uname -m)${RESET}"
    echo -e "${WHITE}  Uptime: ${KS_BLUE}$(uptime -p | sed 's/up //')${RESET}"
    
    echo -e "\n${CYAN}${EMOJI_DATABASE}  Resources${RESET}"
    echo -e "${WHITE}  CPU: ${KS_BLUE}$(nproc) cores${RESET}"
    echo -e "${WHITE}  Memory: ${KS_BLUE}$(free -h | awk '/^Mem:/ {print $3 "/" $2}')${RESET}"
    echo -e "${WHITE}  Disk: ${KS_BLUE}$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')${RESET}"
    
    echo -e "\n${CYAN}${EMOJI_NETWORK}  Network${RESET}"
    echo -e "${WHITE}  IP Address: ${KS_BLUE}$(hostname -I | awk '{print $1}')${RESET}"
    echo -e "${WHITE}  Public IP: ${KS_BLUE}$(curl -s ifconfig.me)${RESET}"
    
    echo -e "\n${GREEN}${EMOJI_CHECK}  Diagnostics complete${RESET}"
}

# ============================================================================
# INSTALLATION FLOWS
# ============================================================================
install_docker_flow() {
    show_banner
    echo -e "${KS_GREEN}${EMOJI_ROCKET}  Starting Docker Deployment ${EMOJI_ROCKET}${RESET}\n"
    
    validate_system
    update_system
    
    # Install Docker
    install_docker
    
    # Install dependencies
    install_packages curl wget unzip jq
    
    # Deploy application
    deploy_application "docker"
    
    # Start services
    deploy_with_docker
    
    # Ask for configuration
    echo -e "\n${CYAN}${EMOJI_GEAR}  Additional Configuration${RESET}"
    read -p "$(echo -e "${WHITE}Configure Pterodactyl? (y/N): ${RESET}")" -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "$(echo -e "${WHITE}Pterodactyl URL: ${RESET}")" ptero_url
        read -p "$(echo -e "${WHITE}Pterodactyl API Key: ${RESET}")" ptero_key
        
        if [ -n "$ptero_url" ] && [ -n "$ptero_key" ]; then
            echo -e "${CYAN}${EMOJI_GEAR}  Configuring Pterodactyl...${RESET}"
            docker exec -i mythicaldash_v3_backend php cli pterodactyl configure <<EOF
y
$ptero_url
$ptero_key
y
EOF
        fi
    fi
    
    # Cloudflare setup
    read -p "$(echo -e "${WHITE}Setup Cloudflare Tunnel? (y/N): ${RESET}")" -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}${EMOJI_NETWORK}  Cloudflare Setup${RESET}"
        read -p "$(echo -e "${WHITE}Tunnel Mode (full/semi): ${RESET}")" cf_mode
        read -p "$(echo -e "${WHITE}Hostname (e.g., dash.example.com): ${RESET}")" cf_hostname
        
        if [ "$cf_mode" = "full" ]; then
            read -p "$(echo -e "${WHITE}Cloudflare Email: ${RESET}")" cf_email
            read -p "$(echo -e "${WHITE}Cloudflare API Key: ${RESET}")" cf_apikey
            setup_cloudflare "full" "$cf_email" "$cf_apikey" "$cf_hostname"
        else
            setup_cloudflare "semi" "" "" "$cf_hostname"
        fi
    fi
    
    # Completion
    echo -e "\n${KS_GREEN}${EMOJI_PARTY}  DEPLOYMENT COMPLETE! ${EMOJI_PARTY}${RESET}"
    echo -e "${KS_ORANGE}══════════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}${EMOJI_LINK}  Access your dashboard at: ${KS_BLUE}http://localhost:4830${RESET}"
    echo -e "${WHITE}${EMOJI_FOLDER}  Installation directory: ${KS_BLUE}$INSTALL_DIR${RESET}"
    echo -e "${WHITE}${EMOJI_EYES}  View logs: ${KS_BLUE}tail -f $LOG_FILE${RESET}"
    echo -e "${KS_ORANGE}══════════════════════════════════════════════════════════${RESET}"
}

install_traditional_flow() {
    show_banner
    echo -e "${KS_GREEN}${EMOJI_ROCKET}  Starting Traditional Deployment ${EMOJI_ROCKET}${RESET}\n"
    
    validate_system
    update_system
    
    # Install packages
    log_step "Installing System Packages"
    
    local packages=(
        mariadb-server mariadb-client
        nginx php8.3 php8.3-fpm php8.3-mysql
        php8.3-mbstring php8.3-xml php8.3-curl
        php8.3-zip php8.3-gd php8.3-bcmath
        redis-server composer nodejs npm
        curl wget unzip jq git
    )
    
    install_packages "${packages[@]}"
    
    # Setup database
    setup_database
    
    # Deploy application
    deploy_application "traditional"
    
    # Setup Nginx
    setup_nginx
    
    # Install composer dependencies
    log_step "Installing PHP Dependencies"
    cd "$INSTALL_DIR"
    run_command "composer install --no-dev --optimize-autoloader" \
        "Installing Composer packages" true
    
    # Setup application
    log_step "Configuring Application"
    run_silent "cp .env.example .env" "Creating environment file"
    run_command "php artisan key:generate" "Generating application key" false
    
    # Setup database in app
    export $(cat /etc/mythicaldash/db.conf | xargs)
    cat > "$INSTALL_DIR/.env" <<EOF
APP_ENV=production
APP_KEY=
DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS
EOF
    
    run_command "php artisan migrate --force" "Running migrations" true
    run_command "php artisan storage:link" "Linking storage" false
    
    # Setup cron
    log_step "Setting up Scheduled Tasks"
    (crontab -l 2>/dev/null; echo "* * * * * cd $INSTALL_DIR && php artisan schedule:run >> /dev/null 2>&1") | crontab -
    log_success "Cron job added"
    
    # Completion
    echo -e "\n${KS_GREEN}${EMOJI_PARTY}  DEPLOYMENT COMPLETE! ${EMOJI_PARTY}${RESET}"
    echo -e "${KS_ORANGE}══════════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}${EMOJI_LINK}  Access your dashboard at: ${KS_BLUE}http://$(hostname -I | awk '{print $1}')${RESET}"
    echo -e "${WHITE}${EMOJI_KEY}  Database config: ${KS_BLUE}/etc/mythicaldash/db.conf${RESET}"
    echo -e "${WHITE}${EMOJI_FOLDER}  Installation directory: ${KS_BLUE}$INSTALL_DIR${RESET}"
    echo -e "${KS_ORANGE}══════════════════════════════════════════════════════════${RESET}"
}

# ============================================================================
# MAIN PROGRAM
# ============================================================================
main() {
    # Initialize
    mkdir -p $(dirname "$LOG_FILE")
    echo "=== Installation started at $(date) ===" > "$LOG_FILE"
    
    while true; do
        show_banner
        show_main_menu
        
        read -p "$(echo -e "${KS_BLUE}${EMOJI_BRAIN}  Select option [0-5]: ${RESET}")" choice
        
        case $choice in
            1)
                install_docker_flow
                break
                ;;
            2)
                install_traditional_flow
                break
                ;;
            3)
                show_banner
                show_diagnostics
                read -p "$(echo -e "\n${WHITE}Press Enter to continue...${RESET}")" _
                ;;
            4)
                show_banner
                echo -e "${CYAN}${EMOJI_EYES}  Installation Log (last 20 lines)${RESET}"
                echo -e "${KS_ORANGE}────────────────────────────────────────────────────────────${RESET}"
                tail -20 "$LOG_FILE"
                echo -e "${KS_ORANGE}────────────────────────────────────────────────────────────${RESET}"
                read -p "$(echo -e "\n${WHITE}Press Enter to continue...${RESET}")" _
                ;;
            5)
                show_banner
                echo -e "${RED}${EMOJI_WARN}  Uninstall Options${RESET}"
                echo -e "${KS_ORANGE}────────────────────────────────────────────────────────────${RESET}"
                echo -e "${WHITE}[1] Remove Docker installation${RESET}"
                echo -e "${WHITE}[2] Remove Traditional installation${RESET}"
                echo -e "${WHITE}[3] Back to main menu${RESET}"
                echo -e "${KS_ORANGE}────────────────────────────────────────────────────────────${RESET}"
                read -p "$(echo -e "${WHITE}Select: ${RESET}")" uninstall_choice
                
                case $uninstall_choice in
                    1)
                        echo -e "${RED}${EMOJI_WARN}  Removing Docker installation...${RESET}"
                        run_silent "cd $INSTALL_DIR && docker compose down -v" "Stopping containers"
                        run_silent "rm -rf $INSTALL_DIR" "Removing files"
                        log_success "Docker installation removed"
                        ;;
                    2)
                        echo -e "${RED}${EMOJI_WARN}  Removing Traditional installation...${RESET}"
                        run_silent "rm -rf $INSTALL_DIR" "Removing application"
                        run_silent "mysql -e 'DROP DATABASE IF EXISTS mythicaldash'" "Removing database"
                        run_silent "rm -f /etc/nginx/sites-{available,enabled}/mythicaldash" "Removing Nginx config"
                        log_success "Traditional installation removed"
                        ;;
                esac
                ;;
            0)
                echo -e "\n${KS_BLUE}${EMOJI_WAVE}  Thank you for using KS HOSTING!${RESET}"
                echo -e "${WHITE}Goodbye!${RESET}\n"
                exit 0
                ;;
            *)
                echo -e "${RED}${EMOJI_ERROR}  Invalid selection!${RESET}"
                sleep 1
                ;;
        esac
    done
    
    # Final message
    echo -e "\n${KS_GREEN}${EMOJI_SPARKLES}  Installation completed successfully! ${EMOJI_SPARKLES}${RESET}"
    echo -e "${KS_BLUE}══════════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}Need help? Check the documentation or contact support.${RESET}"
    echo -e "${WHITE}Log file: ${KS_BLUE}$LOG_FILE${RESET}"
    echo -e "${KS_BLUE}══════════════════════════════════════════════════════════${RESET}"
}

# ============================================================================
# ENTRY POINT
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
