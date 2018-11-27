//
//  CubeView.m
//  texture-coordinates
//
//  Created by sprite on 2018/11/27.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import "CubeView.h"
#import <OpenGLES/ES2/glext.h>
#import "Geometry.h"
#import "SphereCamera.h"

Position F3(float x, float y, float z) {
    Position p;
    p.x = x;
    p.y = y;
    p.z = z;
    return p;
}

@interface CubeView() {
    CGPoint _anchor_position;
    CGPoint _current_position;
    float _beta;
    float _garma;
    GLuint _indexBuffer;
    int _indexBufferSize;
    GLuint _vertexBuffer;
    int _vertexBufferSize;
    GLuint _vertexArray;
    GLKBaseEffect* _cubeEffect;
//    GLKViewController* _controller;
    SphereCamera* _camera;
    int _appendIndex;
}

@property GLKViewController* controller;
//@property (strong, nonatomic) GLKBaseEffect *cubeEffect;

@end

@implementation CubeView 

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static const NSDictionary* NORMAL = {
    @"Y", F3(0,1,0),
    @"-Y", F3(0,-1,0),
    @"X", F3(1,0,0),
    @"-X", F3(-1,0,0),
    @"Z", F3(0,0,1),
    @"-Z", F3(0,0,-1)
};

static const float PI = M_PI;

Vertex vertices[] = {};
GLuint indices[] = {};

- (id)initWithCoder:(NSCoder *)aDecoder {
    _indexBufferSize = 36 * 4 * 1024 * 8;
    _vertexBufferSize = 24 * 40 * 1024 * 8;
    _appendIndex=0;
    
    self = [super initWithCoder:aDecoder];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    self.drawableMultisample = GLKViewDrawableMultisample4X;
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"Failed to set current OpenGL context!");
        exit(1);
    }
    
    [EAGLContext setCurrentContext:self.context];
    [self initEffect];
    [self setupGL];
    
    return self;
}

- (void)initEffect {
    _cubeEffect = [[GLKBaseEffect alloc] init];
    _cubeEffect.colorMaterialEnabled = GL_TRUE;
    _cubeEffect.light0.enabled = GL_TRUE;
    _cubeEffect.light0.position = GLKVector4Make(0, 10, 0, 1);
    //        self.cubeEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1.0);
    //        self.cubeEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
    //        self.cubeEffect.light0.specularColor = GLKVector4Make(0, 0, 0, 1);
    
//    [self configureDefaultLight];
}

#pragma mark - OpenGL Setup & Tear down

- (void)setupGL {
    
    // init GL stuff here
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glDepthFunc(GL_LEQUAL);
    // Enable Transparency
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_CULL_FACE);
    
    // Create Vertex Array Buffer For Vertex Array Objects
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    
    // All of the following configuration for per vertex data is stored into the VAO
    
    // setup vertex buffer - what are my vertices?
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, _vertexBufferSize, vertices, GL_DYNAMIC_DRAW);
    
    // setup index buffer - which vertices form a triangle?
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexBufferSize, indices, GL_DYNAMIC_DRAW);
    
    //Setup Vertex Atrributs
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //SYNTAX -,number of elements per vertex, datatype, FALSE, size of element, offset in datastructure
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    //Textures
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord));
    
    //Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Normal));
    
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    _cubeEffect = nil;
}

- (void) pushVertexBufferAtCubeIndex:(int)cubeIndex AndNumber:(int)number {
    glBufferSubData(GL_ARRAY_BUFFER, cubeIndex * 24 * sizeof(Vertex), number * 24 * sizeof(Vertex), &vertices + cubeIndex * 24 * sizeof(Vertex));
}

- (void) pushIndexBufferAtCubeIndex:(int)cubeIndex AndNumber:(int)number {
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, cubeIndex * 36 * sizeof(GLuint), number * 36 * sizeof(GLuint), &indices + cubeIndex * 36 * sizeof(GLuint));
}

- (void) resize {
    
    if (self.controller != nil) {
        _camera = [[SphereCamera alloc] initWithWidth: self.bounds.size.width Height: self.bounds.size.height];
        
        _cubeEffect.transform.projectionMatrix = _camera.projection;
        
        //            Utils.setDelay(2, closure: testCreating)
    }
}


