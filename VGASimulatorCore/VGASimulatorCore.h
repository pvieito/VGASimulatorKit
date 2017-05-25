//
//  vga_buffer.h
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#ifndef vga_buffer_h
#define vga_buffer_h

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

/**
 VGA Output struct.
 */
struct VGAOutput {
    bool hSync;
    bool vSync;
    uint32_t red;
    uint32_t green;
    uint32_t blue;
} VGAOutput;

/**
 Opens a new simulation file.

 @param path Path to the simulation file.
 @return 0 on success.
 */
int VGAOpenFile(const char * path);

/**
 Closes the simulation file.

 @return 0 on success.
 */
int VGACloseFile();

/**
 Gets the next line in the Simulation file.

 @param line Char pointer where to save the next line.
 @return -1 on error.
 */
int VGAGetNextLine(char **line);

/**
 Gets the next VGA Ouput.

 @param vgaOuput VGAOuput struct where to save the next output.
 @return 0 on succes, -1 on error.
 */
int VGAGetNextOutput(struct VGAOutput *vgaOuput);

// Frame Options
extern int VGAResolutionWidth;
extern int VGAResolutionHeight;
extern int VGABackPorchX;
extern int VGABackPorchY;

/**
 Draws the next frame of the Simulation file in the `frameBuffer`.

 @param frameBuffer Frame Buffer where to draw the simulation.
 @return Frame number on success, 0 for the last frame and -1 on error.
 */
int VGAGetNextFrame(uint32_t *frameBuffer);

#endif /* vga_buffer_h */
