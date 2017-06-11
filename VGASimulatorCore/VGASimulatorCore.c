//
//  VGASimulatorCore.c
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#include "VGASimulatorCore.h"

int VGAResolutionWidth = 1280;
int VGAResolutionHeight = 1024;
int VGABackPorchX = 318;
int VGABackPorchY = 38;

FILE* _Nullable VGAOpenFile(const char * path) {
    FILE *file = fopen(path, "r");
    printf("0x0000000000000000 %p - Frame Opening %s\n", file, file->_p);
    
    if (file == NULL) {
        return NULL;
    }

    return file;
}

int VGACloseFile(FILE* file) {
    if (file != NULL) {
        fclose(file);
        printf("0x0000000000000000 %p - Frame Closing\n", file);
    }

    file = NULL;
    return 0;
}

int VGAGetNextLine(FILE *file, char **line) {

    if (file == NULL) {
        return -1;
    }

    size_t len = 0;
    ssize_t readlen;

    if ((readlen = getline(line, &len, file)) < 0) {
        return -1;
    }

    return 0;
}

int VGAGetNextOutput(FILE *file, VGAOutput *vgaOuput) {

    char * line = NULL;

    if (VGAGetNextLine(file, &line) < 0) {
        return -1;
    }

    int index = 0;
    char *pch;
    pch = strtok(line, " ");

    while (pch != NULL) {
        switch (index) {
            case 2:
                vgaOuput->hSync = strcmp(pch, "1") == 0;
                break;
            case 3:
                vgaOuput->vSync = strcmp(pch, "1") == 0;
                break;
            case 4:
                vgaOuput->red = (uint32_t)strtol(pch, NULL, 2) << 4;
                break;
            case 5:
                vgaOuput->green = (uint32_t)strtol(pch, NULL, 2) << 4;
                break;
            case 6:
                vgaOuput->blue = (uint32_t)strtol(pch, NULL, 2) << 4;
                break;
        }

        pch = strtok(NULL, " ");
        index++;
    }

    return 0;
}

int VGAGetNextFrame(FILE *file, uint32_t *frameBuffer) {

    static int backPorchXCounter = 0;
    static int backPorchYCounter = 0;

    static int hCounter = 0;
    static int vCounter = 0;

    VGAOutput lastOutput;
    VGAOutput nextOutput;

    static int frameCounter = 0;

    bool showFrame = false;

    if (file == NULL) {
        return -1;
    }

    while (VGAGetNextOutput(file, &nextOutput) >= 0) {

        if (!lastOutput.hSync && nextOutput.hSync) {
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

        if (nextOutput.vSync && nextOutput.hSync) {
            // Increment this so we know how far we are
            // After the hsync pulse
            backPorchXCounter += 1;

            // If we are past the back porch
            // Then we can start drawing on the canvas
            if ((backPorchXCounter >= VGABackPorchX) && (backPorchYCounter >= VGABackPorchY)) {

                // Add pixel
                if (hCounter < VGAResolutionWidth && vCounter < VGAResolutionHeight) {
                    frameBuffer[VGAResolutionWidth * vCounter + hCounter] = (nextOutput.blue << 24) + (nextOutput.green << 16) + (nextOutput.red << 8);
                }

                if (backPorchXCounter >= VGABackPorchX) {
                    hCounter += 1;
                }
            }
        }

        if (!lastOutput.vSync && nextOutput.vSync) {

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

        lastOutput = nextOutput;

        if (showFrame) {
            return frameCounter - 1;
        }
    }

    VGACloseFile(file);

    frameCounter = 0;
    return 0;
}
