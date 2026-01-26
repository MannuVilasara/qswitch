#!/usr/bin/env bash

set -e 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

select_flavors() {
    echo "Select flavors to install (enter numbers separated by space, or 'none' to skip):"
    echo "1. caelestia (Caelestia Shell)"
    echo "2. noctalia (Noctalia Shell)"
    echo "3. dms-shell (DMS)"
    echo "4. ii (Illogical Impulse)"
    echo "5. Xenon"
    read -p "Enter numbers: " choices

    install_caelestia=false
    install_noctalia=false
    install_dms_shell=false
    install_ii=false
    install_xenon=false

    if [[ "$choices" != "none" ]]; then
        for num in $choices; do
            case $num in
                1) install_caelestia=true ;;
                2) install_noctalia=true ;;
                3) install_dms_shell=true ;;
                4) install_ii=true ;;
                5) install_xenon=true ;;
                *) print_warning "Invalid option: $num" ;;
            esac
        done
    fi
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

print_info "Checking required commands..."
check_command git
check_command cmake
check_command make
check_command sudo

REPO_URL="https://github.com/MannuVilasara/qswitch.git"
DIR_NAME="qswitch"

if [ -f "main.go" ] && [ -f "CMakeLists.txt" ]; then
    print_info "Already in qswitch directory, skipping clone."
else
    if [ ! -d "$DIR_NAME" ]; then
        print_info "Cloning qswitch repository..."
        git clone "$REPO_URL"
    else
        print_warning "Directory '$DIR_NAME' already exists, skipping clone."
    fi
    cd "$DIR_NAME"
fi

print_info "Setting up build directory..."
mkdir -p build
cd build

print_info "Building qswitch..."
cmake ..
make

print_info "Installing qswitch..."
sudo make install

print_info "Running qswitch exp-setup..."
qswitch exp-setup

print_success "qswitch installed successfully."

if ! command -v yay &>/dev/null; then
    print_warning "yay not found. Installing yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

QSHELL_DIR="/etc/xdg/quickshell"
NOCTALIA_REPO="https://github.com/noctalia-dev/noctalia-shell"
NOCTALIA_DIR="$QSHELL_DIR/noctalia-shell"
XENON_DIR="$QSHELL_DIR/xenon"
XENON_REPO="https://github.com/MannuVilasara/xenon-shell"
QS_CONFIG_DIR="$HOME/.config/qswitch"
EXAMPLE_DIR="$(pwd)/..//example"

echo

select_flavors

if $install_caelestia; then
    print_info "Installing Caelestia Shell..."
    yay -S --needed caelestia-shell
    print_success "Caelestia Shell installed."
fi

if $install_noctalia; then
    print_info "Installing Noctalia Shell..."
    sudo mkdir -p "$QSHELL_DIR"
    if [ ! -d "$NOCTALIA_DIR" ]; then
        sudo git clone "$NOCTALIA_REPO" "$NOCTALIA_DIR"
        print_success "Noctalia Shell cloned."
    else
        print_warning "Noctalia Shell already exists, skipping."
    fi
fi

if $install_xenon; then
    print_info "Installing Xenon Shell..."
    sudo mkdir -p "$QSHELL_DIR"
    if [ ! -d "$XENON_DIR" ]; then
        sudo git clone "$XENON_REPO" "$XENON_DIR"
        print_success "XENON Shell cloned."
    else
        print_warning "XENON Shell already exists, skipping."
    fi
fi

if $install_dms_shell; then
    print_info "Installing DMS..."
    yay -S --needed dms-shell
    print_success "DMS installed."
fi

if $install_ii; then
    print_info "Installing Illogical Impulse..."
    bash <(curl -s https://ii.clsty.link/get)
    print_success "Illogical Impulse installed."
fi

echo
print_success "Selected flavours installed successfully."

echo
read -rp "Apply example config to ~/.config/qswitch? (y/n): " APPLY_CFG

if [[ "$APPLY_CFG" =~ ^[Yy]$ ]]; then
    if [ ! -d "$EXAMPLE_DIR" ]; then
        print_error "example directory not found: $EXAMPLE_DIR"
        exit 1
    fi
    print_info "Applying example config..."
    mkdir -p "$QS_CONFIG_DIR"
    cp -rf "$EXAMPLE_DIR/"* "$QS_CONFIG_DIR/"
    print_success "Example config applied to $QS_CONFIG_DIR"
else
    print_info "Skipping example config."
fi

echo
print_success "🎉 Installation complete."