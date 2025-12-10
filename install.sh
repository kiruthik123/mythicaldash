#!/bin/bash
# ============================================================================
# MythicalDash Deployment System
# Version: 3.2.0 - KS HOSTING BY KSGAMING
# ============================================================================

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly SCRIPT_NAME="mythicaldash-deploy"
readonly SCRIPT_VERSION="3.2.0"
readonly COMPANY_NAME="KS HOSTING BY KSGAMING"
readonly INSTALL_DIR="/var/www/mythicaldash-v3"
readonly LOG_FILE="/var/log/mythicaldash-install.log"

# ============================================================================
# COLOR & EMOJI DEFINITIONS
# ============================================================================
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'

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
readonly EMOJI_FILE="📄"
readonly EMOJI_TERMINAL="💻"
readonly EMOJI_SPEED="⚡"
readonly EMOJI_DIAMOND="💎"

# ============================================================================
# ANIMATION & LOADING FUNCTIONS
# ============================================================================
show_spinner() {
    local pid=$1
    local message="$2"
    local delay=0.1
    local spinstr='|/-\\'
    
    echo -ne "${KS_BLUE}${EMOJI_GEAR}  ${message}... ${RESET}"
    
    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 3); do
            echo -ne "${KS_ORANGE}${spinstr:$i:1}${RESET}"
            sleep $delay
            echo -ne "\b"
        done
    done
    
    echo -ne "\b\b\b\b"
    echo -e "${GREEN}${EMOJI_CHECK} Done!${RESET}"
}

show_progress_bar() {
    local duration=$1
    local message="$2"
    local width=50
    
    echo -ne "${CYAN}${EMOJI_SPEED}  ${message} ${RESET}"
    echo -ne "["
    
    for ((i=0; i<width; i++)); do
        echo -ne "${KS_ORANGE}=>${RESET}"
        sleep $(echo "scale=3; $duration/$width" | bc)
    done
    
    echo -e "] ${GREEN}${EMOJI_CHECK}${RESET}"
}

show_command_execution() {
    local cmd="$1"
    local desc="$2"
    
    echo -e "\n${CYAN}${EMOJI_TERMINAL}  EXECUTING: ${WHITE}${desc}${RESET}"
    echo -e "${DIM}${WHITE}└─ Command: ${KS_ORANGE}${cmd}${RESET}"
    
    # Show a simple animation while command runs
    local frames=("⡀" "⡄" "⡆" "⡇" "⣇" "⣧" "⣷" "⣿")
    local frame=0
    
    # Start command in background
    eval "$cmd" > /dev/null 2>&1 &
    local pid=$!
    
    # Show animation
    while kill -0 $pid 2>/dev/null; do
        echo -ne "${KS_BLUE}${frames[frame]}${RESET}"
        sleep 0.1
        echo -ne "\b"
        frame=$(( (frame + 1) % 8 ))
    done
    
    wait $pid
    local exit_code=$?
    
    echo -ne "\b"
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}${EMOJI_CHECK} Success${RESET}"
    else
        echo -e "${RED}${EMOJI_ERROR} Failed (code: $exit_code)${RESET}"
    fi
    
    return $exit_code
}

show_whats_running() {
    local message="$1"
    local cmd="$2"
    
    echo -e "\n${BLUE}${EMOJI_TERMINAL}  CURRENT TASK: ${WHITE}${message}${RESET}"
    echo -e "${DIM}${WHITE}└─ Command: ${YELLOW}${cmd}${RESET}"
    
    # Create a simple progress indicator
    local dots=""
    echo -ne "${KS_BLUE}${EMOJI_SPEED}  Running"
    
    # Run command in background
    eval "$cmd" > /dev/null 2>&1 &
    local pid=$!
    
    # Show dots while command runs
    while kill -0 $pid 2>/dev/null; do
        echo -ne "${KS_ORANGE}.${RESET}"
        sleep 0.5
        echo -ne "\b"
    done
    
    wait $pid
    local exit_code=$?
    
    echo -ne "\b"
    if [ $exit_code -eq 0 ]; then
        echo -e " ${GREEN}${EMOJI_CHECK} Completed${RESET}"
    else
        echo -e " ${RED}${EMOJI_ERROR} Failed${RESET}"
    fi
    
    return $exit_code
}

