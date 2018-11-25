//
//  UIImage+NDBExtensions.h
//  texture-coordinates
//
//  Created by Sprite on 2018/11/24.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface UIImage (NDBExtensions)

-(GLKVector4)pickPixelAtX:(NSUInteger)x Y:(NSUInteger)y;
@end
