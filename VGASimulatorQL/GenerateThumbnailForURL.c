#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include "VGASimulatorCore.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    // To complete your generator please implement the function GenerateThumbnailForURL in GenerateThumbnailForURL.c
    printf("VGASimulatorQL - GenerateThumbnailForURL");

    CFStringRef vgaSimulationUTI = CFSTR("com.pvieito.vga-simulation");
    CFStringRef dynUTI = CFSTR("dyn.ah62d4rv4ge81q35b");

    CFComparisonResult utiComparisonResult = CFStringCompare(vgaSimulationUTI, contentTypeUTI, kCFCompareCaseInsensitive);
    CFComparisonResult dynComparisonResult = CFStringCompare(dynUTI, contentTypeUTI, kCFCompareCaseInsensitive);

    if ((utiComparisonResult == kCFCompareEqualTo) || (dynComparisonResult == kCFCompareEqualTo)) {
        printf("VGASimulatorQL - UTI: com.pvieito.vga-simulation");

        int pixels = VGAResolutionWidth * VGAResolutionHeight;

        uint32_t *frameBuffer = NULL;
        int bufferSize = sizeof(uint32_t) * pixels;
        frameBuffer = (uint32_t *)malloc(bufferSize);

        CFStringRef simulationPath = CFURLCopyPath(url);
        const char* path = CFStringGetCStringPtr(simulationPath, kCFStringEncodingUTF8);

        if (VGAOpenFile(path) != 0) {
            return -1;
        }

        CGContextRef qlContext = QLThumbnailRequestCreateContext(thumbnail, maxSize, true, NULL);

        if (qlContext) {

            int result = VGAGetNextFrame(frameBuffer);

            if (result < 0) {
                return -1;
            }

            CGContextRef simulationContext = CGBitmapContextCreate(frameBuffer, VGAResolutionWidth, VGAResolutionHeight, 8, VGAResolutionWidth * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
            CGImageRef cgImage = CGBitmapContextCreateImage(simulationContext);
            CGContextRelease(simulationContext);

            CGRect rect = CGRectMake(0, 0, maxSize.width, maxSize.height);
            CGContextClipToRect(qlContext, rect);
            CGContextDrawImage(qlContext, rect, cgImage);
            CGImageRelease(cgImage);
        }
        else {
            return -1;
        }

        QLThumbnailRequestFlushContext(thumbnail, qlContext);
        VGACloseFile();
    }

    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported

    printf("VGASimulatorQL - CancelThumbnailGeneration");
}
