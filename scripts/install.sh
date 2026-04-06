#!/bin/bash
set -e

# Configuration
INSTALL_DIR="${HOME}/.local/bin"
GITHUB_REPO="primal-lang/sdk"
BINARY_NAME="primal"
PATH_WAS_MODIFIED=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

print_info() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

error_exit() {
    print_error "$1"
    exit 1
}

show_help() {
    cat << EOF
Primal SDK Installer

Usage: install.sh [OPTIONS]

Options:
    --help                  Show this help message
    --version <version>     Install a specific version (e.g., 0.4.3)
    --install-dir <path>    Override default install location (~/.local/bin)
    --uninstall             Remove primal binary and PATH entry

Examples:
    install.sh                      Install latest version
    install.sh --version 0.4.3      Install specific version
    install.sh --uninstall          Uninstall primal

EOF
    exit 0
}

# ============================================================================
# Platform Detection
# ============================================================================

detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) error_exit "Unsupported operating system: $(uname -s)" ;;
    esac
}

detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) echo "x86-64" ;;
        *) error_exit "Unsupported architecture: $arch. Only x86-64 is currently supported." ;;
    esac
}

# ============================================================================
# Download Utilities
# ============================================================================

has_command() {
    command -v "$1" >/dev/null 2>&1
}

download_file() {
    local url="$1"
    local output="$2"

    if has_command curl; then
        curl -fsSL "$url" -o "$output"
    elif has_command wget; then
        wget -q "$url" -O "$output"
    else
        error_exit "Neither curl nor wget found. Please install one of them."
    fi
}

fetch_url() {
    local url="$1"

    if has_command curl; then
        curl -fsSL "$url"
    elif has_command wget; then
        wget -qO- "$url"
    else
        error_exit "Neither curl nor wget found. Please install one of them."
    fi
}

# ============================================================================
# Version Management
# ============================================================================

get_latest_version() {
    local api_url="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
    local response
    local version

    response=$(fetch_url "$api_url") || error_exit "Failed to fetch latest release information from GitHub"

    # Extract tag_name from JSON response using jq if available, otherwise fall back to grep/sed
    if has_command jq; then
        version=$(echo "$response" | jq -r '.tag_name' | sed 's/^v//')
    else
        # Fallback: extract tag_name using grep/sed (handles both with and without 'v' prefix)
        version=$(echo "$response" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\?\([^"]*\)".*/\1/')
    fi

    echo "$version"
}

get_installed_version() {
    if [[ -x "${INSTALL_DIR}/${BINARY_NAME}" ]]; then
        "${INSTALL_DIR}/${BINARY_NAME}" --version 2>/dev/null | head -1 || echo ""
    else
        echo ""
    fi
}

# ============================================================================
# PATH Management
# ============================================================================

path_contains_install_dir() {
    echo "$PATH" | tr ':' '\n' | grep -q "^${INSTALL_DIR}$"
}

get_shell_config_file() {
    local shell_name
    shell_name="$(basename "$SHELL")"

    case "$shell_name" in
        bash)
            if [[ -f "${HOME}/.bashrc" ]]; then
                echo "${HOME}/.bashrc"
            elif [[ -f "${HOME}/.bash_profile" ]]; then
                echo "${HOME}/.bash_profile"
            else
                echo "${HOME}/.bashrc"
            fi
            ;;
        zsh)
            echo "${HOME}/.zshrc"
            ;;
        fish)
            echo "${HOME}/.config/fish/config.fish"
            ;;
        *)
            echo "${HOME}/.profile"
            ;;
    esac
}

add_to_path() {
    local config_file
    config_file="$(get_shell_config_file)"
    local shell_name
    shell_name="$(basename "$SHELL")"
    local path_export_line
    local fish_export_line

    # Define the exact lines we add
    path_export_line="export PATH=\"${INSTALL_DIR}:\$PATH\""
    fish_export_line="set -gx PATH \"${INSTALL_DIR}\" \$PATH"

    # Check if our exact PATH entry already exists in config file
    if [[ -f "$config_file" ]]; then
        if grep -qF "$path_export_line" "$config_file" 2>/dev/null || \
           grep -qF "$fish_export_line" "$config_file" 2>/dev/null; then
            return 0
        fi
    fi

    # Create config file directory if needed (for fish)
    mkdir -p "$(dirname "$config_file")"

    # Add PATH entry based on shell type
    echo "" >> "$config_file"
    echo "# Added by Primal SDK installer" >> "$config_file"

    if [[ "$shell_name" == "fish" ]]; then
        echo "$fish_export_line" >> "$config_file"
    else
        echo "$path_export_line" >> "$config_file"
    fi

    print_info "Added ${INSTALL_DIR} to PATH in ${config_file}"
    PATH_WAS_MODIFIED=true
}

