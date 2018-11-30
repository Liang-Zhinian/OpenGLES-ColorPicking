//
//  AbstractCamera.h
//  texture-coordinates
//
//  Created by sprite on 2018/11/27.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AbstractCamera : NSObject {

}
@property GLKMatrix4 projection;
@property GLKMatrix4 view;
@property GLfloat fov;
@property CGFloat width;
@property CGFloat height;
@property CGFloat near;
@property CGFloat far;

-(id)initWithWidth:(CGFloat)width Height:(CGFloat)height FieldOfView:(GLfloat)fieldOfView Near:(GLfloat)near Far:(GLfloat)far;

@end

NS_ASSUME_NONNULL_END
