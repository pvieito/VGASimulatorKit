//
//  VGASimulatorCore.c
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#include "VGASimulatorCore.h"

FILE* _Nullable VGAOpenFile(const char * path) {
        
    FILE *file = fopen(path, "r");
    
    if (file == NULL) {
        return NULL;
    }

    return file;
}

int VGACloseFile(FILE** file) {

    if (*file != NULL) {
        fclose(*file);
    }

    *file = NULL;
    return 0;
}

int VGAGetNextLine(FILE **file, char **line) {

    if (file == NULL) {
        return -1;
    }

    size_t len = 0;
    ssize_t readlen;
    
    if ((readlen = getline(line, &len, *file)) < 0) {
        return -1;
    }

    return 0;
}

int VGAGetNextOutput(FILE **file, VGAOutput *vgaOuput) {

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
                vgaOuput->red = (uint8_t)strtol(pch, NULL, 2) << 4;
                break;
            case 5:
                vgaOuput->green = (uint8_t)strtol(pch, NULL, 2) << 4;
                break;
            case 6:
                vgaOuput->blue = (uint8_t)strtol(pch, NULL, 2) << 4;
                break;
        }

        pch = strtok(NULL, " ");
        index++;
    }
    
    free(line);

    return 0;
}
