//
//  ViewController.m
//  texture-coordinates
//
//  Created by Christoph Halang on 28/02/15.
//  Copyright (c) 2015 Christoph Halang. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "Geometry.h"
#import "SphereCamera.h"


Position MakePosition(float f[3]){
    Position p = {f[0], f[1], f[2]};
    return p;
}

Color MakeColor(float r, float g, float b, float a){
    Color c = {r, g, b, a};
    return c;
}

Normal MakeNormal(float s, float t, float p) {
    Normal n = {s, t, p};
    return n;
}

Normal MakeNormal3(float f[3]) {
    Normal n = {f[0], f[1], f[2]};
    return n;
}

@interface ViewController (){
    float _curRed;
    BOOL _increasing;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _vertexArray;
    float _rotation;
    GLKMatrix4 _rotMatrix;
    GLKVector3 _anchor_position;
    GLKVector3 _current_position;
    GLKQuaternion _quatStart;
    GLKQuaternion _quat;
    
    BOOL _slerping;
    float _slerpCur;
    float _slerpMax;
    GLKQuaternion _slerpStart;
    GLKQuaternion _slerpEnd;
    
    EAGLContext* _context;
    GLKBaseEffect* _effect;
    SphereCamera* _camera;
    BOOL _initialized;
    
    BOOL _autoRotate;
    
    float _beta;
    float _garma;
}

@property GLKMatrix4 modelMatrix; // transformations of the model
@property GLKMatrix4 viewMatrix; // camera position and orientation
@property GLKMatrix4 projectionMatrix; // view frustum (near plane, far plane)
@property GLKTextureInfo* textureInfo;
@property float rotation;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property int32_t glVertexAttributeBufferID;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *) self.view;
    view.context = _context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    self.viewMatrix = GLKMatrix4MakeLookAt(0.0, 0.0, 26.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    self.projectionMatrix  = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), 4.0/3.0, 1, 51);
    
    [self initEffect];
    [self initCamera];
    [self setupGL];
    
    _autoRotate = NO;
}

- (void)initEffect {
    _effect = [[GLKBaseEffect alloc] init];
    [self configureDefaultLight];
    _initialized = YES;
}

- (void)initCamera {
    _camera = [[SphereCamera alloc] initWithWidth: self.view.bounds.size.width Height: self.view.bounds.size.height];
    if (_effect != nil)
        _effect.transform.projectionMatrix = _camera.projection;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup The Shader

- (void)prepareEffectWithModelMatrix:(GLKMatrix4)modelMatrix viewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projectionMatrix{
    _effect.transform.modelviewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    _effect.transform.modelviewMatrix = GLKMatrix4Multiply(_camera.view, modelMatrix);
    _effect.transform.projectionMatrix = projectionMatrix;
    [_effect prepareToDraw];
}

- (void)configureDefaultLight{
    //Lightning
    _effect.light0.enabled = GL_TRUE;
    _effect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1.0);
    _effect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1.0);
    _effect.light0.position = GLKVector4Make(0, 0,-10,1.0);
}

- (void)configureDefaultMaterial {
    
    _effect.texture2d0.enabled = NO;
    
    
    _effect.material.ambientColor = GLKVector4Make(0.3,0.3,0.3,1.0);
    _effect.material.diffuseColor = GLKVector4Make(0.3,0.3,0.3,1.0);
    _effect.material.emissiveColor = GLKVector4Make(0.0,0.0,0.0,1.0);
    _effect.material.specularColor = GLKVector4Make(0.0,0.0,0.0,1.0);
    
    _effect.material.shininess = 0;
}

- (void)configureDefaultTexture{
    _effect.texture2d0.enabled = YES;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"texture_numbers" ofType:@"png"];
    
    NSError *error;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                        forKey:GLKTextureLoaderOriginBottomLeft];
    
    
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path
                                                           options:options error:&error];
    if (self.textureInfo == nil)
        NSLog(@"Error loading texture: %@", [error localizedDescription]);
    
    
    GLKEffectPropertyTexture *tex = [[GLKEffectPropertyTexture alloc] init];
    tex.enabled = YES;
    tex.envMode = GLKTextureEnvModeDecal;
    tex.name = self.textureInfo.name;
    
    _effect.texture2d0.name = tex.name;
    
}

#pragma mark - OpenGL Setup

