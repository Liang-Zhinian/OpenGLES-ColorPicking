//
//  AbstractCamera.m
//  texture-coordinates
//
//  Created by sprite on 2018/11/27.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import "AbstractCamera.h"



@implementation AbstractCamera

-(id)initWithWidth:(CGFloat)width Height:(CGFloat)height FieldOfView:(GLfloat)fieldOfView Near:(GLfloat)near Far:(GLfloat)far {
    if(self = [super init]) {
        self.fov = fieldOfView;
        self.width = width;
        self.height = height;
        self.near = near;
        self.far = far;
        self.projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fieldOfView), width/height, near, far);
    }
    return self;
}

@end
