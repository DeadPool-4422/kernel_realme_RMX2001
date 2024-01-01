#!/bin/bash

# Function to compile the kernel
compile() {
    # Exit immediately if a command exits with a non-zero status.
    set -e

    # Define the necessary directories
    CLANG_DIR="$(pwd)/clang"
    GCC_DIR="$(pwd)/aarch64-linux-android-4.9"

    # Check and remove existing directories if they exist
    [ -d "$CLANG_DIR" ] && echo "Removing $CLANG_DIR" && rm -rf "$CLANG_DIR"
    [ -d "$GCC_DIR" ] && echo "Removing $GCC_DIR" && rm -rf "$GCC_DIR"

    # Clone the necessary repositories
    git clone --depth 1 https://github.com/GrowtopiaJaw/aarch64-linux-android-4.9.git -b google --single-branch "$GCC_DIR"
    git clone --depth 1 https://github.com/AlpacaGang/clang.git "$CLANG_DIR"

    # Set the environment variables
    export ARCH=arm64
    export CROSS_COMPILE="$GCC_DIR/bin/aarch64-linux-android-"
    export CC="$CLANG_DIR/bin/clang"
    export CLANG_TRIPLE=aarch64-linux-gnu-

    # Clear previous remnants if any
    make clean

    # Make the defconfig
    make O=out RMX2001_defconfig

    # Start the kernel build
    make O=out -j8

    echo "Kernel build is complete."
}

# Function to upload the kernel
zupload() {
    if [ -f "out/arch/arm64/boot/Image.gz-dtb" ]; then
        git clone --depth=1 https://github.com/sarthakroy2002/AnyKernel3.git -b RMX2001 AnyKernel
        cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
        cd AnyKernel
        zip_name="Generic-Kernel-$(date +%Y%m%d).zip"
        zip -r9 "$zip_name" *
        echo "Uploading $zip_name..."
        curl --upload-file "./$zip_name" https://free.keep.sh
    else
        echo "Kernel image does not exist, skipping upload."
    fi
}

# Run the compile and upload functions
compile
zupload