- (void)setupGL {
    
    [EAGLContext setCurrentContext:_context];
    
    // Try to render as fast as possible
    self.preferredFramesPerSecond = 60;
    
    // init GL stuff here
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glDepthFunc(GL_LEQUAL);
    // Enable Transparency
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    // Create Vertex Array Buffer For Vertex Array Objects
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    
    // All of the following configuration for per vertex data is stored into the VAO
    
    // setup vertex buffer - what are my vertices?
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VerticesCube), VerticesCube, GL_STATIC_DRAW);
    
    // setup index buffer - which vertices form a triangle?
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(IndicesTrianglesCube), IndicesTrianglesCube, GL_STATIC_DRAW);
    
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
    
    
    glActiveTexture(GL_TEXTURE0);
    [self configureDefaultTexture];
    
    
    // were done so unbind the VAO
    glBindVertexArrayOES(0);
    
    _rotMatrix = GLKMatrix4Identity;
    _quat = GLKQuaternionMake(0, 0, 0, 1);
    _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    
    UITapGestureRecognizer * dtRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    dtRec.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:dtRec];
    
}

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:_context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    _effect = nil;
    
}

#pragma mark - OpenGL Drawing

- (void)update{
    if (_increasing) {
        _curRed += 1.0 * self.timeSinceLastUpdate;
    } else {
        _curRed -= 1.0 * self.timeSinceLastUpdate;
    }
    if (_curRed >= 1.0) {
        _curRed = 1.0;
        _increasing = NO;
    }
    if (_curRed <= 0.0) {
        _curRed = 0.0;
        _increasing = YES;
    }
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    self.projectionMatrix = projectionMatrix;
    
    if (_autoRotate)
        self.rotation += self.timeSinceLastUpdate * 0.5f;
    
    if (_slerping) {
        
        _slerpCur += self.timeSinceLastUpdate;
        float slerpAmt = _slerpCur / _slerpMax;
        if (slerpAmt > 1.0) {
            slerpAmt = 1.0;
            _slerping = NO;
        }
        
        _quat = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(_curRed, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawTheCube];
}

- (void)drawTheCube {
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(3.0, 3.0, 3.0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, 0);
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(self.rotation, 1.0, 1.0, 1.0);
    
    if (!_autoRotate)
        rotationMatrix = _rotMatrix;
    
    GLKMatrixStackRef matrixStack = GLKMatrixStackCreate(CFAllocatorGetDefault());
    
    GLKMatrixStackMultiplyMatrix4(matrixStack, translateMatrix);
    GLKMatrixStackMultiplyMatrix4(matrixStack, rotationMatrix);
    GLKMatrixStackMultiplyMatrix4(matrixStack, scaleMatrix);
    
    GLKMatrixStackPush(matrixStack);
    self.modelMatrix = GLKMatrixStackGetMatrix4(matrixStack);
    glBindVertexArrayOES(_vertexArray);
    [self prepareEffectWithModelMatrix:self.modelMatrix viewMatrix:self.viewMatrix projectionMatrix:self.projectionMatrix];
    glDrawElements(GL_TRIANGLES, sizeof(IndicesTrianglesCube) / sizeof(IndicesTrianglesCube[0]), GL_UNSIGNED_BYTE, 0);
    glBindVertexArrayOES(0);
    
    CFRelease(matrixStack);
    
}

- (GLKVector3) projectOntoSurface:(GLKVector3) touchPoint
{
    float radius = self.view.bounds.size.width/3;
    GLKVector3 center = GLKVector3Make(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0);
    GLKVector3 P = GLKVector3Subtract(touchPoint, center);
    
    // Flip the y-axis because pixel coords increase toward the bottom.
    P = GLKVector3Make(P.x, P.y * -1, P.z);
    
    float radius2 = radius * radius;
    float length2 = P.x*P.x + P.y*P.y;
    
    if (length2 <= radius2)
        P.z = sqrt(radius2 - length2);
    else
    {
        /*
         P.x *= radius / sqrt(length2);
         P.y *= radius / sqrt(length2);
         P.z = 0;
         */
        P.z = radius2 / (2.0 * sqrt(length2));
        float length = sqrt(length2 + P.z * P.z);
        P = GLKVector3DivideScalar(P, length);
    }
    
    return GLKVector3Normalize(P);
}

- (void)computeIncremental {
    
    GLKVector3 axis = GLKVector3CrossProduct(_anchor_position, _current_position);
    float dot = GLKVector3DotProduct(_anchor_position, _current_position);
    float angle = acosf(dot);
    
    GLKQuaternion Q_rot = GLKQuaternionMakeWithAngleAndVector3Axis(angle * 2, axis);
    Q_rot = GLKQuaternionNormalize(Q_rot);
    
    // TODO: Do something with Q_rot...
    _quat = GLKQuaternionMultiply(Q_rot, _quatStart);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    _anchor_position = GLKVector3Make(location.x, location.y, 0);
    _anchor_position = [self projectOntoSurface:_anchor_position];
    
    _current_position = _anchor_position;
    _quatStart = _quat;
    
    _beta = _camera.beta;
    _garma = _camera.garma;
    
    [self pickAtX:location.x Y:location.y];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGPoint lastLoc = [touch previousLocationInView:self.view];
    CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
    
    float rotX = -1 * GLKMathDegreesToRadians(diff.y / 2.0);
    float rotY = -1 * GLKMathDegreesToRadians(diff.x / 2.0);
    
    bool isInvertible;
    GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0));
    _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
    GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(0, 1, 0));
    _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
    
    _current_position = GLKVector3Make(location.x, location.y, 0);
    _current_position = [self projectOntoSurface:_current_position];
    
    [self computeIncremental];
    
    CGPoint diff2 = CGPointMake(_current_position.x - _anchor_position.x, _current_position.y - _anchor_position.y);
    float beta = GLKMathDegreesToRadians(diff2.y / 2.0);
    float garma = GLKMathDegreesToRadians(diff2.x / 2.0);
    
    [_camera updateBeta:(_beta + beta) Garma:(_garma + garma)];
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    _slerping = YES;
    _slerpCur = 0;
    _slerpMax = 1.0;
    _slerpStart = _quat;
    _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
    
}

