#!/usr/bin/env python3
'''VGASimulator.py - Pedro José Pereira Vieito © 2016
    View VGA output from a VHDL simulation.

    Ported from VGA Simulator:
    https://github.com/MadLittleMods/vga-simulator
    by Eric Eastwood <contact@ericeastwood.com>

    More info about how to generate VGA output from VHDL simulation here:
    http://ericeastwood.com/blog/8/vga-simulator-getting-started

Usage:
    VGASimulator.py <file> [<frames>]

Options:
    -h, --help    Show this help
'''

import sys
import os
import re
import struct
from PIL import Image
from docopt import docopt

__author__ = "Pedro José Pereira Vieito"
__email__ = "pvieito@gmail.com"

# Display settings
# http://tinyvga.com/vga-timing
res_x = 1280
res_y = 1024
back_porch_x = 318
back_porch_y = 38


def render_vga(file):

    vga_file = open(file, 'r')

    back_porch_x_count = 0
    back_porch_y_count = 0

    h_counter = 0
    v_counter = 0

    last_hsync = -1
    last_vsync = -1

    frame_count = 0

    vga_output = None

    print('[ ] VGA Simulator')
    print('[ ] Resolution:', res_x, '×', res_y)

    for vga_line in vga_file:
        vga_line = vga_line.split(" ")

        try:
            hsync = ord(vga_line[2]) - 0x30
            vsync = ord(vga_line[3]) - 0x30
            red = int(vga_line[4], 2) << 4
            green = int(vga_line[5], 2) << 4
            blue = int(vga_line[6], 2) << 4
        except:
            hsync, vsync, red, gree, blue = (0, 0, 0, 0, 0)

        if not last_hsync and hsync:
            h_counter = 0

            # Move to the next row, if past back porch
            if back_porch_y_count >= back_porch_y:
                v_counter += 1

            # Increment this so we know how far we are
            # after the vsync pulse
            back_porch_y_count += 1

            # Set this to zero so we can count up to the actual
            back_porch_x_count = 0

        if not last_vsync and vsync:

            if vga_output:
                vga_output.show("VGA Output")
            else:
                vga_output = Image.new('RGB', (res_x, res_y), (0, 0, 0))

            if frame_count < frames_limit or frames_limit == -1:
                print("[+] VSYNC: Decoding frame", frame_count)

                frame_count += 1
                h_counter = 0
                v_counter = 0

                # Set this to zero so we can count up to the actual
                back_porch_y_count = 0

            else:
                print("[ ]", frames_limit, "frames decoded")
                exit(0)

        if vga_output and vsync and hsync:
            # Increment this so we know how far we are
            # After the hsync pulse
            back_porch_x_count += 1

            # If we are past the back porch
            # Then we can start drawing on the canvas
            if back_porch_x_count >= back_porch_x and \
               back_porch_y_count >= back_porch_y:

                # Add pixel
                if h_counter < res_x and v_counter < res_y:
                    vga_output.putpixel((h_counter, v_counter),
                                        (red, green, blue))

            # Move to the next pixel, if past back porch
            if back_porch_x_count >= back_porch_x:
                h_counter += 1

        last_hsync = hsync
        last_vsync = vsync

args = docopt(__doc__)
file = args['<file>']

if args['<frames>']:
    frames_limit = int(args['<frames>'])
else:
    frames_limit = -1

vga_extensions = ['.vga', '.txt']

if os.path.isfile(file) and os.path.splitext(file)[1] in vga_extensions:
    render_vga(file)
    print("[ ]", "Final frame decoded")
else:
    print('[x] VGA output file (.vga) not found.')
