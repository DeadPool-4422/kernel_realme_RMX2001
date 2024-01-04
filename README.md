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

# Kernel Compilation for Droidian

For detailed instructions on compiling this kernel, please refer to the [Droidian Porting Guide](https://github.com/droidian/porting-guide/blob/master/kernel-compilation.md).

## Compilation Process
After following the guide, you will find the compiled `boot.img` in the following directory:
```
out/KERNEL_OBJ/
```
This is generated after executing `RELENG_HOST_ARCH="arm64" releng-build-package` within the Docker container.

## Helper Scripts and Assets
This repository also includes a `helper` directory. It contains scripts and assets for post-installation tasks on Droidian. Currently, it features a script that configures the power button for proper functionality and turning on the screen when the power button is pressed.

---

### Notes:
- Make sure to have a great day ahead!

---
