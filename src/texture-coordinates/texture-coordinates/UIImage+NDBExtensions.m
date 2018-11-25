//
//  UIImage+NDBExtensions.m
//  texture-coordinates
//
//  Created by Sprite on 2018/11/24.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import "UIImage+NDBExtensions.h"

@implementation UIImage (NDBExtensions)

- (GLKVector4)pickPixelAtX:(NSUInteger)x Y:(NSUInteger)y {
    
    CGImageRef cgImage = [self CGImage];
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    if ((x > width) || (y > height))
    {
        GLKVector4 baseColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
        return baseColor;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef bitmapData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(bitmapData);
    size_t offset = ((width * y) + x) * 4;
    //UInt8 b = data[offset+0];
    float b = data[offset+0];
    float g = data[offset+1];
    float r = data[offset+2];
    float a = data[offset+3];
    CFRelease(bitmapData);
    NSLog(@"R:%f G:%f B:%f A:%f", r, g, b, a);
    GLKVector4 objColor = GLKVector4Make(r/255.0f, g/255.0f, b/255.0f, a/255.0f);
    return objColor;
}

@end
