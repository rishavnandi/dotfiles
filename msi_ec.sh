#!/bin/bash
# Usage: ./build_kernel_module.sh [optional: kernel source URL]

# Exit on error, treat unset variables as errors, and propagate errors in pipelines
set -euo pipefail

# Define constants
readonly KERNEL_VERSION=$(uname -r)
readonly KERNEL_BASE="${KERNEL_VERSION%-*}"
readonly KERNEL_SRC="kernel-${KERNEL_BASE}.src.rpm"
readonly BUILD_PATH="$HOME/rpmbuild/BUILD/kernel-${KERNEL_BASE}-build/kernel-${KERNEL_BASE}/linux-${KERNEL_VERSION}"
readonly MACHINE_ARCH=$(uname -m)
readonly CONFIG_FILE="configs/kernel-${KERNEL_BASE}-${MACHINE_ARCH}.config"
readonly MAKEFILE="$BUILD_PATH/Makefile"
readonly MODULE_DIR="drivers/acpi"

# Initialize RPM build environment
rpmdev-setuptree

# Function to download kernel source
download_kernel_source() {
  local url=$1
  if [ -z "$url" ]; then
    echo "Downloading kernel source..."
    yumdownloader --source "kernel-${KERNEL_VERSION}"
  else
    echo "Downloading kernel source from URL: $url"
    wget "$url"
  fi
}

# Function to prepare kernel build environment
prepare_kernel_build() {
  echo "Installing build dependencies..."
  sudo yum-builddep -y "$KERNEL_SRC"
  rpm -Uvh "$KERNEL_SRC"
  cd "$HOME/rpmbuild/SPECS"
  rpmbuild -bp --target="$MACHINE_ARCH" kernel.spec
}

# Function to configure kernel build
configure_kernel_build() {
  echo "Configuring kernel build..."
  cd "$BUILD_PATH"
  local extraversion="${KERNEL_VERSION#${KERNEL_BASE}-}"
  sed -i "s/^EXTRAVERSION =.*/EXTRAVERSION = $extraversion/" "$MAKEFILE"
  cp "$CONFIG_FILE" .config
  echo "CONFIG_ACPI_EC_DEBUGFS=m" >> .config
  make modules_prepare
}

# Function to build and install kernel module
build_and_install_module() {
  echo "Building and installing kernel module..."
  export KBUILD_MODPOST_WARN=1
  make M="$MODULE_DIR" modules
  sudo make M="$MODULE_DIR" modules_install
  sudo depmod -a
}

# Main script execution
main() {
  local kernel_source_url=$1
  download_kernel_source "$kernel_source_url"
  prepare_kernel_build
  configure_kernel_build
  build_and_install_module
  echo "Kernel module build and installation completed successfully."
}

# Execute main function with provided arguments
main "$@"
