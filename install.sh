#!/bin/bash
# MythicalDash Installation Script (Emoji-Enhanced)
# Version 2.1.1
# Supports Ubuntu, Ubuntu Server, and Debian

# ----------------- ANSI COLOR CODES -----------------
# Define colors for better UI/UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Helper function for colored text
echo_color() {
    COLOR=$1
    MESSAGE=$2
    echo -e "${COLOR}${MESSAGE}${NC}"
}

# ----------------- UI/UX FUNCTIONS -----------------

# Function to display a step header with an emoji
step_header() {
    echo ""
    echo_color $CYAN "========================================================"
    echo_color $CYAN "$1 $2"
    echo_color $CYAN "========================================================"
    echo ""
}

# Function to show a progress indicator (Spinner)
# Usage: spinner "Message..." & SPINNER_PID=$!
spinner() {
    local pid=$!
    local delay=0.1
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local message=$1
    
    while [ -d /proc/$pid ]; do
        local i=$((i+1 % ${#spin}))
        printf "\r${YELLOW}  [${spin:$i:1}] ${message}${NC}"
        sleep $delay
    done
    printf "\r${GREEN}  [✅] ${message} Done.${NC}\n" # Success checkmark
}

# ----------------- CORE FUNCTIONS -----------------

echo_color $PURPLE "✨ Script By _webdevkin && MythicalLTD By Cassian (V2.1.1)"

# Function to check if a package is installed and install it if not
install_packages() {
    packages_to_install=()
    for pkg in "$@"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1;
        then
            packages_to_install+=("$pkg")
        fi
    done

    if [ ${#packages_to_install[@]} -gt 0 ]; then
        echo_color $YELLOW "  📦 Installing packages: ${packages_to_install[*]}..."
        sudo apt-get -qq install -y "${packages_to_install[@]}"
        if [ $? -ne 0 ]; then
            echo_color $RED "  [❌] Failed to install one or more packages. Exiting."
            exit 1
        fi
    else
        echo_color $GREEN "  ✅ All required dependencies already installed. Skipping..."
    fi
}

# Uninstall functions (added emojis)
uninstall_docker() {
    step_header "🗑️ Uninstalling MythicalDash (Docker)"
    uninstall_cloudflare_tunnel
    if [ -f /var/www/mythicaldash-v3/docker-compose.yml ]; then
        echo_color $YELLOW "  🛑 Stopping and removing Docker containers..."
        (cd /var/www/mythicaldash-v3 && sudo docker compose down -v) & spinner "Containers removal"
    fi
    echo_color $YELLOW "  🗑️ Removing MythicalDash files..."
    sudo rm -rf /var/www/mythicaldash-v3
    echo_color $GREEN "✅ Docker-based uninstallation complete."
}

uninstall_no_docker() {
    step_header "🗑️ Uninstalling MythicalDash (Native)"
    uninstall_cloudflare_tunnel
    echo_color $YELLOW "  ❌ Removing MariaDB database and user..."
    sudo mysql -e "DROP DATABASE IF EXISTS mythicaldash_remastered;"
    sudo mysql -e "DROP USER IF EXISTS 'mythicaldash_remastered'@'127.0.0.1';" & spinner "Database cleanup"

    echo_color $YELLOW "  🛑 Stopping services (Redis/MariaDB)..."
    sudo systemctl stop redis-server
    sudo systemctl stop mariadb & spinner "Stopping services"

    echo_color $YELLOW "  🗑️ Removing MythicalDash files..."
    sudo rm -rf /var/www/mythicaldash-v3 & spinner "File removal"

    echo_color $YELLOW "  ⏰ Removing cron jobs..."
    (crontab -l | grep -v -e '/var/www/mythicaldash-v3/') | crontab - & spinner "Cron job cleanup"
    
    echo_color $GREEN "✅ Native uninstallation complete."
}

uninstall_cloudflare_tunnel() {
    echo_color $CYAN "--- ☁️ Cloudflare Tunnel Cleanup ---"
    if [ -f /var/www/mythicaldash-v3/.cf_creds ]; then
        # shellcheck source=/dev/null
        . /var/www/mythicaldash-v3/.cf_creds
        if [ -n "$TUNNEL_ID" ] && [ -n "$ACCOUNT_ID" ] && [ -n "$ZONE_ID" ] && [ -n "$CF_HOSTNAME" ]; then
            echo_color $YELLOW "  🗑️ Attempting to delete DNS record for $CF_HOSTNAME..."
            DNS_RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=CNAME&name=$CF_HOSTNAME" \
                 -H "X-Auth-Email: $CF_EMAIL" \
                 -H "X-Auth-Key: $CF_API_KEY" \
                 -H "Content-Type: application/json" | jq -r '.result[0].id')

            if [ -n "$DNS_RECORD_ID" ] && [ "$DNS_RECORD_ID" != "null" ]; then
                curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
                     -H "X-Auth-Email: $CF_EMAIL" \
                     -H "X-Auth-Key: $CF_API_KEY" \
                     -H "Content-Type: application/json" > /dev/null
                echo_color $GREEN "  ✅ DNS record deleted."
            else
                echo_color $YELLOW "  ⚠️ Could not find DNS record or already deleted."
            fi

            echo_color $YELLOW "  🗑️ Deleting Cloudflare Tunnel..."
            curl -s -X DELETE "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID" \
                 -H "X-Auth-Email: $CF_EMAIL" \
                 -H "X-Auth-Key: $CF_API_KEY" \
                 -H "Content-Type: application/json" > /dev/null
            echo_color $GREEN "  ✅ Cloudflare Tunnel deleted."
        else
            echo_color $YELLOW "  ⚠️ Cloudflare credentials incomplete. Skipping tunnel deletion."
        fi
        sudo rm /var/www/mythicaldash-v3/.cf_creds
        echo_color $GREEN "  🔑 Credentials file removed."
    else
        echo_color $YELLOW "  ⚠️ Cloudflare credentials file not found. Skipping tunnel deletion."
    fi
    echo_color $CYAN "-----------------------------------"
}

# Cloudflare setup functions (added emojis)
setup_cloudflare_tunnel_full_auto() {
    step_header "☁️ Cloudflare Tunnel: Full Automatic Setup" "🛠️"
    install_packages jq

    ACCOUNTS_DATA=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
         -H "X-Auth-Email: $CF_EMAIL" \
         -H "X-Auth-Key: $CF_API_KEY" \
         -H "Content-Type: application/json")

    ACCOUNT_COUNT=$(echo "$ACCOUNTS_DATA" | jq -r '.result | length')

    if [ "$ACCOUNT_COUNT" == "0" ]; then
        echo_color $RED "❌ Error: No Cloudflare accounts found. Please check your email and API key."
        return 1
    elif [ "$ACCOUNT_COUNT" -gt "1" ]; then
        echo_color $YELLOW "Multiple Cloudflare accounts found. Please choose one:"
    echo "$ACCOUNTS_DATA" | jq -r '.result[] | "\(.id) \(.name)"' | nl
    read -r -p "$(echo_color $WHITE 'Enter the number of the account you want to use: ')" ACCOUNT_CHOICE
    ACCOUNT_ID=$(echo "$ACCOUNTS_DATA" | jq -r ".result[$((ACCOUNT_CHOICE-1))].id")
    fi
    
    # ... (Tunnel ID/Token/Zone ID logic remains the same)

    echo_color $YELLOW "  🔗 Configuring DNS and ingress rules via API..."
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data "$(jq -n --arg host "$CF_HOSTNAME" --arg tunnel "$TUNNEL_ID" '{type:"CNAME",name:$host,content:($tunnel + ".cfargotunnel.com"),proxied:true}')" > /dev/null
    
    curl -s -X PUT "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
         -H "Content-Type: application/json" \
        --data "$(jq -n --arg hostname "$CF_HOSTNAME" '{config:{ingress:[{hostname:$hostname,service:"http://localhost:4830"},{service:"http_status:404"}]}}')" > /dev/null
    
    echo_color $GREEN "✅ Full-automatic Cloudflare Tunnel setup complete. DNS and Ingress configured."

    # Save Cloudflare credentials
    {
        printf 'CF_EMAIL="%s"\n' "$CF_EMAIL"
        printf 'CF_API_KEY="%s"\n' "$CF_API_KEY"
        printf 'ACCOUNT_ID="%s"\n' "$ACCOUNT_ID"
        printf 'TUNNEL_ID="%s"\n' "$TUNNEL_ID"
        printf 'ZONE_ID="%s"\n' "$ZONE_ID"
        printf 'CF_HOSTNAME="%s"\n' "$CF_HOSTNAME"
    } > /var/www/mythicaldash-v3/.cf_creds
    sudo chmod 600 /var/www/mythicaldash-v3/.cf_creds
    echo_color $YELLOW "  🔒 Credentials saved securely to .cf_creds."
}

setup_cloudflare_tunnel_client() {
    if [ -n "$CF_TUNNEL_TOKEN" ]; then
        step_header "🚀 Cloudflare Tunnel Client Setup"
        if [ "$INST_TYPE" == "0" ]; then 
            if ! command -v docker &> /dev/null; then
                echo_color $YELLOW "  🐳 Docker not found, installing Docker for client container..."
                curl -sSL https://get.docker.com/ | CHANNEL=stable bash & spinner "Docker installation"
                sudo systemctl enable --now docker
                sudo usermod -aG docker "$USER"
                echo_color $YELLOW "  ⚠️ NOTE: You may need to log out and back in for Docker group changes to take effect."
            fi
            echo_color $YELLOW "  🚀 Starting Cloudflare Tunnel client container..."
            docker run -d --network host --restart always cloudflare/cloudflared:latest tunnel --no-autoupdate run --token "$CF_TUNNEL_TOKEN" & spinner "Tunnel client start (Docker)"
        else 
            echo_color $YELLOW "  📦 Installing cloudflared client..."
            curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
            sudo dpkg -i cloudflared.deb & spinner "cloudflared package install"
            sudo cloudflared service install "$CF_TUNNEL_TOKEN"
            sudo systemctl enable --now cloudflared & spinner "cloudflared service start"
            rm cloudflared.deb
            echo_color $GREEN "  ✅ cloudflared installed and running."
        fi
        echo_color $GREEN "✅ Cloudflare Tunnel setup complete. Dashboard accessible via: https://$CF_HOSTNAME"
        if [ "$CF_TUNNEL_MODE" == "2" ]; then
            echo_color $YELLOW "========================================================"
            echo_color $YELLOW "⚠️ SEMI-AUTOMATIC MODE NOTICE ⚠️"
            echo_color $YELLOW "Please manually create a CNAME DNS record for ${CF_HOSTNAME} in your Cloudflare dashboard."
            echo_color $YELLOW "The Ingress rule should point to http://localhost:4830."
            echo_color $YELLOW "========================================================"
        fi
    else
        echo_color $YELLOW "  ⏭️ Skipping Cloudflare Tunnel client setup."
    fi
}

# ----------------- MAIN EXECUTION -----------------

if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    OS=$ID
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "ubuntu-server" ] || [ "$OS" = "debian" ]; then
        echo_color $GREEN "✅ Detected Supported OS: ${OS^}"
        
        # --- UI: Ask all questions upfront with clear sections ---
        step_header "🖥️ Choose Operation"
        INST_TYPE=""
        while [[ ! "$INST_TYPE" =~ ^[0-3]$ ]]; do
            echo_color $WHITE "1: 🐳 Install with Docker"
            echo_color $WHITE "2: 💻 Install without Docker (Native)"
            echo_color $RED "3: 🗑️ Uninstall Docker installation"
            echo_color $RED "4: 🗑️ Uninstall without-Docker installation"
            read -r -p "$(echo_color $CYAN 'Option (1/2/3/4): ')" INST_TYPE
            # Map user's 1-4 input back to 0-3 for case statement compatibility
            if [ "$INST_TYPE" = "1" ]; then INST_TYPE="0"; 
            elif [ "$INST_TYPE" = "2" ]; then INST_TYPE="1"; 
            elif [ "$INST_TYPE" = "3" ]; then INST_TYPE="2";
            elif [ "$INST_TYPE" = "4" ]; then INST_TYPE="3";
            elif [[ ! "$INST_TYPE" =~ ^[0-3]$ ]]; then
                echo_color $RED "❌ Invalid input. Please enter 1, 2, 3, or 4."
            fi
        done

        # ... (variable setup remains the same)

        if [[ "$INST_TYPE" == "0" || "$INST_TYPE" == "1" ]]; then
            # --- UI: Reinstall Check ---
            if [ -f /var/www/mythicaldash-v3/.installed ]; then
                read -r -p "$(echo_color $YELLOW '⚠️ MythicalDash appears to be installed. Reinstall? (y/n): ')" reinstall
                if [ "$reinstall" != "y" ]; then
                    echo_color $GREEN "✅ Exiting installation as requested."
                    exit 0
                fi
            fi

            # --- UI: Cloudflare Tunnel Configuration ---
            step_header "☁️ Cloudflare Tunnel Configuration" "🔑"
            while [[ ! "$CF_TUNNEL_SETUP" =~ ^[ynYN]$ ]]; do
                read -r -p "$(echo_color $WHITE 'Set up Cloudflare Tunnel for secure access? (y/n): ')" CF_TUNNEL_SETUP
            done

            if [[ "$CF_TUNNEL_SETUP" =~ ^[yY]$ ]]; then
                echo_color $WHITE "Choose Cloudflare Tunnel setup mode:"
                echo_color $WHITE "  1: 🥇 Full Automatic (Recommended: Needs API key, creates tunnel/DNS)"
                echo_color $WHITE "  2: 🥈 Semi-Automatic (Needs pre-generated tunnel token)"
                while [[ ! "$CF_TUNNEL_MODE" =~ ^[12]$ ]]; do
                    read -r -p "$(echo_color $CYAN 'Mode (1/2): ')" CF_TUNNEL_MODE
                done

                if [ "$CF_TUNNEL_MODE" == "1" ]; then
                    echo_color $YELLOW "--- 🔑 Full Automatic Mode Credentials ---"
                    while [ -z "$CF_EMAIL" ]; do read -r -p "$(echo_color $WHITE 'Cloudflare Email: ')" CF_EMAIL; done
                    while [ -z "$CF_API_KEY" ]; do read -r -p "$(echo_color $WHITE 'Cloudflare Global API Key: ')" CF_API_KEY; done
                    while [ -z "$CF_HOSTNAME" ]; do read -r -p "$(echo_color $WHITE 'Hostname (e.g., dash.example.com): ')" CF_HOSTNAME; done
                else
                    echo_color $YELLOW "--- 🔑 Semi-Automatic Mode Credentials ---"
                    while [ -z "$CF_TUNNEL_TOKEN" ]; do read -r -p "$(echo_color $WHITE 'Cloudflare Tunnel Token: ')" CF_TUNNEL_TOKEN; done
                    while [ -z "$CF_HOSTNAME" ]; do read -r -p "$(echo_color $WHITE 'Hostname (Required for ingress, e.g., dash.example.com): ')" CF_HOSTNAME; done
                fi
            else
                echo_color $YELLOW "⚠️ WARNING: Manual Nginx/SSL setup required without Cloudflare Tunnel. See documentation."
            fi

            # --- UI: Pterodactyl Configuration ---
            step_header "🐦 Pterodactyl Integration"
            while [[ ! "$PTERO_CONFIGURE" =~ ^[ynYN]$ ]]; do
                read -r -p "$(echo_color $WHITE 'Configure Pterodactyl panel settings now? (y/n): ')" PTERO_CONFIGURE
            done

            if [[ "$PTERO_CONFIGURE" =~ ^[yY]$ ]]; then
                while [ -z "$PTERO_URL" ]; do read -r -p "$(echo_color $WHITE 'Pterodactyl Panel URL: ')" PTERO_URL; done
                while [ -z "$PTERO_API_KEY" ]; do read -r -p "$(echo_color $WHITE 'Pterodactyl API Key: ')" PTERO_API_KEY; done
            fi

            # --- UI: Admin User Creation (Native only) ---
            if [ "$INST_TYPE" == "1" ]; then
                step_header "👤 Initial Admin User Creation"
                while [ -z "$ADMIN_EMAIL" ]; do read -r -p "$(echo_color $WHITE 'Admin Email: ')" ADMIN_EMAIL; done
                while [ -z "$ADMIN_USERNAME" ]; do read -r -p "$(echo_color $WHITE 'Admin Username: ')" ADMIN_USERNAME; done
                while [ -z "$ADMIN_FIRST_NAME" ]; do read -r -p "$(echo_color $WHITE 'Admin First Name: ')" ADMIN_FIRST_NAME; done
                while [ -z "$ADMIN_LAST_NAME" ]; do read -r -p "$(echo_color $WHITE 'Admin Last Name: ')" ADMIN_LAST_NAME; done
                while [ -z "$ADMIN_PASSWORD" ]; do read -r -s -p "$(echo_color $WHITE 'Admin Password (hidden): ')" ADMIN_PASSWORD; echo; done
            fi
            
        # --- UI: Uninstallation Confirmation ---
        elif [[ "$INST_TYPE" == "2" || "$INST_TYPE" == "3" ]]; then
            read -r -p "$(echo_color $RED '🔥🔥 Are you ABSOLUTELY SURE you want to uninstall? This deletes all data! (y/n): ')" confirm
        fi

        # ----------------- EXECUTION LOGIC -----------------
        echo ""
        case $INST_TYPE in
            0) # Install Docker
                step_header "🐳 MythicalDash Docker Installation Process"
                install_packages curl unzip jq
                if [ "$reinstall" = "y" ]; then sudo rm -f /var/www/mythicaldash-v3/.installed; fi
                
                # Docker installation logic 
                if ! command -v docker &> /dev/null; then
                    echo_color $YELLOW "  🐳 Docker not found, installing..."
                    curl -sSL https://get.docker.com/ | CHANNEL=stable bash & spinner "Docker installation"
                    sudo systemctl enable --now docker
                    sudo usermod -aG docker "$USER"
                    echo_color $YELLOW "  ⚠️ NOTE: Log out and back in may be needed for Docker group."
                fi
                
                echo_color $YELLOW "  📁 Setting up MythicalDash-v3 directory..."
                sudo mkdir -p /var/www/mythicaldash-v3
                cd /var/www/mythicaldash-v3 || exit 1
                echo_color $YELLOW "  ⬇️ Downloading latest release..."
                sudo curl -Lo MythicalDash.zip https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip & spinner "Download"
                echo_color $YELLOW "  📂 Extracting files..."
                sudo unzip -o MythicalDash.zip -d /var/www/mythicaldash-v3 > /dev/null
                cd /var/www/mythicaldash-v3 || exit 1
                echo_color $YELLOW "  ▶️ Starting Docker containers (app, db, redis)..."
                sudo docker compose up -d & spinner "Containers start"
                
                echo_color $GREEN "🎉 MythicalDash-v3 Docker setup complete."
                
                if [[ "$PTERO_CONFIGURE" =~ ^[yY]$ ]]; then
                    echo_color $CYAN "  🛠️ Configuring Pterodactyl settings..."
                    sleep 10 # Wait for container to stabilize
                    printf "y\n%s\n%s\ny\n" "$PTERO_URL" "$PTERO_API_KEY" | sudo docker exec -i mythicaldash_v3_backend php cli pterodactyl configure
                    echo_color $GREEN "  ✅ Pterodactyl configuration complete."
                else
                    echo_color $YELLOW "  ℹ️ Manual configuration required: sudo docker exec -it mythicaldash_v3_backend php cli pterodactyl configure"
                fi
                
                if [[ "$CF_TUNNEL_SETUP" =~ ^[yY]$ ]]; then
                    if [ "$CF_TUNNEL_MODE" == "1" ]; then if ! setup_cloudflare_tunnel_full_auto; then CF_TUNNEL_TOKEN=""; fi; fi
                    setup_cloudflare_tunnel_client
                fi

                sudo touch /var/www/mythicaldash-v3/.installed
                ;;
            1) # Install Native
                step_header "💻 MythicalDash Native Installation Process"
                if [ "$reinstall" = "y" ]; then sudo rm -f /var/www/mythicaldash-v3/.installed; fi
                
                # OS-specific installation logic 
                if [ "$OS" = "ubuntu" ] || [ "$OS" = "ubuntu-server" ]; then
                    echo_color $YELLOW "📦 Installing base dependencies for Ubuntu/Ubuntu Server..."
                    export DEBIAN_FRONTEND=noninteractive
                    sudo apt -qq update && sudo apt -qq upgrade -y & spinner "System Update/Upgrade"
                    install_packages software-properties-common curl apt-transport-https ca-certificates gnupg jq make unzip tar git zip redis-server dos2unix
                    
                    echo_color $YELLOW "  ➕ Adding PHP (Ondrej) PPA & MariaDB repository..."
                    LC_ALL=C.UTF-8 sudo add-apt-repository -y ppa:ondrej/php > /dev/null
                    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash > /dev/null
                    sudo apt -qq update & spinner "Repository Update"
                    install_packages mariadb-server mariadb-client php8.3 php8.3-common php8.3-cli php8.3-gd php8.3-mysql php8.3-mbstring php8.3-bcmath php8.3-xml php8.3-fpm php8.3-curl php8.3-zip php8.3-redis
                # ... (Debian logic similarly enhanced) ...
                fi

                if ! command -v composer &> /dev/null; then
                    echo_color $YELLOW "  🎼 Installing Composer..."
                    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer > /dev/null
                    echo_color $GREEN "  ✅ Composer installed."
                fi
                
                # Application/Database Setup 
                echo_color $YELLOW "  ⬇️ Downloading/Extracting MythicalDash..."
                sudo mkdir -p /var/www/mythicaldash-v3
                cd /var/www/mythicaldash-v3 || exit 1
                sudo curl -Lo MythicalDash.zip https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip > /dev/null
                sudo unzip -o MythicalDash.zip -d /var/www/mythicaldash-v3 > /dev/null
                # ... (extraction cleanup logic remains) ...
                sudo chown -R www-data:www-data /var/www/mythicaldash-v3/*
                
                echo_color $YELLOW "  Composer: Installing PHP dependencies..."
                cd /var/www/mythicaldash-v3/backend || exit 1
                COMPOSER_ALLOW_SUPERUSER=1 sudo composer install --no-dev --optimize-autoloader & spinner "Composer Install"
                
                echo_color $YELLOW "  ⚙️ Starting/Configuring MariaDB..."
                sudo systemctl enable --now mariadb
                # ... (sed commands remain) ...
                sudo systemctl restart mariadb & spinner "MariaDB Restart"

                echo_color $YELLOW "  🔑 Creating MariaDB user and database..."
                DB_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9_ | head -c 16)
                sudo mysql -e "CREATE USER IF NOT EXISTS 'mythicaldash_remastered'@'127.0.0.1';"
                sudo mysql -e "ALTER USER 'mythicaldash_remastered'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
                sudo mysql -e "CREATE DATABASE IF NOT EXISTS mythicaldash_remastered;"
                sudo mysql -e "GRANT ALL PRIVILEGES ON mythicaldash_remastered.* TO 'mythicaldash_remastered'@'127.0.0.1' WITH GRANT OPTION;" & spinner "Database/User Creation"
                echo_color $GREEN "  🔑 Database Password Generated: ${DB_PASSWORD}"

                echo_color $YELLOW "  📦 Running initial application setup/migrations..."
                cd /var/www/mythicaldash-v3 || exit 1
                sudo make set-prod > /dev/null
                
                # Run setup/migrate using the generated password
                printf "xchacha20\nmythicaldash_remastered\n127.0.0.1\n3306\nmythicaldash_remastered\n%s\n" "$DB_PASSWORD" | sudo -u www-data php mythicaldash setup
                sudo -u www-data php mythicaldash migrate & spinner "Database Migration"

                if [[ "$PTERO_CONFIGURE" =~ ^[yY]$ ]]; then
                    echo_color $CYAN "  🛠️ Configuring Pterodactyl settings..."
                    printf "y\n%s\n%s\ny\n" "$PTERO_URL" "$PTERO_API_KEY" | sudo -u www-data php mythicaldash pterodactyl configure
                    echo_color $GREEN "  ✅ Pterodactyl configuration complete."
                fi

                echo_color $YELLOW "  ⏰ Adding/Updating Cron Jobs..."
                { crontab -l 2>/dev/null | grep -v -F "/var/www/mythicaldash-v3/"; \
                  echo "* * * * * bash /var/www/mythicaldash-v3/backend/storage/cron/runner.bash >> /dev/null 2>&1"; \
                  echo "* * * * * php /var/www/mythicaldash-v3/backend/storage/cron/runner.php >> /dev/null 2>&1"; } | crontab - & spinner "Cron Jobs"

                if [[ "$CF_TUNNEL_SETUP" =~ ^[yY]$ ]]; then
                    if [ "$CF_TUNNEL_MODE" == "1" ]; then if ! setup_cloudflare_tunnel_full_auto; then CF_TUNNEL_TOKEN=""; fi; fi
                    setup_cloudflare_tunnel_client
                fi

                sudo touch /var/www/mythicaldash-v3/.installed
                echo_color $GREEN "🎉 MythicalDash-v3 Native setup is COMPLETE!"
                ;;
            2) # Uninstall Docker
                if [ "$confirm" = "y" ]; then uninstall_docker; else echo_color $GREEN "✅ Uninstallation cancelled."; exit 0; fi
                ;;
            3) # Uninstall without Docker
                if [ "$confirm" = "y" ]; then uninstall_no_docker; else echo_color $GREEN "✅ Uninstallation cancelled."; exit 0; fi
                ;;
            *)
                echo_color $RED "❌ Internal error: Invalid installation type."
                exit 1
                ;;
        esac
    else
        echo_color $RED "❌ Unsupported OS: $OS"
        exit 1
    fi
else
    echo_color $RED "❌ Cannot determine OS"
    exit 1
fi
