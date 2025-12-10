#!/bin/bash
# ============================================================================
# MythicalDash Deployment System
# Version: 4.0.0 - KS HOSTING BY KSGAMING
# ============================================================================

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly SCRIPT_NAME="mythicaldash-deploy"
readonly SCRIPT_VERSION="4.0.0"
readonly COMPANY_NAME="KS HOSTING BY KSGAMING"
readonly INSTALL_DIR="/var/www/mythicaldash-v3"
readonly LOG_FILE="/var/log/mythicaldash-install.log"

# ============================================================================
# COLOR & EMOJI DEFINITIONS
# ============================================================================
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'

# Modern Gradient Colors
readonly GRADIENT_BLUE='\033[38;5;39m'
readonly GRADIENT_CYAN='\033[38;5;51m'
readonly GRADIENT_PURPLE='\033[38;5;93m'
readonly GRADIENT_PINK='\033[38;5;200m'

# Status Colors
readonly SUCCESS_COLOR='\033[38;5;46m'    # Bright Green
readonly ERROR_COLOR='\033[38;5;196m'     # Bright Red
readonly WARNING_COLOR='\033[38;5;214m'   # Orange
readonly INFO_COLOR='\033[38;5;75m'       # Sky Blue

# Background Colors
readonly BG_DARK='\033[48;5;235m'
readonly BG_LIGHT='\033[48;5;252m'

# Emojis - Modern Set
readonly EMOJI_CHECK="✅"
readonly EMOJI_CROSS="❌"
readonly EMOJI_WARN="⚠️"
readonly EMOJI_INFO="💡"
readonly EMOJI_ROCKET="🚀"
readonly EMOJI_GEAR="⚙️"
readonly EMOJI_DB="🗄️"
readonly EMOJI_NETWORK="🌐"
readonly EMOJI_SHIELD="🛡️"
readonly EMOJI_CLOCK="⏰"
readonly EMOJI_FOLDER="📂"
readonly EMOJI_KEY="🔑"
readonly EMOJI_LINK="🔗"
readonly EMOJI_COMPUTER="🖥️"
readonly EMOJI_DOCKER="🐳"
readonly EMOJI_SERVER="🔧"
readonly EMOJI_DOWNLOAD="⬇️"
readonly EMOJI_UPLOAD="⬆️"
readonly EMOJI_SPARKLE="✨"
readonly EMOJI_PARTY="🎉"
readonly EMOJI_THUMBS="👍"
readonly EMOJI_WAVE="👋"
readonly EMOJI_EYE="👁️"
readonly EMOJI_BRAIN="🧠"
readonly EMOJI_HAMMER="🔨"
readonly EMOJI_MAG="🔍"
readonly EMOJI_LOCK="🔒"
readonly EMOJI_UNLOCK="🔓"
readonly EMOJI_BELL="🔔"
readonly EMOJI_FLAG="🏁"
readonly EMOJI_STAR="⭐"
readonly EMOJI_FIRE="🔥"
readonly EMOJI_DIAMOND="💎"
readonly EMOJI_CRYSTAL="🔮"
readonly EMOJI_SPEED="⚡"
readonly EMOJI_LOADING="🔄"

