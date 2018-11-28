//
//  SphereCamera.m
//  texture-coordinates
//
//  Created by sprite on 2018/11/27.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import "SphereCamera.h"

@interface SphereCamera() {

}

@end

@implementation SphereCamera

const static float PI = M_PI;

-(id)initWithWidth:(CGFloat)width
            Height:(CGFloat)height {
    
    self = [self initWithWidth: width Height: height FieldOfView: 65 Near: 1 Far: 51 Beta:0 Garma:0 Radius:30 Target:GLKVector3Make(0,0,0)];
    
    return self;
}

-(id)initWithWidth:(CGFloat)width
            Height:(CGFloat)height
       FieldOfView:(GLfloat)fieldOfView
              Near:(GLfloat)near
               Far:(GLfloat)far
              Beta:(GLfloat)beta
             Garma:(GLfloat)garma
            Radius:(GLfloat)radius
            Target:(GLKVector3)target {
//    self.PI = M_PI;
    self.up = GLKVector3Make(0.0, 1.0, 0.0);
    
//    if (fieldOfView == nil) fieldOfView = 60;
//    if (near == nil) near = 2;
//    if (far == nil) far = 50;
//    if (beta == nil) beta = 0;
//    if (garma == nil) garma = 0;
//    if (radius == nil) radius = 30;
//    if (target == nil) target = GLKVector3Make(0,0,0);
    
    self.target = target;
    self.radius = radius;
    self.beta = beta;
    self.garma = garma;
    self = [super initWithWidth: width Height: height FieldOfView: fieldOfView Near: near Far: far];
    [self updateBeta: self.beta Garma: self.garma Radius: self.radius Target: self.target];
    
    return self;
}

-(void) updateBeta:(GLfloat) beta Garma:(GLfloat)garma {
    [self updateBeta: beta Garma: garma Radius: self.radius Target: self.target];
}

-(void) updateBeta:(GLfloat) beta {
    [self updateBeta: beta Garma: self.garma Radius: self.radius Target: self.target];
}

-(void) updateGarma:(GLfloat) garma {
    [self updateBeta: self.beta Garma: garma Radius: self.radius Target: self.target];
}

-(void) updateRadius:(GLfloat) radius {
    [self updateBeta: self.beta Garma: self.garma Radius: radius Target: self.target];
}

-(void) updateTarget:(GLKVector3)target {
    [self updateBeta: self.beta Garma: self.garma Radius: self.radius Target: self.target];
}

-(void) updateBeta:(GLfloat)beta Garma:(GLfloat)garma Radius:(GLfloat)radius
            Target:(GLKVector3)target {
    
    GLfloat x = radius * sin(beta - PI/2) * sin(PI - garma) + target.x;
    GLfloat y = radius * cos(beta - PI/2) + target.y;
    GLfloat z = radius * sin(beta - PI/2) * cos(PI - garma) + target.z;
    
    self.radius = radius;
    self.beta = beta;
    self.garma = garma;
    self.target = target;
    
    self.position = GLKVector3Make(x,y,z);
    
    //        print("beta:" + String(beta))
    //        print("garma:" + String(garma))
    //        print("camera position : " + String(position.x) + " " + String(position.y) + " " + String(position.z))
    
    
    self.view = GLKMatrix4MakeLookAt(self.position.x, self.position.y, self.position.z, self.target.x, self.target.y, self.target.z, self.up.x, self.up.y, self.up.z);
    
}

@end