- (Vertex*) genOneCubeVerticesAtPosition:(GLKVector3)position Color:(Color)color {
    
    float x = position.x;
    float y = position.y;
    float z = position.z;
    Vertex vertex[] = {0,};
    
    return vertex;
}

- (GLuint*) genOneCubeIndicesAtIndex:(int)index {
    int vertexCount = index * 24;
    GLuint cubeIndices[] = {
            vertexCount, vertexCount+1, vertexCount+2,
            vertexCount+2, vertexCount+3, vertexCount,
            
            vertexCount+4, vertexCount+6, vertexCount+5,
            vertexCount+4, vertexCount+5, vertexCount+7,
            
            vertexCount+8, vertexCount+9, vertexCount+10,
            vertexCount+10, vertexCount+11, vertexCount+8,
            
            vertexCount+12, vertexCount+13, vertexCount+14,
            vertexCount+14, vertexCount+15, vertexCount+12,
            
            vertexCount+16, vertexCount+17, vertexCount+18,
            vertexCount+18, vertexCount+19, vertexCount+16,
            
            vertexCount+20, vertexCount+21, vertexCount+22,
            vertexCount+22, vertexCount+23, vertexCount+20
    };
    
    return &cubeIndices;
}

- (NSDictionary*) intersectsTriangleWithNear:(GLKVector3)near
                                         Far:(GLKVector3)far
                                           A:(GLKVector3)a
                                           B:(GLKVector3)b
                                           C:(GLKVector3)c
                                      Normal:(GLKVector3)normal {
    //follow http://sarvanz.blogspot.com/2012/03/probing-using-ray-casting-in-opengl.html
    
    GLKVector3 ray = GLKVector3Subtract(far, near);
    float nDotL = GLKVector3DotProduct(normal, ray);
    //是否跟三角面在同一平面或者背对三角面
    if (nDotL >= 0) {
        return @{ @"intersect": @NO, @"result": [NSNull null] };
    }
    
    float d = GLKVector3DotProduct(normal, GLKVector3Subtract(a, near)) / nDotL;
    //是否在最近点和最远点之外
    if (d < 0 || d > 1) {
        return @{ @"intersect": @NO, @"result": [NSNull null] };
    }
    
    GLKVector3 p = GLKVector3Add(near, GLKVector3MultiplyScalar(ray, d));
    GLKVector3 n1 = GLKVector3CrossProduct( GLKVector3Subtract(b, a),  GLKVector3Subtract(p, a));
    GLKVector3 n2 = GLKVector3CrossProduct( GLKVector3Subtract(c, b),  GLKVector3Subtract(p, b));
    GLKVector3 n3 = GLKVector3CrossProduct( GLKVector3Subtract(a, c),  GLKVector3Subtract(p, c));
    
    if (GLKVector3DotProduct(normal, n1) >= 0 &&
        GLKVector3DotProduct(normal, n2) >= 0 &&
        GLKVector3DotProduct(normal, n3) >= 0) {
        NSDictionary *dictionary = @{ @"intersect": @YES, @"result": [NSValue value:&p withObjCType:@encode(GLKVector3)] };
        return dictionary;
    }else{
        return @{ @"intersect": @NO, @"result": [NSNull null] };
    }
}

- (void) testCreating {
    
    int delay = -1;
    
    
    void (^delayFn)(void) = ^{
        GLKVector3 pos = GLKVector3Make(_appendIndex % 10, _appendIndex%100 / 10, _appendIndex/100);
        Color color;
        color.r = _appendIndex % 10 / 10;
        color.g = _appendIndex % 100 / 100;
        color.b = _appendIndex % 1000 / 1000;
        color.a = 1;
        
        GLuint* ves = [self genOneCubeVerticesAtPosition:pos Color: color];
        GLuint* ins = [self genOneCubeIndicesAtIndex:_appendIndex];
//        vertices.appendContentsOf(ves);
//        indices.appendContentsOf(ins);
//        pushVertexBuffer(_appendIndex, number: 1);
//        pushIndexBuffer(_appendIndex, number: 1);
        _appendIndex++;
        
        if (delay < 1000) {
//            delay = Utils.setDelay(0.005, closure: delayFn);
        }
        
    };
    delayFn();
    
}

@end