run_and_show() {
    local cmd="$1"
    local description="$2"
    
    echo -e "\n${CYAN}${EMOJI_GEAR}  ${description}${RESET}"
    echo -e "${DIM}${WHITE}└─ ${cmd}${RESET}"
    
    # Show the full command
    echo -e "${YELLOW}${BOLD}Full command:${RESET} ${WHITE}${cmd}${RESET}"
    
    # Execute with output
    if eval "$cmd" 2>&1; then
        echo -e "${GREEN}${EMOJI_CHECK}  ${description} completed successfully${RESET}"
        return 0
    else
        echo -e "${RED}${EMOJI_ERROR}  ${description} failed${RESET}"
        return 1
    fi
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
    echo -e "\n${KS_PURPLE}${EMOJI_FLAG}  STEP: ${BOLD}$1${RESET}"
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════${RESET}"
}

log_substep() {
    echo -e "${BLUE}${EMOJI_BRAIN}  $1${RESET}"
}

# ============================================================================
# BANNER & DISPLAY FUNCTIONS
# ============================================================================
show_banner() {
    clear
    echo -e "${KS_BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                          ║"
    echo "║  ██╗  ██╗███████╗    ██╗  ██╗ ██████╗ ███████╗ █████╗ ███╗   ███╗       ║"
    echo "║  ██║ ██╔╝██╔════╝    ██║  ██║██╔═══██╗██╔════╝██╔══██╗████╗ ████║       ║"
    echo "║  █████╔╝ ███████╗    ███████║██║   ██║███████╗███████║██╔████╔██║       ║"
    echo "║  ██╔═██╗ ╚════██║    ██╔══██║██║   ██║╚════██║██╔══██║██║╚██╔╝██║       ║"
    echo "║  ██║  ██╗███████║    ██║  ██║╚██████╔╝███████║██║  ██║██║ ╚═╝ ██║       ║"
    echo "║  ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝       ║"
    echo "║                                                                          ║"
    echo "║  ${KS_GREEN}${EMOJI_ROCKET}  KS HOSTING BY KSGAMING - DEPLOYMENT SYSTEM ${KS_BLUE}                 ║"
    echo "║  ${WHITE}Version ${SCRIPT_VERSION} • Professional • Secure • Fast ${KS_BLUE}                       ║"
    echo "║                                                                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${WHITE}${EMOJI_COMPUTER}  System: $(lsb_release -ds 2>/dev/null || echo "Linux System")${RESET}"
    echo -e "${WHITE}${EMOJI_CLOCK}  Started: $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════════════${RESET}\n"
}

# ============================================================================
# SYSTEM VALIDATION
# ============================================================================
validate_system() {
    log_step "System Validation"
    
    echo -e "${BLUE}${EMOJI_MAG}  Checking system requirements...${RESET}"
    
    # Check OS
    if [ ! -f /etc/os-release ]; then
        log_error "Cannot detect operating system"
        exit 1
    fi
    
    source /etc/os-release
    
    case "$ID" in
        ubuntu|debian)
            log_success "Supported OS: $PRETTY_NAME"
            ;;
        *)
            log_error "Unsupported OS: $PRETTY_NAME"
            exit 1
            ;;
    esac
    
    # Check root
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root: sudo bash $0"
        exit 1
    fi
    
    # Check internet
    if ! ping -c 1 google.com &> /dev/null; then
        log_warning "Internet connection check failed"
    else
        log_success "Internet connection verified"
    fi
    
    echo -e "${GREEN}${EMOJI_SHIELD}  System validation passed${RESET}"
}

