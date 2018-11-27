//
//  Vector4f.m
//  texture-coordinates
//
//  Created by sprite on 2018/11/27.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector4f.h"

@interface Vector4f(){
//    float _x;
//    float _y;
//    float _z;
//    float _w;
}
@property float x;
@property float y;
@property float z;
@property float w;

@end


@implementation Vector4f
-(id)initWithX:(float)x Y:(float)y Z:(float)z W:(float)w {
    if(self = [super init]) {
        self.x = x;
        self.y = y;
        self.z = z;
        self.w = w;
    }
    return self;
}

@end
