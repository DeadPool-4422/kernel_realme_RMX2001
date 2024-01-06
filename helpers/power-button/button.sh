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
#include <time.h>  // Include this header for the time function

#define POWER_BUTTON_EVENT "/dev/input/event1"
#define POWER_KEYCODE KEY_POWER
#define DELAY_SECONDS 1

int main() {
    int input_fd = open(POWER_BUTTON_EVENT, O_RDONLY);
    if (input_fd == -1) {
        perror("Failed to open power button event");
        return 1;
    }

    struct input_event ev;
    int count = 0;
    struct timeval last_press_time;
    struct timeval current_time;

    srand(time(NULL)); // Seed the random number generator

    while (1) {
        if (read(input_fd, &ev, sizeof(ev)) == -1) {
            perror("Failed to read power button event");
            close(input_fd);
            return 1;
        }

        if (ev.type == EV_KEY && ev.value == 1) {  // Key press event
            if (ev.code == POWER_KEYCODE) {
                count++;
                if (count % 2 == 0) {  // Every 2nd press
                    gettimeofday(&current_time, NULL);
                    double elapsed_time = (current_time.tv_sec - last_press_time.tv_sec) +
                                          (current_time.tv_usec - last_press_time.tv_usec) / 1000000.0;

                    if (elapsed_time >= DELAY_SECONDS) {
                        // Generate a random brightness value between 30 and 35
                        int brightness = (rand() % 6) + 30; // rand() % 6 gives a number between 0-5, + 30 adjusts it to 30-35
                        char command[100];
                        sprintf(command, "echo '%d' > /sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness", brightness);
                        int ret = system(command);
                        if (ret == -1) {
                            perror("Failed to execute shell command");
                        } else {
                            printf("Brightness set to %d\n", brightness);
                        }
                    }
                }

                gettimeofday(&last_press_time, NULL);
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
