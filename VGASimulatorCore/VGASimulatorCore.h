//
//  VGASimulatorCore.h
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#ifndef VGASimulatorCore_h
#define VGASimulatorCore_h

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

/**
 VGA Output struct.
 */
typedef struct {
    bool hSync;
    bool vSync;
    uint32_t red;
    uint32_t green;
    uint32_t blue;
} VGAOutput;

/**
 VGA Simulation State struct.
 */
typedef struct {
    FILE* simulationFile;
    int backPorchXCounter;
    int backPorchYCounter;
    int hCounter;
    int vCounter;
    int frameCounter;
    VGAOutput lastOutput;
    VGAOutput nextOutput;
} VGASimulationState;

/**
 Opens a new simulation file.

 @param path Path to the simulation file.
 @return 0 on success.
 */
FILE* VGAOpenFile(const char * path);

/**
 Closes the simulation file.

 @return 0 on success.
 */
int VGACloseFile(FILE *file);

/**
 Gets the next line in the Simulation file.

 @param line Char pointer where to save the next line.
 @return -1 on error.
 */
int VGAGetNextLine(FILE *file, char **line);

/**
 Gets the next VGA Ouput.

 @param vgaOuput VGAOuput struct where to save the next output.
 @return 0 on succes, -1 on error.
 */
int VGAGetNextOutput(FILE *file, VGAOutput *vgaOuput);

// Frame Options
extern const int VGAResolutionWidth;
extern const int VGAResolutionHeight;
extern const int VGABackPorchX;
extern const int VGABackPorchY;

/**
 Draws the next frame of the Simulation file in the `frameBuffer`.

 @param frameBuffer Frame Buffer where to draw the simulation.
 @return Frame number on success, 0 for the last frame and -1 on error.
 */
int VGAGetNextFrame(VGASimulationState *simulationState, uint32_t *frameBuffer);

#endif /* VGASimulatorCore_h */