remove_from_path() {
    local config_file
    config_file="$(get_shell_config_file)"

    if [[ -f "$config_file" ]]; then
        # Create a temporary file
        local temp_file
        temp_file=$(mktemp)

        # Remove the Primal PATH entries (using fixed string matching for exactness)
        grep -vF "# Added by Primal SDK installer" "$config_file" | \
        grep -vF "export PATH=\"${INSTALL_DIR}:\$PATH\"" | \
        grep -vF "set -gx PATH \"${INSTALL_DIR}\" \$PATH" > "$temp_file" || true

        mv "$temp_file" "$config_file"

        print_info "Removed PATH entry from ${config_file}"
    fi
}

# ============================================================================
# Installation Functions
# ============================================================================

install_binary() {
    local version="$1"
    local os
    local arch
    local binary_suffix=""
    local download_url
    local temp_file

    os=$(detect_os)
    arch=$(detect_arch)

    if [[ "$os" == "windows" ]]; then
        binary_suffix=".exe"
    fi

    download_url="https://github.com/${GITHUB_REPO}/raw/refs/tags/v${version}/bin/${BINARY_NAME}-${os}-${arch}${binary_suffix}"

    print_info "Downloading primal v${version} for ${os}-${arch}..."

    # Create temp file
    temp_file=$(mktemp)

    # Download binary
    if ! download_file "$download_url" "$temp_file"; then
        rm -f "$temp_file"
        error_exit "Failed to download from ${download_url}"
    fi

    # Create install directory if it doesn't exist
    mkdir -p "${INSTALL_DIR}"

    # Move binary to install location
    mv "$temp_file" "${INSTALL_DIR}/${BINARY_NAME}${binary_suffix}"

    # Set executable permission
    chmod +x "${INSTALL_DIR}/${BINARY_NAME}${binary_suffix}"
}

verify_installation() {
    if [[ -x "${INSTALL_DIR}/${BINARY_NAME}" ]]; then
        local installed_version
        installed_version=$("${INSTALL_DIR}/${BINARY_NAME}" --version 2>/dev/null | head -1) || true
        if [[ -n "$installed_version" ]]; then
            return 0
        fi
    fi
    return 1
}

# ============================================================================
# Uninstall Function
# ============================================================================

uninstall() {
    print_info "Uninstalling Primal SDK..."

    local binary_path="${INSTALL_DIR}/${BINARY_NAME}"

    if [[ -f "$binary_path" ]]; then
        rm -f "$binary_path"
        print_success "Removed ${binary_path}"
    else
        print_warning "Binary not found at ${binary_path}"
    fi

    remove_from_path

    print_success "Primal SDK has been uninstalled."
    print_info "Please restart your shell or source your shell config file."

    exit 0
}

# ============================================================================
# Main Script
# ============================================================================

main() {
    local target_version=""
    local do_uninstall=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                show_help
                ;;
            --version)
                if [[ -z "$2" || "$2" == --* ]]; then
                    error_exit "--version requires a version number (e.g., --version 0.4.3)"
                fi
                target_version="$2"
                shift 2
                ;;
            --install-dir)
                if [[ -z "$2" || "$2" == --* ]]; then
                    error_exit "--install-dir requires a path"
                fi
                INSTALL_DIR="$2"
                shift 2
                ;;
            --uninstall)
                do_uninstall=true
                shift
                ;;
            *)
                error_exit "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done

    # Handle uninstall
    if [[ "$do_uninstall" == true ]]; then
        uninstall
    fi

    # Check for existing installation
    print_info "Checking for existing installation..."
    local installed_version
    installed_version=$(get_installed_version)

    if [[ -n "$installed_version" ]]; then
        print_info "Found primal ${installed_version} installed"
    fi

    # Determine target version
    if [[ -z "$target_version" ]]; then
        print_info "Fetching latest version..."
        target_version=$(get_latest_version)
        if [[ -z "$target_version" ]]; then
            error_exit "Failed to determine latest version"
        fi
    fi

    print_info "Target version: ${target_version}"

    # Check if already up to date
    if [[ "$installed_version" == "$target_version" ]]; then
        print_success "Already up to date (v${target_version})"
        exit 0
    fi

    # Install or update
    if [[ -n "$installed_version" ]]; then
        print_info "Updating primal from ${installed_version} to ${target_version}..."
    else
        print_info "Installing primal v${target_version}..."
    fi

    install_binary "$target_version"

    # Update PATH if needed (only on fresh install)
    if [[ -z "$installed_version" ]]; then
        if ! path_contains_install_dir; then
            add_to_path
        fi
    fi

    # Verify installation
    if verify_installation; then
        echo ""
        if [[ -n "$installed_version" ]]; then
            print_success "Successfully updated primal from ${installed_version} to ${target_version}!"
        else
            print_success "Successfully installed primal v${target_version}!"
        fi
        echo ""
        print_info "Installation directory: ${INSTALL_DIR}"

        if [[ "$PATH_WAS_MODIFIED" == true ]]; then
            echo ""
            print_warning "Please restart your shell or run:"
            echo "  source $(get_shell_config_file)"
        fi

        echo ""
        print_info "Run 'primal --version' to verify the installation."
    else
        error_exit "Installation verification failed. Please check the installation manually."
    fi
}

main "$@"
