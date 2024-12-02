#!/bin/bash

# Check for GCC and install if not present
if ! command -v gcc &> /dev/null; then
    echo "GCC is not installed. Installing build-essential..."
    sudo apt update && sudo apt install build-essential
fi

# Define the C source code
cat <<'EOF' > button.c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <sys/time.h>

#define POWER_BUTTON_EVENT "/dev/input/event1"
#define POWER_KEYCODE KEY_POWER
#define DELAY_SECONDS 1
#define MAX_BRIGHTNESS 2047
#define BRIGHTNESS_FILE "/sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness"

int get_current_brightness() {
    FILE *brightness_file = fopen(BRIGHTNESS_FILE, "r");
    if (!brightness_file) {
        perror("Failed to open brightness file for reading");
        return -1;
    }

    int current_brightness;
    if (fscanf(brightness_file, "%d", &current_brightness) != 1) {
        perror("Failed to read current brightness value");
        fclose(brightness_file);
        return -1;
    }

    fclose(brightness_file);
    return current_brightness;
}

int set_brightness(int value) {
    if (value <= 0 || value > MAX_BRIGHTNESS) {
        fprintf(stderr, "Brightness value must be between 1 and %d\n", MAX_BRIGHTNESS);
        return -1;
    }

    FILE *brightness_file = fopen(BRIGHTNESS_FILE, "w");
    if (!brightness_file) {
        perror("Failed to open brightness file for writing");
        return -1;
    }

    fprintf(brightness_file, "%d\n", value);
    fclose(brightness_file);

    printf("Brightness set to %d\n", value);
    return 0;
}

int main() {
    int input_fd = open(POWER_BUTTON_EVENT, O_RDONLY);
    if (input_fd == -1) {
        perror("Failed to open power button event");
        return 1;
    }

    struct input_event ev;
    struct timeval last_press_time = {0, 0};
    struct timeval current_time;

    while (1) {
        if (read(input_fd, &ev, sizeof(ev)) == -1) {
            perror("Failed to read power button event");
            close(input_fd);
            return 1;
        }

        if (ev.type == EV_KEY && ev.value == 1) { // Key press event
            if (ev.code == POWER_KEYCODE) {
                gettimeofday(&current_time, NULL);
                double elapsed_time = (current_time.tv_sec - last_press_time.tv_sec) +
                                      (current_time.tv_usec - last_press_time.tv_usec) / 1000000.0;

                if (elapsed_time >= DELAY_SECONDS) {
                    int previous_brightness = get_current_brightness();
                    if (previous_brightness == -1) {
                        continue;
                    }

                    // Set maximum brightness
                    if (set_brightness(MAX_BRIGHTNESS) == 0) {
                        sleep(2); // Delay for visibility
                        // Revert to previous brightness
                        set_brightness(previous_brightness);
                    }
                }

                last_press_time = current_time;
            }
        }
    }

    close(input_fd);
    return 0;
}
EOF

# Compile the program
gcc -o button button.c

# Check if compilation was successful
if [ ! -f button ]; then
    echo "Compilation failed."
    exit 1
fi

# Copy the compiled program to /usr/bin
sudo cp button /usr/bin/

# Create a systemd service
sudo bash -c 'echo -e "[Unit]\nDescription=Button Service\nAfter=multi-user.target\n\n[Service]\nType=simple\nUser=root\nExecStart=/usr/bin/button\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/button.service'

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable button.service
sudo systemctl start button.service

echo "Setup complete. The button service is now installed and running."
