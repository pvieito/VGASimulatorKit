//
//  VGASimulatorCore.c
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#include "VGASimulatorCore.h"

const int VGAResolutionWidth = 1280;
const int VGAResolutionHeight = 1024;
const int VGABackPorchX = 318;
const int VGABackPorchY = 38;

FILE* _Nullable VGAOpenFile(const char * path) {
        
    FILE *file = fopen(path, "r");
    
    if (file == NULL) {
        return NULL;
    }

    return file;
}

int VGACloseFile(FILE* file) {
    
    if (file != NULL) {
        fclose(file);
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
    
    free(line);

    return 0;
}

int VGAGetNextFrame(VGASimulationState *simulationState, uint32_t *frameBuffer) {

    bool showFrame = false;

    if (simulationState->simulationFile == NULL) {
        return -1;
    }

    while (VGAGetNextOutput(simulationState->simulationFile, &simulationState->nextOutput) >= 0) {

        if (!simulationState->lastOutput.hSync && simulationState->nextOutput.hSync) {
            // New horizontal line
            simulationState->hCounter = 0;

            // Move to the next row, if past back porch
            if (simulationState->backPorchYCounter >= VGABackPorchY) {
                simulationState->vCounter += 1;
            }

            // Increment this so we know how far we are after the vsync pulse
            simulationState->backPorchYCounter += 1;

            // Set this to zero so we can count up to the actual
            simulationState->backPorchXCounter = 0;
        }

        if (simulationState->nextOutput.vSync && simulationState->nextOutput.hSync) {
            // Increment this so we know how far we are
            // After the hsync pulse
            simulationState->backPorchXCounter += 1;

            // If we are past the back porch
            // Then we can start drawing on the canvas
            if ((simulationState->backPorchXCounter >= VGABackPorchX) && (simulationState->backPorchYCounter >= VGABackPorchY)) {

                // Add pixel
                if (simulationState->hCounter < VGAResolutionWidth && simulationState->vCounter < VGAResolutionHeight) {
                    frameBuffer[VGAResolutionWidth * simulationState->vCounter + simulationState->hCounter] = (simulationState->nextOutput.blue << 24) + (simulationState->nextOutput.green << 16) + (simulationState->nextOutput.red << 8);
                }

                if (simulationState->backPorchXCounter >= VGABackPorchX) {
                    simulationState->hCounter += 1;
                }
            }
        }

        if (!simulationState->lastOutput.vSync && simulationState->nextOutput.vSync) {

            if (simulationState->frameCounter > 0) {
                showFrame = true;
            }

            // New frame
            simulationState->frameCounter += 1;
            simulationState->hCounter = 0;
            simulationState->vCounter = 0;

            // Set this to zero so we can count up to the actual
            simulationState->backPorchYCounter = 0;
        }

        simulationState->lastOutput = simulationState->nextOutput;

        if (showFrame) {
            return simulationState->frameCounter - 1;
        }
    }

    VGACloseFile(simulationState->simulationFile);

    simulationState->frameCounter = 0;
    return 0;
}
