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
    uint8_t red;
    uint8_t green;
    uint8_t blue;
} VGAOutput;

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
int VGACloseFile(FILE **file);

/**
 Gets the next line in the Simulation file.

 @param line Char pointer where to save the next line.
 @return -1 on error.
 */
int VGAGetNextLine(FILE **file, char **line);

/**
 Gets the next VGA Ouput.

 @param vgaOuput VGAOuput struct where to save the next output.
 @return 0 on succes, -1 on error.
 */
int VGAGetNextOutput(FILE **file, VGAOutput *vgaOuput);

#endif /* VGASimulatorCore_h */