# ============================================================================
# UI COMPONENTS
# ============================================================================
show_header() {
    clear
    echo -e "${GRADIENT_BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                          ║"
    echo -e "║  ${GRADIENT_CYAN}██████╗ ██╗  ██╗    ██╗  ██╗ ██████╗ ███████╗ █████╗ ███╗   ███╗${GRADIENT_BLUE}                    ║"
    echo -e "║  ${GRADIENT_CYAN}██╔══██╗██║  ██║    ██║  ██║██╔═══██╗██╔════╝██╔══██╗████╗ ████║${GRADIENT_BLUE}                    ║"
    echo -e "║  ${GRADIENT_CYAN}██████╔╝███████║    ███████║██║   ██║███████╗███████║██╔████╔██║${GRADIENT_BLUE}                    ║"
    echo -e "║  ${GRADIENT_CYAN}██╔══██╗██╔══██║    ██╔══██║██║   ██║╚════██║██╔══██║██║╚██╔╝██║${GRADIENT_BLUE}                    ║"
    echo -e "║  ${GRADIENT_CYAN}██║  ██║██║  ██║    ██║  ██║╚██████╔╝███████║██║  ██║██║ ╚═╝ ██║${GRADIENT_BLUE}                    ║"
    echo -e "║  ${GRADIENT_CYAN}╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝${GRADIENT_BLUE}                    ║"
    echo "║                                                                                          ║"
    echo -e "║  ${BOLD}${GRADIENT_PURPLE}${EMOJI_DIAMOND}  KS HOSTING BY KSGAMING - ENTERPRISE DEPLOYMENT SYSTEM  ${EMOJI_DIAMOND}${GRADIENT_BLUE}           ║"
    echo -e "║  ${BOLD}${GRADIENT_PINK}Version ${SCRIPT_VERSION} • Professional • Secure • Reliable${GRADIENT_BLUE}                     ║"
    echo "║                                                                                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo -e "${DIM}${GRADIENT_PURPLE}════════════════════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${GRADIENT_CYAN}${EMOJI_COMPUTER}  System: $(lsb_release -ds 2>/dev/null || echo 'Linux System')${RESET}"
    echo -e "${GRADIENT_BLUE}${EMOJI_CLOCK}  Started: $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "${DIM}${GRADIENT_PURPLE}════════════════════════════════════════════════════════════════════════════════════════════${RESET}\n"
}

