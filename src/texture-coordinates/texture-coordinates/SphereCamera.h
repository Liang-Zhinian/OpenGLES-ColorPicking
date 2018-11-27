//
//  SphereCamera.h
//  texture-coordinates
//
//  Created by sprite on 2018/11/27.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import "AbstractCamera.h"
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SphereCamera : AbstractCamera {
    
}

@property GLKVector3 position;
@property float beta;
@property float garma;
@property float radius;
@property GLKVector3 target;
@property float PI;
@property GLKVector3 up;

-(id)initWithWidth:(CGFloat)width Height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
