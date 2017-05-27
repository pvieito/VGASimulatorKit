#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include "VGASimulatorCore.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c

    printf("VGASimulatorQL - GeneratePreviewForURL");
    CFBooleanRef lastFrame = kCFBooleanFalse;

    CFStringRef vgaSimulationUTI = CFSTR("com.pvieito.vga-simulation");
    CFStringRef dynUTI = CFSTR("dyn.ah62d4rv4ge81q35b");

    CFComparisonResult utiComparisonResult = CFStringCompare(vgaSimulationUTI, contentTypeUTI, kCFCompareCaseInsensitive);
    CFComparisonResult dynComparisonResult = CFStringCompare(dynUTI, contentTypeUTI, kCFCompareCaseInsensitive);

    if ((utiComparisonResult == kCFCompareEqualTo) || (dynComparisonResult == kCFCompareEqualTo)) {
        printf("VGASimulatorQL - UTI: com.pvieito.vga-simulation");

        CGRect rect = CGRectMake(0, 0, (CGFloat)VGAResolutionWidth, (CGFloat)VGAResolutionHeight);

        int pixels = VGAResolutionWidth * VGAResolutionHeight;

        uint32_t *frameBuffer = NULL;
        int bufferSize = sizeof(uint32_t) * pixels;
        frameBuffer = (uint32_t *)malloc(bufferSize);

        CFStringRef simulationPath = CFURLCopyPath(url);
        const char* path = CFStringGetCStringPtr(simulationPath, kCFStringEncodingUTF8);

        if (VGAOpenFile(path) != 0) {
            return -1;
        }

        CGContextRef qlContext = QLPreviewRequestCreatePDFContext(preview, &rect, NULL, options);

        while (lastFrame == kCFBooleanFalse) {

            if (qlContext) {

                CGPDFContextBeginPage(qlContext, NULL);

                int result = VGAGetNextFrame(frameBuffer);

                if (result < 0) {
                    return -1;
                }

                if (result == 0 || result >= 6) {
                    lastFrame = kCFBooleanTrue;
                }

                CGContextRef simulationContext = CGBitmapContextCreate(frameBuffer, VGAResolutionWidth, VGAResolutionHeight, 8, VGAResolutionWidth * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
                CGImageRef cgImage = CGBitmapContextCreateImage(simulationContext);
                CGContextRelease(simulationContext);

                CGContextClipToRect(qlContext, rect);
                CGContextDrawImage(qlContext, rect, cgImage);
                CGImageRelease(cgImage);
                CGPDFContextEndPage(qlContext);
            }
            else {
                return -1;
            }
        }

        CGPDFContextClose(qlContext);
        QLPreviewRequestFlushContext(preview, qlContext);
        VGACloseFile();
    }

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported

    printf("VGASimulatorQL - CancelPreviewGeneration");
}