show_menu() {
    echo -e "${BOLD}${GRADIENT_BLUE}${EMOJI_CRYSTAL}  DEPLOYMENT CONSOLE ${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e ""
    
    echo -e "  ${SUCCESS_COLOR}${EMOJI_DOCKER} [1] Docker Deployment${RESET}"
    echo -e "     ${DIM}Containerized setup with automatic service management${RESET}"
    echo -e ""
    
    echo -e "  ${INFO_COLOR}${EMOJI_SERVER} [2] Traditional Deployment${RESET}"
    echo -e "     ${DIM}Native installation with full system integration${RESET}"
    echo -e ""
    
    echo -e "  ${GRADIENT_CYAN}${EMOJI_MAG} [3] System Diagnostics${RESET}"
    echo -e "  ${GRADIENT_PURPLE}${EMOJI_EYE} [4] View Installation Log${RESET}"
    echo -e "  ${WARNING_COLOR}${EMOJI_WARN} [5] Uninstall Options${RESET}"
    echo -e ""
    
    echo -e "  ${GRADIENT_BLUE}${EMOJI_WAVE} [0] Exit Console${RESET}"
    echo -e ""
    
    echo -e "${DIM}${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

show_divider() {
    echo -e "${DIM}${GRADIENT_PURPLE}────────────────────────────────────────────────────────────────────────────────${RESET}"
}

show_section() {
    local title="$1"
    local emoji="$2"
    
    echo -e "\n${BOLD}${GRADIENT_BLUE}${emoji}  ${title} ${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

show_subsection() {
    local title="$1"
    local emoji="$2"
    
    echo -e "\n${BOLD}${GRADIENT_CYAN}${emoji}  ${title}${RESET}"
}

show_progress_ui() {
    local step="$1"
    local total="$2"
    local message="$3"
    
    local width=50
    local percent=$((step * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "\r${GRADIENT_BLUE}${EMOJI_LOADING}  Progress: ["
    printf "%${filled}s" "" | sed 's/ /█/g'
    printf "%${empty}s" "" | sed 's/ /░/g'
    printf "] ${percent}%% • ${message}${RESET}"
    
    if [ $step -eq $total ]; then
        echo ""
    fi
}

# ============================================================================
# ANIMATION FUNCTIONS
# ============================================================================
show_loading() {
    local message="$1"
    local pid="$2"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    
    echo -ne "${GRADIENT_CYAN}${EMOJI_LOADING}  ${message}... ${RESET}"
    
    while kill -0 "$pid" 2>/dev/null; do
        echo -ne "${GRADIENT_PURPLE}${frames[i]}${RESET}"
        sleep 0.1
        echo -ne "\b"
        i=$(( (i + 1) % ${#frames[@]} ))
    done
    
    echo -ne "\b"
}

show_spinner() {
    local message="$1"
    local duration="${2:-3}"
    local frames=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
    
    echo -ne "${GRADIENT_CYAN}${EMOJI_LOADING}  ${message}... ${RESET}"
    
    for ((i=0; i<duration*10; i++)); do
        echo -ne "${GRADIENT_PURPLE}${frames[i % ${#frames[@]}]}${RESET}"
        sleep 0.1
        echo -ne "\b"
    done
    
    echo -ne "\b"
}

show_countdown() {
    local seconds="$1"
    local message="$2"
    
    echo -ne "${GRADIENT_BLUE}${EMOJI_CLOCK}  ${message} ${RESET}"
    
    for ((i=seconds; i>0; i--)); do
        echo -ne "${GRADIENT_PURPLE}${i}s${RESET}"
        sleep 1
        echo -ne "\b\b"
    done
    
    echo -ne "  "
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================
log_success() {
    echo -e "${SUCCESS_COLOR}${EMOJI_CHECK}  ${BOLD}SUCCESS:${RESET} ${SUCCESS_COLOR}$1${RESET}"
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${ERROR_COLOR}${EMOJI_CROSS}  ${BOLD}ERROR:${RESET} ${ERROR_COLOR}$1${RESET}"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_info() {
    echo -e "${INFO_COLOR}${EMOJI_INFO}  ${BOLD}INFO:${RESET} ${INFO_COLOR}$1${RESET}"
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "${WARNING_COLOR}${EMOJI_WARN}  ${BOLD}WARNING:${RESET} ${WARNING_COLOR}$1${RESET}"
    echo "[WARNING] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_step() {
    echo -e "\n${BOLD}${GRADIENT_BLUE}${EMOJI_FLAG}  STEP: $1${RESET}"
    show_divider
}

log_substep() {
    echo -e "${GRADIENT_CYAN}${EMOJI_BRAIN}  $1${RESET}"
}

# ============================================================================
# COMMAND EXECUTION FUNCTIONS
# ============================================================================
run_command() {
    local cmd="$1"
    local description="$2"
    local show_output="${3:-false}"
    
    # Show command execution
    echo -e "\n${GRADIENT_CYAN}${EMOJI_GEAR}  ${description}${RESET}"
    echo -e "${DIM}${GRADIENT_PURPLE}└─ ${cmd}${RESET}"
    
    # Execute command
    if [ "$show_output" = "true" ]; then
        if eval "$cmd" >> "$LOG_FILE" 2>&1; then
            echo -e "${SUCCESS_COLOR}${EMOJI_CHECK}  Completed${RESET}"
            return 0
        else
            echo -e "${ERROR_COLOR}${EMOJI_CROSS}  Failed${RESET}"
            return 1
        fi
    else
        if eval "$cmd" >> "$LOG_FILE" 2>&1 & then
            local pid=$!
            show_loading "Processing" "$pid"
            wait "$pid"
            
            if [ $? -eq 0 ]; then
                echo -e "${SUCCESS_COLOR}${EMOJI_CHECK}${RESET}"
                return 0
            else
                echo -e "${ERROR_COLOR}${EMOJI_CROSS}${RESET}"
                return 1
            fi
        fi
    fi
}

run_async() {
    local cmd="$1"
    local description="$2"
    
    echo -ne "${GRADIENT_CYAN}${EMOJI_SPEED}  ${description}... ${RESET}"
    
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        echo -e "${SUCCESS_COLOR}${EMOJI_CHECK}${RESET}"
        return 0
    else
        echo -e "${ERROR_COLOR}${EMOJI_CROSS}${RESET}"
        return 1
    fi
}

run_verbose() {
    local cmd="$1"
    local description="$2"
    
    echo -e "\n${GRADIENT_CYAN}${EMOJI_GEAR}  ${description}${RESET}"
    echo -e "${DIM}${GRADIENT_PURPLE}└─ ${cmd}${RESET}"
    
    # Show spinner for 2 seconds
    show_spinner "Initializing" 2
    
    # Execute and show output
    echo -e "\n${DIM}${GRADIENT_PURPLE}Output:${RESET}"
    echo -e "${GRADIENT_BLUE}"
    eval "$cmd"
    local exit_code=$?
    echo -e "${RESET}"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${SUCCESS_COLOR}${EMOJI_CHECK}  Command completed successfully${RESET}"
        return 0
    else
        echo -e "${ERROR_COLOR}${EMOJI_CROSS}  Command failed with exit code: $exit_code${RESET}"
        return 1
    fi
}

# ============================================================================
# SYSTEM FUNCTIONS
# ============================================================================
validate_system() {
    show_section "System Validation" "${EMOJI_SHIELD}"
    
    # Check OS
    if [ ! -f /etc/os-release ]; then
        log_error "Unable to detect operating system"
        exit 1
    fi
    
    source /etc/os-release
    
    case "$ID" in
        ubuntu|debian)
            log_success "Operating System: $PRETTY_NAME"
            ;;
        *)
            log_error "Unsupported OS: $PRETTY_NAME"
            exit 1
            ;;
    esac
    
    # Check root privileges
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root: sudo bash $0"
        exit 1
    fi
    
    # Check essential tools
    local tools=("curl" "wget" "systemctl")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "${INFO_COLOR}${EMOJI_CHECK}  $tool available${RESET}"
        else
            log_warning "$tool not found (will be installed)"
        fi
    done
    
    log_success "System validation passed"
}

update_system() {
    show_section "System Update" "${EMOJI_DOWNLOAD}"
    
    run_async "apt-get update -qq" "Updating package lists"
    run_async "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq" "Upgrading system"
    
    log_success "System updated"
}

install_packages() {
    local packages=("$@")
    local install_list=()
    
    show_subsection "Package Management" "${EMOJI_HAMMER}"
    
    # Check existing packages
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "${SUCCESS_COLOR}${EMOJI_CHECK}  $pkg already installed${RESET}"
        else
            install_list+=("$pkg")
        fi
    done
    
    # Install missing packages
    if [ ${#install_list[@]} -gt 0 ]; then
        echo -e "${INFO_COLOR}${EMOJI_DOWNLOAD}  Installing: ${install_list[*]}${RESET}"
        
        run_command "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ${install_list[@]}" \
            "Installing packages"
    fi
}

# ============================================================================
# DATABASE FUNCTIONS
# ============================================================================
setup_database() {
    show_section "Database Configuration" "${EMOJI_DB}"
    
    local db_name="mythicaldash"
    local db_user="mythical_user"
    local db_pass=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24)
    
    show_subsection "Securing MariaDB" "${EMOJI_LOCK}"
    
    run_async "mysql -e \"DELETE FROM mysql.user WHERE User='';\" >/dev/null 2>&1" "Removing anonymous users"
    run_async "mysql -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\" >/dev/null 2>&1" "Securing root access"
    
    show_subsection "Creating Database" "${EMOJI_FOLDER}"
    
    run_command "mysql -e \"CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\"" \
        "Creating database"
    
    run_command "mysql -e \"CREATE USER IF NOT EXISTS '$db_user'@'127.0.0.1' IDENTIFIED BY '$db_pass';\"" \
        "Creating database user"
    
    run_command "mysql -e \"GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'127.0.0.1';\"" \
        "Granting privileges"
    
    run_async "mysql -e \"FLUSH PRIVILEGES;\"" "Finalizing"
    
    # Save credentials
    mkdir -p /etc/mythicaldash
    cat > /etc/mythicaldash/db.conf <<EOF
# Database Configuration - KS HOSTING
# Generated: $(date)
# Do not modify manually

DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_NAME="$db_name"
DB_USER="$db_user"
DB_PASS="$db_pass"
EOF
    
    chmod 600 /etc/mythicaldash/db.conf
    
    echo -e "${SUCCESS_COLOR}${EMOJI_KEY}  Credentials saved to: /etc/mythicaldash/db.conf${RESET}"
    log_success "Database configured"
}

# ============================================================================
# APPLICATION FUNCTIONS
# ============================================================================
deploy_application() {
    local mode="$1"
    
    show_section "Application Deployment" "${EMOJI_ROCKET}"
    
    # Create directory
    run_async "mkdir -p $INSTALL_DIR" "Creating installation directory"
    run_async "chmod 755 $INSTALL_DIR" "Setting permissions"
    
    # Download application
    show_subsection "Downloading" "${EMOJI_DOWNLOAD}"
    
    local download_url="https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip"
    local temp_file="/tmp/mythicaldash-$(date +%s).zip"
    
    run_command "wget -q -O '$temp_file' '$download_url'" "Downloading MythicalDash"
    
    # Extract
    show_subsection "Extracting" "${EMOJI_UPLOAD}"
    
    run_command "unzip -q -o '$temp_file' -d '$INSTALL_DIR'" "Extracting files"
    run_async "rm -f '$temp_file'" "Cleaning up"
    
    # Set permissions
    show_subsection "Permissions" "${EMOJI_LOCK}"
    
    run_async "chown -R www-data:www-data '$INSTALL_DIR'" "Setting ownership"
    run_async "find '$INSTALL_DIR' -type d -exec chmod 755 {} \;" "Setting directory permissions"
    run_async "find '$INSTALL_DIR' -type f -exec chmod 644 {} \;" "Setting file permissions"
    
    log_success "Application deployed"
}

setup_nginx() {
    show_section "Web Server Configuration" "${EMOJI_NETWORK}"
    
    cat > /etc/nginx/sites-available/mythicaldash <<'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/mythicaldash-v3/public;
    index index.php;
    
    client_max_body_size 100M;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
    
    run_async "ln -sf /etc/nginx/sites-available/mythicaldash /etc/nginx/sites-enabled/" "Enabling site"
    run_async "rm -f /etc/nginx/sites-enabled/default" "Removing default"
    
    run_command "nginx -t" "Testing configuration" true
    run_async "systemctl reload nginx" "Reloading service"
    
    log_success "Nginx configured"
}

# ============================================================================
# DOCKER FUNCTIONS
# ============================================================================
install_docker() {
    show_section "Docker Installation" "${EMOJI_DOCKER}"
    
    show_subsection "Preparing System" "${EMOJI_GEAR}"
    run_async "apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null" "Cleaning old versions"
    
    show_subsection "Installing Docker" "${EMOJI_DOWNLOAD}"
    run_command "curl -fsSL https://get.docker.com -o /tmp/get-docker.sh" "Downloading installer"
    run_command "sh /tmp/get-docker.sh" "Installing Docker Engine"
    run_async "rm -f /tmp/get-docker.sh" "Cleaning up"
    
    show_subsection "Starting Services" "${EMOJI_ROCKET}"
    run_async "systemctl enable docker" "Enabling service"
    run_async "systemctl start docker" "Starting service"
    
    show_subsection "Configuring User" "${EMOJI_COMPUTER}"
    run_async "usermod -aG docker $SUDO_USER" "Adding user to docker group"
    
    run_async "docker --version" "Verifying installation"
    
    log_success "Docker installed"
}

deploy_with_docker() {
    show_section "Docker Deployment" "${EMOJI_SERVER}"
    
    cd "$INSTALL_DIR"
    
    show_subsection "Starting Services" "${EMOJI_ROCKET}"
    run_command "docker compose up -d" "Starting containers"
    
    show_countdown 10 "Waiting for initialization"
    
    run_async "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" "Checking container status"
    
    log_success "Docker services started"
}

# ============================================================================
# USER INTERFACE FUNCTIONS
# ============================================================================
prompt_yes_no() {
    local prompt="$1"
    local default="${2:-no}"
    
    while true; do
        echo -ne "${GRADIENT_CYAN}${EMOJI_BRAIN}  ${prompt} [y/N]: ${RESET}"
        read -r response
        
        case "${response:-$default}" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "${WARNING_COLOR}${EMOJI_WARN}  Please answer yes or no${RESET}" ;;
        esac
    done
}

prompt_input() {
    local prompt="$1"
    local default="$2"
    
    echo -ne "${GRADIENT_CYAN}${EMOJI_BRAIN}  ${prompt}"
    
    if [ -n "$default" ]; then
        echo -ne " [${GRADIENT_PURPLE}${default}${RESET}]: "
    else
        echo -ne ": "
    fi
    
    read -r response
    
    if [ -z "$response" ] && [ -n "$default" ]; then
        echo "$default"
    else
        echo "$response"
    fi
}

show_diagnostics() {
    show_section "System Diagnostics" "${EMOJI_MAG}"
    
    echo -e "${GRADIENT_CYAN}${EMOJI_COMPUTER}  System Information${RESET}"
    echo -e "  ${DIM}OS:${RESET} $(lsb_release -ds 2>/dev/null || echo 'Unknown')"
    echo -e "  ${DIM}Kernel:${RESET} $(uname -r)"
    echo -e "  ${DIM}Architecture:${RESET} $(uname -m)"
    echo -e "  ${DIM}Uptime:${RESET} $(uptime -p | sed 's/up //')"
    
    echo -e "\n${GRADIENT_CYAN}${EMOJI_DB}  Resources${RESET}"
    echo -e "  ${DIM}CPU:${RESET} $(nproc) cores"
    echo -e "  ${DIM}Memory:${RESET} $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "  ${DIM}Disk:${RESET} $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    
    echo -e "\n${GRADIENT_CYAN}${EMOJI_NETWORK}  Network${RESET}"
    echo -e "  ${DIM}IP Address:${RESET} $(hostname -I | awk '{print $1}')"
    echo -e "  ${DIM}Public IP:${RESET} $(curl -s ifconfig.me 2>/dev/null || echo 'Not available')"
    
    echo -e "\n${SUCCESS_COLOR}${EMOJI_CHECK}  Diagnostics complete${RESET}"
}

# ============================================================================
# INSTALLATION FLOWS
# ============================================================================
install_docker_flow() {
    show_header
    echo -e "${BOLD}${GRADIENT_BLUE}${EMOJI_DOCKER}  DOCKER DEPLOYMENT ${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    
    # Step 1: System Validation
    validate_system
    
    # Step 2: System Update
    update_system
    
    # Step 3: Install Docker
    install_docker
    
    # Step 4: Install tools
    show_section "Installing Tools" "${EMOJI_HAMMER}"
    install_packages curl wget unzip jq
    
    # Step 5: Deploy Application
    deploy_application "docker"
    
    # Step 6: Start Services
    deploy_with_docker
    
    # Additional Configuration
    echo -e "\n${GRADIENT_PURPLE}${EMOJI_GEAR}  ADDITIONAL CONFIGURATION ${GRADIENT_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    # Pterodactyl Configuration
    if prompt_yes_no "Configure Pterodactyl integration?"; then
        local ptero_url=$(prompt_input "Pterodactyl Panel URL")
        local ptero_key=$(prompt_input "Pterodactyl API Key")
        
        if [ -n "$ptero_url" ] && [ -n "$ptero_key" ]; then
            show_subsection "Configuring Pterodactyl" "${EMOJI_SERVER}"
            
            local config_cmd="docker exec -i mythicaldash_v3_backend php cli pterodactyl configure <<EOF
y
$ptero_url
$ptero_key
y
EOF"
            run_verbose "$config_cmd" "Setting up integration"
        fi
    fi
    
    # Cloudflare Configuration
    if prompt_yes_no "Setup Cloudflare Tunnel?"; then
        local cf_mode=$(prompt_input "Tunnel mode (full/semi)" "semi")
        local cf_hostname=$(prompt_input "Hostname (e.g., dash.example.com)")
        
        if [ "$cf_mode" = "full" ]; then
            local cf_email=$(prompt_input "Cloudflare Email")
            local cf_apikey=$(prompt_input "Cloudflare API Key")
            # Cloudflare setup would go here
            echo -e "${INFO_COLOR}${EMOJI_INFO}  Cloudflare full setup selected${RESET}"
        else
            echo -e "${INFO_COLOR}${EMOJI_INFO}  Manual Cloudflare configuration required${RESET}"
        fi
    fi
    
    # Completion
    show_completion "docker"
}

install_traditional_flow() {
    show_header
    echo -e "${BOLD}${GRADIENT_BLUE}${EMOJI_SERVER}  TRADITIONAL DEPLOYMENT ${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    
    # Step 1: System Validation
    validate_system
    
    # Step 2: System Update
    update_system
    
    # Step 3: Install Packages
    show_section "System Packages" "${EMOJI_HAMMER}"
    
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
    
    # Step 4: Database Setup
    setup_database
    
    # Step 5: Deploy Application
    deploy_application "traditional"
    
    # Step 6: Configure Nginx
    setup_nginx
    
    # Step 7: PHP Dependencies
    show_section "PHP Dependencies" "${EMOJI_GEAR}"
    
    cd "$INSTALL_DIR"
    run_command "composer install --no-dev --optimize-autoloader" "Installing Composer packages"
    
    # Step 8: Application Setup
    show_section "Application Configuration" "${EMOJI_CRYSTAL}"
    
    run_async "cp .env.example .env 2>/dev/null || true" "Creating environment"
    run_command "php artisan key:generate" "Generating application key"
    
    # Configure database
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
    
    run_command "php artisan migrate --force" "Running migrations"
    run_async "php artisan storage:link" "Linking storage"
    
    # Step 9: Cron Jobs
    show_section "Scheduled Tasks" "${EMOJI_CLOCK}"
    
    local cron_cmd="(crontab -l 2>/dev/null; echo \"* * * * * cd $INSTALL_DIR && php artisan schedule:run >> /dev/null 2>&1\") | crontab -"
    run_async "$cron_cmd" "Setting up cron job"
    
    # Completion
    show_completion "traditional"
}

show_completion() {
    local mode="$1"
    
    echo -e "\n${SUCCESS_COLOR}${EMOJI_PARTY}${BOLD}  DEPLOYMENT SUCCESSFUL! ${EMOJI_PARTY}${RESET}"
    show_divider
    
    if [ "$mode" = "docker" ]; then
        echo -e "${GRADIENT_CYAN}${EMOJI_LINK}  Dashboard URL:${RESET} ${BOLD}http://localhost:4830${RESET}"
        echo -e "${GRADIENT_CYAN}${EMOJI_DOCKER}  Container Status:${RESET} ${BOLD}docker ps${RESET}"
        echo -e "${GRADIENT_CYAN}${EMOJI_EYE}  View Logs:${RESET} ${BOLD}docker logs mythicaldash_v3_backend${RESET}"
    else
        echo -e "${GRADIENT_CYAN}${EMOJI_LINK}  Dashboard URL:${RESET} ${BOLD}http://$(hostname -I | awk '{print $1}')${RESET}"
        echo -e "${GRADIENT_CYAN}${EMOJI_KEY}  Database Config:${RESET} ${BOLD}/etc/mythicaldash/db.conf${RESET}"
        echo -e "${GRADIENT_CYAN}${EMOJI_NETWORK}  Nginx Config:${RESET} ${BOLD}/etc/nginx/sites-available/mythicaldash${RESET}"
    fi
    
    echo -e ""
    echo -e "${GRADIENT_CYAN}${EMOJI_FOLDER}  Installation Directory:${RESET} ${BOLD}$INSTALL_DIR${RESET}"
    echo -e "${GRADIENT_CYAN}${EMOJI_EYE}  Installation Log:${RESET} ${BOLD}$LOG_FILE${RESET}"
    
    echo -e "\n${WARNING_COLOR}${EMOJI_BELL}  Next Steps:${RESET}"
    echo -e "  ${DIM}1. Access your dashboard at the URL above${RESET}"
    echo -e "  ${DIM}2. Configure your administrator account${RESET}"
    echo -e "  ${DIM}3. Set up SSL/TLS certificates for production${RESET}"
    echo -e "  ${DIM}4. Configure backup and monitoring${RESET}"
    
    show_divider
    echo -e "${GRADIENT_PURPLE}${EMOJI_SPARKLE}  Thank you for choosing KS HOSTING BY KSGAMING! ${EMOJI_SPARKLE}${RESET}\n"
}

# ============================================================================
# MAIN PROGRAM
# ============================================================================
main() {
    # Initialize logging
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=== KS HOSTING Deployment Started $(date) ===" > "$LOG_FILE"
    echo "=== Version: $SCRIPT_VERSION ===" >> "$LOG_FILE"
    
    # Create config directory
    mkdir -p /etc/mythicaldash
    
    while true; do
        show_header
        show_menu
        
        echo -ne "${GRADIENT_CYAN}${EMOJI_BRAIN}  Select option [0-5]: ${RESET}"
        read -r choice
        
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
                show_header
                show_diagnostics
                echo -ne "\n${GRADIENT_CYAN}Press Enter to continue...${RESET}"
                read -r _
                ;;
            4)
                show_header
                echo -e "${GRADIENT_CYAN}${EMOJI_EYE}  Installation Log ${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
                if [ -f "$LOG_FILE" ]; then
                    echo -e "${DIM}"
                    tail -30 "$LOG_FILE"
                    echo -e "${RESET}"
                else
                    echo -e "${WARNING_COLOR}${EMOJI_WARN}  No log file found${RESET}"
                fi
                echo -e "${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
                echo -ne "\n${GRADIENT_CYAN}Press Enter to continue...${RESET}"
                read -r _
                ;;
            5)
                show_header
                echo -e "${WARNING_COLOR}${EMOJI_WARN}  UNINSTALL OPTIONS ${GRADIENT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
                echo -e "  ${GRADIENT_CYAN}[1] ${RESET}Remove Docker installation"
                echo -e "  ${GRADIENT_CYAN}[2] ${RESET}Remove Traditional installation"
                echo -e "  ${GRADIENT_CYAN}[3] ${RESET}Back to main menu"
                echo -e ""
                echo -ne "${GRADIENT_CYAN}Select option [1-3]: ${RESET}"
                read -r uninstall_choice
                
                case $uninstall_choice in
                    1)
                        echo -e "\n${WARNING_COLOR}${EMOJI_WARN}  Removing Docker installation...${RESET}"
                        if [ -d "$INSTALL_DIR" ]; then
                            cd "$INSTALL_DIR" && run_async "docker compose down -v" "Stopping containers"
                            run_async "rm -rf $INSTALL_DIR" "Removing files"
                            log_success "Docker installation removed"
                        else
                            echo -e "${INFO_COLOR}${EMOJI_INFO}  Installation not found${RESET}"
                        fi
                        ;;
                    2)
                        echo -e "\n${WARNING_COLOR}${EMOJI_WARN}  Removing Traditional installation...${RESET}"
                        run_async "rm -rf $INSTALL_DIR" "Removing application"
                        run_async "mysql -e 'DROP DATABASE IF EXISTS mythicaldash'" "Removing database"
                        run_async "rm -f /etc/nginx/sites-{available,enabled}/mythicaldash" "Removing Nginx config"
                        log_success "Traditional installation removed"
                        ;;
                esac
                
                echo -ne "\n${GRADIENT_CYAN}Press Enter to continue...${RESET}"
                read -r _
                ;;
            0)
                echo -e "\n${GRADIENT_BLUE}${EMOJI_WAVE}  Thank you for using KS HOSTING!${RESET}"
                echo -e "${GRADIENT_PURPLE}Goodbye!${RESET}\n"
                exit 0
                ;;
            *)
                echo -e "${ERROR_COLOR}${EMOJI_CROSS}  Invalid selection!${RESET}"
                sleep 1
                ;;
        esac
    done
    
    # Final message
    echo -e "\n${SUCCESS_COLOR}${EMOJI_SPARKLE}  Process completed successfully! ${EMOJI_SPARKLE}${RESET}"
    show_divider
    echo -e "${DIM}Log file: $LOG_FILE${RESET}"
    echo -e "${DIM}Need assistance? Contact our support team.${RESET}"
    show_divider
}

# ============================================================================
# ENTRY POINT
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