#pragma mark - ray picking


- (void) pickAtX:(CGFloat)x Y:(CGFloat)y {
    
    //follow http://schabby.de/picking-opengl-ray-tracing/
    GLKVector3 viewVector3 = GLKVector3Normalize(GLKVector3Subtract(_camera.target, _camera.position));
    GLKVector3 hVector3 = GLKVector3Normalize(GLKVector3CrossProduct(viewVector3, _camera.up));
    GLKVector3 vVector3 = GLKVector3Normalize(GLKVector3CrossProduct(hVector3, viewVector3));
    
    CGFloat width = _camera.width;
    CGFloat height = _camera.height;
    
    // convert fovy to radians
    float rad = _camera.fov * M_PI / 180;
    float vLength = tan( rad / 2 ) * _camera.near;
    float hLength = vLength * (width / height);
    
    vVector3 = GLKVector3MultiplyScalar(vVector3, vLength);
    hVector3 = GLKVector3MultiplyScalar(hVector3, hLength);
    
    // translate mouse coordinates so that the origin lies in the center
    // of the view port
    float xPoint = x - width / 2;
    float yPoint = y - height / 2;
    xPoint = xPoint/width * 2;
    yPoint = -yPoint/height * 2;
    
    
    
    
    // compute direction of picking ray by subtracting intersection point
    
    GLKVector3 direction = GLKVector3Add(GLKVector3MultiplyScalar(viewVector3, _camera.near), GLKVector3MultiplyScalar(hVector3, xPoint));
    direction = GLKVector3Add(direction, GLKVector3MultiplyScalar(vVector3, yPoint));
    
    // linear combination to compute intersection of picking ray with
    // view port plane
    GLKVector3 near = GLKVector3Add(_camera.position, direction);
    GLKVector3 far = GLKVector3Add(_camera.position, GLKVector3MultiplyScalar(direction, _camera.far / _camera.near));
    
    //print("near : " + String(near.x) + " " + String(near.y) + " " + String(near.z))
    //print("far : " + String(far.x) + " " + String(far.y) + " " + String(far.z))
    
    for (int index = 1; index <= sizeof(IndicesTrianglesCube); index++) {
        if (index != 1 && index % 3 == 0){
            Position aa = MakePosition(VerticesCube[IndicesTrianglesCube[index-3]].Position);
            Position bb = MakePosition(VerticesCube[IndicesTrianglesCube[index-2]].Position);
            Position cc = MakePosition(VerticesCube[IndicesTrianglesCube[index-1]].Position);
            Normal nn = MakeNormal3(VerticesCube[IndicesTrianglesCube[index-1]].Normal);
            GLKVector3 a = GLKVector3Make(aa.x, aa.y, aa.z);
            GLKVector3 b = GLKVector3Make(bb.x, bb.y, bb.z);
            GLKVector3 c = GLKVector3Make(cc.x, cc.y, cc.z);
            GLKVector3 n = GLKVector3Make(nn.s, nn.t, nn.p);
            NSDictionary* data = [self intersectsTriangleWithNear: near
                                                              Far: far
                                                                A: a
                                                                B: b
                                                                C: c
                                                           Normal: n];
            BOOL intersect = [[data objectForKey:@"intersect"] boolValue];
            if (intersect) {
                Position result;
                [[data objectForKey:@"result"] getValue:&result];
                NSLog(@"%x %x %x", result.x, result.y, result.z);
            }
        }
    }
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

@end
