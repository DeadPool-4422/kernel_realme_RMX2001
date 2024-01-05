Linux kernel
============

This file was moved to Documentation/admin-guide/README.rst

Please notice that there are several guides for kernel developers and users.
These guides can be rendered in a number of formats, like HTML and PDF.

In order to build the documentation, use ``make htmldocs`` or
``make pdfdocs``.

There are various text files in the Documentation/ subdirectory,
several of them using the Restructured Text markup notation.
See Documentation/00-INDEX for a list of what is contained in each file.

Please read the Documentation/process/changes.rst file, as it contains the
requirements for building and running the kernel, and information about
the problems which may result by upgrading your kernel.
---

# Kernel Compilation Guide for Droidian

This document provides instructions for compiling the kernel for Droidian. For comprehensive steps, please refer to the [Droidian Porting Guide](https://github.com/droidian/porting-guide/blob/master/kernel-compilation.md).

## Compilation Process
To compile the kernel, follow the steps in the guide. Upon completion, the `boot.img` file will be located in the `out/KERNEL_OBJ/` directory. This file is created after running `RELENG_HOST_ARCH="arm64" releng-build-package` within the Docker environment.

## Helper Scripts and Assets
The `helper` directory in this repository contains useful scripts and assets for post-installation on Droidian devices. A notable script included is for configuring the power button to turn on the screen when pressed which works most of the times.

### WiFi Setup Instructions:
- To enable WiFi, connect the Droidian device to a Linux system via USB.
- Use `dmesg` to determine the RNDIS IP address of the Droidian device.
- SSH into the device using the IP address (e.g., `ssh droidian@10.??.??.82`). Default password is `1234` 
- Execute `echo S | sudo tee /dev/wmtWifi` to activate WiFi.

### Reminder:
- Have a great day ahead!

---
