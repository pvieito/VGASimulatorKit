//
//  VGASimulatorCore.c
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

int VGAResolutionWidth = 1280;
int VGAResolutionHeight = 1024;

int VGABackPorchX = 318;
int VGABackPorchY = 38;

static FILE * filePointer;

int VGAOpenFile(const char * path) {
    filePointer = fopen(path, "r");

    if (filePointer == NULL) {
        return -1;
    }

    return 0;
}

int VGACloseFile() {
    if (filePointer != NULL) {
        fclose(filePointer);
    }

    filePointer = NULL;
    return 0;
}

int VGAGetNextLine(char **line) {

    if (filePointer == NULL) {
        return -1;
    }

    static size_t len = 0;
    static ssize_t readlen;

    if ((readlen = getline(line, &len, filePointer)) < 0) {
        return -1;
    }

    return 0;
}

int VGAGetNextLineComponents(bool *hSync, bool *vSync, uint32_t *red, uint32_t *green, uint32_t *blue) {

    static char * line = NULL;

    if (VGAGetNextLine(&line) < 0) {
        return -1;
    }

    int index = 0;
    char *pch;
    pch = strtok(line, " ");

    while (pch != NULL) {
        switch (index) {
            case 2:
                *hSync = strcmp(pch, "1") == 0;
                break;
            case 3:
                *vSync = strcmp(pch, "1") == 0;
                break;
            case 4:
                *red = (uint32_t)strtol(pch, NULL, 2) << 4;
                break;
            case 5:
                *green = (uint32_t)strtol(pch, NULL, 2) << 4;
                break;
            case 6:
                *blue = (uint32_t)strtol(pch, NULL, 2) << 4;
                break;
        }

        pch = strtok(NULL, " ");
        index++;
    }

    return 0;
}

int VGAGetNextFrame(uint32_t *frameBuffer) {

    static int backPorchXCounter = 0;
    static int backPorchYCounter = 0;

    static int hCounter = 0;
    static int vCounter = 0;

    static bool lastHSync = false;
    static bool lastVSync = false;
    
    static int frameCounter = 0;

    bool showFrame = false;

    if (filePointer == NULL) {
        return -1;
    }

    bool hSync = false;
    bool vSync = false;

    uint32_t red = 0;
    uint32_t green = 0;
    uint32_t blue = 0;

    while (VGAGetNextLineComponents(&hSync, &vSync, &red, &green, &blue) >= 0) {

        if (!lastHSync && hSync) {
            // New horizontal line
            hCounter = 0;

            // Move to the next row, if past back porch
            if (backPorchYCounter >= VGABackPorchY) {
                vCounter += 1;
            }

            // Increment this so we know how far we are after the vsync pulse
            backPorchYCounter += 1;

            // Set this to zero so we can count up to the actual
            backPorchXCounter = 0;
        }

        if (vSync && hSync) {
            // Increment this so we know how far we are
            // After the hsync pulse
            backPorchXCounter += 1;

            // If we are past the back porch
            // Then we can start drawing on the canvas
            if ((backPorchXCounter >= VGABackPorchX) && (backPorchYCounter >= VGABackPorchY)) {

                // Add pixel
                if (hCounter < VGAResolutionWidth && vCounter < VGAResolutionHeight) {
                    frameBuffer[VGAResolutionWidth * vCounter + hCounter] = (blue << 24) + (green << 16) + (red << 8);
                }

                if (backPorchXCounter >= VGABackPorchX) {
                    hCounter += 1;
                }
            }
        }

        if (!lastVSync && vSync) {

            if (frameCounter > 0) {
                showFrame = true;
            }

            // New frame
            frameCounter += 1;
            hCounter = 0;
            vCounter = 0;

            // Set this to zero so we can count up to the actual
            backPorchYCounter = 0;
        }

        lastHSync = hSync;
        lastVSync = vSync;

        if (showFrame) {
            return frameCounter - 1;
        }
    }

    VGACloseFile();

    frameCounter = 0;
    return 0;
}