# ============================================================================
# PACKAGE MANAGEMENT
# ============================================================================
update_system() {
    log_step "System Update"
    
    echo -e "${CYAN}${EMOJI_DOWNLOAD}  Updating package lists...${RESET}"
    
    if run_and_show "apt-get update -qq" "Updating package database"; then
        log_success "Package lists updated"
    else
        log_error "Failed to update package lists"
        return 1
    fi
    
    echo -e "${CYAN}${EMOJI_UPLOAD}  Upgrading system packages...${RESET}"
    
    if run_and_show "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq" "Upgrading system"; then
        log_success "System upgraded"
    else
        log_warning "System upgrade completed with warnings"
    fi
    
    return 0
}

install_packages() {
    local packages=("$@")
    local install_list=()
    
    echo -e "${BLUE}${EMOJI_HAMMER}  Checking packages...${RESET}"
    
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "${GREEN}${EMOJI_CHECK}  $pkg already installed${RESET}"
        else
            install_list+=("$pkg")
        fi
    done
    
    if [ ${#install_list[@]} -gt 0 ]; then
        echo -e "${CYAN}${EMOJI_DOWNLOAD}  Installing: ${install_list[*]}${RESET}"
        
        local install_cmd="DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ${install_list[@]}"
        
        if show_whats_running "Installing system packages" "$install_cmd"; then
            log_success "Packages installed successfully"
        else
            log_error "Failed to install packages"
            return 1
        fi
    else
        echo -e "${GREEN}${EMOJI_CHECK}  All required packages are already installed${RESET}"
    fi
    
    return 0
}

# ============================================================================
# DATABASE SETUP
# ============================================================================
setup_database() {
    log_step "Database Configuration"
    
    local db_name="mythicaldash"
    local db_user="mythical_user"
    local db_pass=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 16)
    
    echo -e "${BLUE}${EMOJI_DATABASE}  Setting up MariaDB database...${RESET}"
    
    # Secure MariaDB
    echo -e "${CYAN}${EMOJI_SHIELD}  Securing MariaDB installation...${RESET}"
    
    local secure_sql="
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;
    "
    
    if show_whats_running "Securing MariaDB" "mysql -e \"$secure_sql\""; then
        echo -e "${GREEN}${EMOJI_CHECK}  MariaDB secured${RESET}"
    fi
    
    # Create database
    echo -e "${CYAN}${EMOJI_FILE}  Creating database...${RESET}"
    
    if show_whats_running "Creating database" "mysql -e \"CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""; then
        echo -e "${GREEN}${EMOJI_CHECK}  Database created: $db_name${RESET}"
    fi
    
    # Create user
    echo -e "${CYAN}${EMOJI_KEY}  Creating database user...${RESET}"
    
    if show_whats_running "Creating user" "mysql -e \"CREATE USER IF NOT EXISTS '$db_user'@'127.0.0.1' IDENTIFIED BY '$db_pass';\""; then
        echo -e "${GREEN}${EMOJI_CHECK}  User created: $db_user${RESET}"
    fi
    
    # Grant privileges
    echo -e "${CYAN}${EMOJI_UNLOCK}  Granting privileges...${RESET}"
    
    if show_whats_running "Granting privileges" "mysql -e \"GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'127.0.0.1';\""; then
        echo -e "${GREEN}${EMOJI_CHECK}  Privileges granted${RESET}"
    fi
    
    # Flush privileges
    show_whats_running "Finalizing" "mysql -e \"FLUSH PRIVILEGES;\""
    
    # Save credentials
    mkdir -p /etc/mythicaldash
    cat > /etc/mythicaldash/db.conf <<EOF
# Database Configuration - KS HOSTING
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=$db_name
DB_USER=$db_user
DB_PASS=$db_pass
EOF
    
    chmod 600 /etc/mythicaldash/db.conf
    
    echo -e "${GREEN}${EMOJI_KEY}  Database credentials saved to: /etc/mythicaldash/db.conf${RESET}"
    log_success "Database configuration completed"
}

# ============================================================================
# APPLICATION DEPLOYMENT
# ============================================================================
download_application() {
    log_step "Downloading Application"
    
    local download_url="https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip"
    local temp_file="/tmp/mythicaldash-$(date +%s).zip"
    
    echo -e "${BLUE}${EMOJI_DOWNLOAD}  Downloading MythicalDash...${RESET}"
    echo -e "${DIM}${WHITE}Source: ${download_url}${RESET}"
    
    if show_whats_running "Downloading application" "wget -q -O $temp_file $download_url"; then
        local file_size=$(stat -c%s "$temp_file" 2>/dev/null || echo "0")
        if [ "$file_size" -gt 1000000 ]; then
            echo -e "${GREEN}${EMOJI_CHECK}  Download complete ($((file_size/1024/1024)) MB)${RESET}"
        else
            log_warning "Downloaded file seems small ($file_size bytes)"
        fi
    else
        log_error "Failed to download application"
        return 1
    fi
    
    # Extract application
    echo -e "${BLUE}${EMOJI_FOLDER}  Extracting files...${RESET}"
    
    if show_whats_running "Extracting files" "unzip -q -o $temp_file -d $INSTALL_DIR"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Files extracted to $INSTALL_DIR${RESET}"
    else
        log_error "Failed to extract files"
        return 1
    fi
    
    # Cleanup
    rm -f "$temp_file"
    
    # Set permissions
    echo -e "${BLUE}${EMOJI_LOCK}  Setting permissions...${RESET}"
    
    show_whats_running "Setting ownership" "chown -R www-data:www-data $INSTALL_DIR"
    show_whats_running "Setting directory permissions" "find $INSTALL_DIR -type d -exec chmod 755 {} \\;"
    show_whats_running "Setting file permissions" "find $INSTALL_DIR -type f -exec chmod 644 {} \\;"
    
    log_success "Application downloaded and prepared"
}

# ============================================================================
# DOCKER DEPLOYMENT
# ============================================================================
install_docker_engine() {
    log_step "Docker Engine Installation"
    
    echo -e "${BLUE}${EMOJI_DOCKER}  Installing Docker...${RESET}"
    
    # Remove old versions
    echo -e "${CYAN}${EMOJI_WRENCH}  Removing old Docker versions...${RESET}"
    show_whats_running "Cleaning old Docker" "apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null"
    
    # Install prerequisites
    echo -e "${CYAN}${EMOJI_HAMMER}  Installing prerequisites...${RESET}"
    install_packages apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker repository
    echo -e "${CYAN}${EMOJI_FOLDER}  Adding Docker repository...${RESET}"
    
    if show_whats_running "Adding GPG key" "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"; then
        echo -e "${GREEN}${EMOJI_CHECK}  GPG key added${RESET}"
    fi
    
    local arch=$(dpkg --print-architecture)
    local repo_cmd="echo \"deb [arch=$arch signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null"
    
    if show_whats_running "Adding repository" "$repo_cmd"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Repository added${RESET}"
    fi
    
    # Update and install Docker
    echo -e "${CYAN}${EMOJI_DOWNLOAD}  Installing Docker Engine...${RESET}"
    
    show_whats_running "Updating packages" "apt-get update -qq"
    
    local docker_packages="docker-ce docker-ce-cli containerd.io docker-compose-plugin"
    if show_whats_running "Installing Docker packages" "apt-get install -y -qq $docker_packages"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Docker packages installed${RESET}"
    fi
    
    # Start and enable Docker
    echo -e "${CYAN}${EMOJI_ROCKET}  Starting Docker service...${RESET}"
    
    if show_whats_running "Enabling Docker" "systemctl enable docker"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Docker enabled${RESET}"
    fi
    
    if show_whats_running "Starting Docker" "systemctl start docker"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Docker started${RESET}"
    fi
    
    # Add user to docker group
    echo -e "${CYAN}${EMOJI_COMPUTER}  Configuring user permissions...${RESET}"
    
    if show_whats_running "Adding user to docker group" "usermod -aG docker $SUDO_USER"; then
        echo -e "${GREEN}${EMOJI_CHECK}  User added to docker group${RESET}"
        echo -e "${YELLOW}${EMOJI_INFO}  Note: You may need to log out and back in for group changes to take effect${RESET}"
    fi
    
    # Verify installation
    echo -e "${CYAN}${EMOJI_MAG}  Verifying installation...${RESET}"
    
    if show_whats_running "Checking Docker version" "docker --version"; then
        log_success "Docker Engine installed successfully"
    else
        log_error "Docker installation verification failed"
        return 1
    fi
}

# ============================================================================
# USER INTERFACE
# ============================================================================
show_main_menu() {
    echo -e "\n${KS_BLUE}${EMOJI_DIAMOND}  KS HOSTING DEPLOYMENT MENU ${KS_ORANGE}═══════════════════════════════════════${RESET}"
    echo -e ""
    echo -e "  ${GREEN}${EMOJI_DOCKER} [1] Docker Deployment${RESET}"
    echo -e "     ${DIM}Containerized installation with Docker Compose${RESET}"
    echo -e ""
    echo -e "  ${CYAN}${EMOJI_SERVER} [2] Traditional Deployment${RESET}"
    echo -e "     ${DIM}Direct installation on host system${RESET}"
    echo -e ""
    echo -e "  ${YELLOW}${EMOJI_MAG} [3] System Diagnostics${RESET}"
    echo -e "  ${MAGENTA}${EMOJI_EYES} [4] View Installation Log${RESET}"
    echo -e "  ${RED}${EMOJI_WARN} [5] Uninstall Options${RESET}"
    echo -e ""
    echo -e "  ${WHITE}${EMOJI_WAVE} [0] Exit${RESET}"
    echo -e ""
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════════════${RESET}"
}

# ============================================================================
# INSTALLATION FLOWS
# ============================================================================
install_docker_flow() {
    show_banner
    echo -e "${KS_GREEN}${EMOJI_ROCKET}${BOLD}  DOCKER DEPLOYMENT ${EMOJI_ROCKET}${RESET}\n"
    
    # Step 1: Validate system
    validate_system
    
    # Step 2: Update system
    update_system
    
    # Step 3: Install Docker
    install_docker_engine
    
    # Step 4: Install additional tools
    log_step "Installing Tools"
    install_packages curl wget unzip jq git
    
    # Step 5: Create directory
    echo -e "${BLUE}${EMOJI_FOLDER}  Creating installation directory...${RESET}"
    show_whats_running "Creating directory" "mkdir -p $INSTALL_DIR && chmod 755 $INSTALL_DIR"
    
    # Step 6: Download application
    download_application
    
    # Step 7: Start Docker containers
    log_step "Starting Services"
    
    cd "$INSTALL_DIR"
    
    echo -e "${BLUE}${EMOJI_ROCKET}  Starting Docker containers...${RESET}"
    if show_whats_running "Starting containers" "docker compose up -d"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Containers started successfully${RESET}"
    else
        log_error "Failed to start containers"
        return 1
    fi
    
    # Step 8: Wait for services
    echo -e "${CYAN}${EMOJI_CLOCK}  Waiting for services to initialize...${RESET}"
    for i in {1..5}; do
        echo -ne "${KS_BLUE}.${RESET}"
        sleep 2
    done
    echo -e " ${GREEN}${EMOJI_CHECK}${RESET}"
    
    # Step 9: Ask for additional configuration
    echo -e "\n${KS_PURPLE}${EMOJI_GEAR}  Additional Configuration ${KS_ORANGE}══════════════════════════════════${RESET}"
    
    # Pterodactyl configuration
    read -p "$(echo -e "${WHITE}${EMOJI_SERVER}  Configure Pterodactyl? (y/N): ${RESET}")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "$(echo -e "${WHITE}  Pterodactyl Panel URL (e.g., https://panel.example.com): ${RESET}")" ptero_url
        read -p "$(echo -e "${WHITE}  Pterodactyl API Key: ${RESET}")" ptero_key
        
        if [ -n "$ptero_url" ] && [ -n "$ptero_key" ]; then
            echo -e "${CYAN}${EMOJI_GEAR}  Configuring Pterodactyl...${RESET}"
            local config_cmd="docker exec -i mythicaldash_v3_backend php cli pterodactyl configure <<EOF
y
$ptero_url
$ptero_key
y
EOF"
            if show_whats_running "Configuring Pterodactyl" "$config_cmd"; then
                echo -e "${GREEN}${EMOJI_CHECK}  Pterodactyl configured${RESET}"
            fi
        fi
    fi
    
    # Cloudflare configuration
    read -p "$(echo -e "${WHITE}${EMOJI_NETWORK}  Setup Cloudflare Tunnel? (y/N): ${RESET}")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}${EMOJI_NETWORK}  Cloudflare Tunnel Setup${RESET}"
        read -p "$(echo -e "${WHITE}  Tunnel Mode (full/semi) [semi]: ${RESET}")" cf_mode
        cf_mode=${cf_mode:-semi}
        
        read -p "$(echo -e "${WHITE}  Hostname (e.g., dash.example.com): ${RESET}")" cf_hostname
        
        if [ "$cf_mode" = "full" ]; then
            read -p "$(echo -e "${WHITE}  Cloudflare Email: ${RESET}")" cf_email
            read -p "$(echo -e "${WHITE}  Cloudflare API Key: ${RESET}")" cf_apikey
            # Simplified Cloudflare setup
            echo -e "${YELLOW}${EMOJI_INFO}  Full Cloudflare setup would be implemented here${RESET}"
        else
            echo -e "${YELLOW}${EMOJI_INFO}  Manual Cloudflare configuration required${RESET}"
            echo -e "${DIM}  Please configure tunnel manually in Cloudflare dashboard${RESET}"
        fi
    fi
    
    # Completion
    show_completion_message "docker"
}

install_traditional_flow() {
    show_banner
    echo -e "${KS_GREEN}${EMOJI_ROCKET}${BOLD}  TRADITIONAL DEPLOYMENT ${EMOJI_ROCKET}${RESET}\n"
    
    # Step 1: Validate system
    validate_system
    
    # Step 2: Update system
    update_system
    
    # Step 3: Install packages
    log_step "Installing System Packages"
    
    local packages=(
        mariadb-server mariadb-client
        nginx php8.3 php8.3-fpm php8.3-mysql
        php8.3-mbstring php8.3-xml php8.3-curl
        php8.3-zip php8.3-gd php8.3-bcmath
        php8.3-redis redis-server 
        composer nodejs npm
        curl wget unzip jq git
    )
    
    install_packages "${packages[@]}"
    
    # Step 4: Setup database
    setup_database
    
    # Step 5: Create directory
    echo -e "${BLUE}${EMOJI_FOLDER}  Creating installation directory...${RESET}"
    show_whats_running "Creating directory" "mkdir -p $INSTALL_DIR && chmod 755 $INSTALL_DIR"
    
    # Step 6: Download application
    download_application
    
    # Step 7: Setup Nginx
    log_step "Web Server Configuration"
    
    echo -e "${BLUE}${EMOJI_NETWORK}  Configuring Nginx...${RESET}"
    
    cat > /etc/nginx/sites-available/mythicaldash <<EOF
server {
    listen 80;
    server_name _;
    root $INSTALL_DIR/public;
    index index.php index.html index.htm;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
    
    show_whats_running "Creating Nginx config" "ln -sf /etc/nginx/sites-available/mythicaldash /etc/nginx/sites-enabled/"
    show_whats_running "Removing default site" "rm -f /etc/nginx/sites-enabled/default"
    
    if show_whats_running "Testing Nginx config" "nginx -t"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Nginx configuration valid${RESET}"
    fi
    
    if show_whats_running "Reloading Nginx" "systemctl reload nginx"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Nginx reloaded${RESET}"
    fi
    
    # Step 8: Install PHP dependencies
    log_step "PHP Dependencies"
    
    cd "$INSTALL_DIR"
    
    echo -e "${BLUE}${EMOJI_HAMMER}  Installing Composer dependencies...${RESET}"
    if show_whats_running "Installing dependencies" "composer install --no-dev --optimize-autoloader"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Dependencies installed${RESET}"
    fi
    
    # Step 9: Setup application
    log_step "Application Configuration"
    
    echo -e "${BLUE}${EMOJI_GEAR}  Configuring application...${RESET}"
    
    # Setup environment
    if [ -f ".env.example" ]; then
        show_whats_running "Creating environment file" "cp .env.example .env"
    fi
    
    # Generate key
    if show_whats_running "Generating application key" "php artisan key:generate"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Application key generated${RESET}"
    fi
    
    # Setup database in .env
    source /etc/mythicaldash/db.conf
    cat > "$INSTALL_DIR/.env" <<EOF
APP_ENV=production
APP_DEBUG=false
APP_URL=http://$(hostname -I | awk '{print $1}')
APP_KEY=

DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS
EOF
    
    # Run migrations
    echo -e "${BLUE}${EMOJI_DATABASE}  Setting up database...${RESET}"
    if show_whats_running "Running migrations" "php artisan migrate --force"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Database migrations completed${RESET}"
    fi
    
    # Link storage
    show_whats_running "Linking storage" "php artisan storage:link"
    
    # Setup cron
    log_step "Scheduled Tasks"
    
    echo -e "${BLUE}${EMOJI_CLOCK}  Setting up cron job...${RESET}"
    local cron_cmd="(crontab -l 2>/dev/null; echo \"* * * * * cd $INSTALL_DIR && php artisan schedule:run >> /dev/null 2>&1\") | crontab -"
    if show_whats_running "Adding cron job" "$cron_cmd"; then
        echo -e "${GREEN}${EMOJI_CHECK}  Cron job configured${RESET}"
    fi
    
    # Completion
    show_completion_message "traditional"
}

show_completion_message() {
    local mode="$1"
    
    echo -e "\n${KS_GREEN}${EMOJI_PARTY}${BOLD}  DEPLOYMENT COMPLETE! ${EMOJI_PARTY}${RESET}"
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════════════${RESET}"
    
    if [ "$mode" = "docker" ]; then
        echo -e "${WHITE}${EMOJI_LINK}  Dashboard URL: ${KS_BLUE}http://localhost:4830${RESET}"
        echo -e "${WHITE}${EMOJI_DOCKER}  Container Status: ${KS_BLUE}docker ps${RESET}"
        echo -e "${WHITE}${EMOJI_EYES}  View Logs: ${KS_BLUE}docker logs mythicaldash_v3_backend${RESET}"
    else
        echo -e "${WHITE}${EMOJI_LINK}  Dashboard URL: ${KS_BLUE}http://$(hostname -I | awk '{print $1}')${RESET}"
        echo -e "${WHITE}${EMOJI_KEY}  Database Config: ${KS_BLUE}/etc/mythicaldash/db.conf${RESET}"
        echo -e "${WHITE}${EMOJI_EYES}  Nginx Config: ${KS_BLUE}/etc/nginx/sites-available/mythicaldash${RESET}"
    fi
    
    echo -e ""
    echo -e "${WHITE}${EMOJI_FOLDER}  Installation Directory: ${KS_BLUE}$INSTALL_DIR${RESET}"
    echo -e "${WHITE}${EMOJI_FILE}  Installation Log: ${KS_BLUE}$LOG_FILE${RESET}"
    echo -e ""
    echo -e "${YELLOW}${EMOJI_BELL}  Next Steps:${RESET}"
    echo -e "${DIM}  1. Access your dashboard at the URL above${RESET}"
    echo -e "${DIM}  2. Configure your administrator account${RESET}"
    echo -e "${DIM}  3. Set up SSL/TLS certificates for production${RESET}"
    echo -e "${DIM}  4. Configure backups and monitoring${RESET}"
    echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${KS_GREEN}${EMOJI_SPARKLES}  Thank you for choosing KS HOSTING BY KSGAMING! ${EMOJI_SPARKLES}${RESET}\n"
}

# ============================================================================
# MAIN PROGRAM
# ============================================================================
main() {
    # Initialize logging
    mkdir -p $(dirname "$LOG_FILE")
    echo "=== KS HOSTING Deployment started at $(date) ===" > "$LOG_FILE"
    echo "=== Script Version: $SCRIPT_VERSION ===" >> "$LOG_FILE"
    
    # Create config directory
    mkdir -p /etc/mythicaldash
    
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
                echo -e "${CYAN}${EMOJI_MAG}  System Diagnostics${RESET}"
                echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════${RESET}"
                echo -e "${WHITE}OS: $(lsb_release -ds 2>/dev/null || echo "Unknown")${RESET}"
                echo -e "${WHITE}Kernel: $(uname -r)${RESET}"
                echo -e "${WHITE}CPU: $(nproc) cores${RESET}"
                echo -e "${WHITE}Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')${RESET}"
                echo -e "${WHITE}Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')${RESET}"
                echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════${RESET}"
                read -p "$(echo -e "${WHITE}Press Enter to continue...${RESET}")" _
                ;;
            4)
                show_banner
                echo -e "${CYAN}${EMOJI_EYES}  Installation Log${RESET}"
                echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════${RESET}"
                if [ -f "$LOG_FILE" ]; then
                    tail -30 "$LOG_FILE"
                else
                    echo -e "${YELLOW}No log file found${RESET}"
                fi
                echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════${RESET}"
                read -p "$(echo -e "${WHITE}Press Enter to continue...${RESET}")" _
                ;;
            5)
                show_banner
                echo -e "${RED}${EMOJI_WARN}  Uninstall Options${RESET}"
                echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════${RESET}"
                echo -e "${WHITE}[1] Remove Docker installation${RESET}"
                echo -e "${WHITE}[2] Remove Traditional installation${RESET}"
                echo -e "${WHITE}[3] Back to main menu${RESET}"
                echo -e "${KS_ORANGE}════════════════════════════════════════════════════════════════${RESET}"
                read -p "$(echo -e "${WHITE}Select: ${RESET}")" uninstall_choice
                
                case $uninstall_choice in
                    1)
                        echo -e "${RED}${EMOJI_WARN}  Removing Docker installation...${RESET}"
                        if [ -d "$INSTALL_DIR" ]; then
                            cd "$INSTALL_DIR" && show_whats_running "Stopping containers" "docker compose down -v"
                            show_whats_running "Removing files" "rm -rf $INSTALL_DIR"
                            echo -e "${GREEN}${EMOJI_CHECK}  Docker installation removed${RESET}"
                        else
                            echo -e "${YELLOW}${EMOJI_INFO}  Installation not found${RESET}"
                        fi
                        ;;
                    2)
                        echo -e "${RED}${EMOJI_WARN}  Removing Traditional installation...${RESET}"
                        show_whats_running "Removing application" "rm -rf $INSTALL_DIR"
                        show_whats_running "Removing database" "mysql -e 'DROP DATABASE IF EXISTS mythicaldash'"
                        show_whats_running "Removing Nginx config" "rm -f /etc/nginx/sites-{available,enabled}/mythicaldash"
                        echo -e "${GREEN}${EMOJI_CHECK}  Traditional installation removed${RESET}"
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
}

# ============================================================================
# ENTRY POINT
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
