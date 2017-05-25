//
//  vga_buffer.h
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#ifndef vga_buffer_h
#define vga_buffer_h

#include <stdio.h>
#include <stdbool.h>

int VGAResolutionWidth;
int VGAResolutionHeight;

int VGABackPorchX;
int VGABackPorchY;

int VGAOpenFile(const char * path);
int VGACloseFile();
int VGAGetNextLine(char **line);
int VGAGetNextLineComponents(bool *hSync, bool *vSync, uint32_t *red, uint32_t *green, uint32_t *blue);
int VGAGetNextFrame(uint32_t *frameBuffer);

#endif /* vga_buffer_h */
