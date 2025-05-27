#!/bin/bash
# install-zoom.sh - Best practices script for installing Zoom during BlueBuild
# Place this file at: files/scripts/install-zoom.sh

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
readonly ZOOM_URL="https://zoom.us/client/latest/zoom_x86_64.rpm"
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_PREFIX="[${SCRIPT_NAME}]"

# Logging functions
log_info() {
    echo "${LOG_PREFIX} INFO: $*" >&2
}

log_error() {
    echo "${LOG_PREFIX} ERROR: $*" >&2
}

log_warning() {
    echo "${LOG_PREFIX} WARNING: $*" >&2
}

# Check if we're running as root (required for rpm-ostree)
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Verify network connectivity
check_network() {
    log_info "Checking network connectivity..."
    
    if ! curl -s --connect-timeout 10 --max-time 30 --head "$ZOOM_URL" >/dev/null 2>&1; then
        log_error "Cannot reach Zoom download URL: $ZOOM_URL"
        log_error "Check your internet connection or try again later"
        exit 1
    fi
    
    log_info "✓ Network connectivity verified"
}

# Verify rpm-ostree is available
check_rpm_ostree() {
    if ! command -v rpm-ostree >/dev/null 2>&1; then
        log_error "rpm-ostree command not found"
        log_error "This script is designed for rpm-ostree based systems"
        exit 1
    fi
    
    log_info "✓ rpm-ostree is available"
}

# Check if Zoom is already installed
check_existing_zoom() {
    if rpm -q zoom >/dev/null 2>&1; then
        local current_version
        current_version=$(rpm -q zoom --queryformat '%{VERSION}-%{RELEASE}')
        log_warning "Zoom is already installed (version: $current_version)"
        log_info "Proceeding with installation to ensure latest version..."
    fi
}

# Install Zoom using rpm-ostree
install_zoom() {
    log_info "Installing Zoom from: $ZOOM_URL"
    
    # Use --idempotent to avoid errors if already installed
    # Use --allow-inactive to work during image builds
    if rpm-ostree install --idempotent --allow-inactive "$ZOOM_URL"; then
        log_info "✓ Zoom installation completed successfully"
    else
        local exit_code=$?
        log_error "Failed to install Zoom (exit code: $exit_code)"
        exit $exit_code
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying Zoom installation..."
    
    # Check if the package is now available in the rpm database
    if rpm -q zoom >/dev/null 2>&1; then
        local installed_version
        installed_version=$(rpm -q zoom --queryformat '%{VERSION}-%{RELEASE}')
        log_info "✓ Zoom successfully installed (version: $installed_version)"
    else
        log_warning "Zoom package not found in rpm database"
        log_info "This may be normal during image build - package will be available after deployment"
    fi
}

# Main installation function
main() {
    log_info "Starting Zoom installation process..."
    
    # Pre-flight checks
    check_root
    check_rpm_ostree
    check_network
    
    # Installation process
    check_existing_zoom
    install_zoom
    verify_installation
    
    log_info "Zoom installation process completed successfully"
}

# Trap to handle script interruption
trap 'log_error "Script interrupted"; exit 130' INT TERM

# Run main function
main "$@"
