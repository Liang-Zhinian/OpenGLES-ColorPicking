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
#import "DLTriangle.h"
#import "UIImage+NDBExtensions.h"
#import "texture_coordinates-Swift.h"

typedef enum {
    DM_RENDER,
    DM_SELECT
} DrawMode;

@interface ViewController () {
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
    
    BOOL _initialized;
    
    GLuint _framebuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@property GLKMatrix4 modelMatrix; // transformations of the model
@property GLKMatrix4 viewMatrix; // camera position and orientation
@property GLKMatrix4 projectionMatrix; // view frustum (near plane, far plane)
@property GLKTextureInfo* textureInfo;
@end

@implementation ViewController
@synthesize context = _context;
@synthesize effect = _effect;
// Rest of file...

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    
    self.viewMatrix = GLKMatrix4MakeLookAt(0.0, 0.0, 26.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    self.projectionMatrix  = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), 4.0/3.0, 1, 51);
    
    [self initEffect];
    [self setupGL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


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
    _effect.texture2d0.enabled = true;
    
}

#pragma mark - OpenGL Setup

- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);

    // Enable Transparency
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
//    glEnable(GL_CULL_FACE);
    
//    _effect = [[GLKBaseEffect alloc] init];
    
    // New lines
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
    
//    [self createFramebufferObject];
    
    _rotMatrix = GLKMatrix4Identity;
    _quat = GLKQuaternionMake(0, 0, 0, 1);
    _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    
    UITapGestureRecognizer * dtRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    dtRec.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:dtRec];
}

#pragma mark - Create a Framebuffer Object
- (void)createFramebufferObject {
    GLsizei width = 600; //((GLKView *)self.view).drawableWidth;
    GLsizei height = 600; //((GLKView *)self.view).drawableHeight;
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    
    GLuint colorRenderbuffer;
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    GLuint depthRenderbuffer;
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"***************************failed to make complete picker buffer object %x", status);
    }
}

#pragma mark - Setup The Shader

- (void)prepareEffectWithModelMatrix:(GLKMatrix4)modelMatrix viewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projectionMatrix{
    _effect.transform.modelviewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    _effect.transform.projectionMatrix = projectionMatrix;
    [_effect prepareToDraw];
}

- (void)initEffect {
    _effect = [[GLKBaseEffect alloc] init];
    [self configureDefaultLight];
    _initialized = YES;
}

- (void)configureDefaultLight{
    //Lightning
    _effect.light0.enabled = GL_TRUE;
    _effect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1.0);
    _effect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1.0);
    _effect.light0.position = GLKVector4Make(0, 0,-10,1.0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
//    glClearColor(_curRed, 0.0, 0.0, 1.0);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.effect prepareToDraw];

    glBindVertexArrayOES(_vertexArray);
    glDrawElements(GL_TRIANGLES, sizeof(IndicesTrianglesCube)/sizeof(IndicesTrianglesCube[0]), GL_UNSIGNED_BYTE, 0);
    
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(3.0, 3.0, 3.0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, 0);

    GLKMatrixStackRef matrixStack = GLKMatrixStackCreate(CFAllocatorGetDefault());

    GLKMatrixStackMultiplyMatrix4(matrixStack, translateMatrix);
    GLKMatrixStackMultiplyMatrix4(matrixStack, _rotMatrix);
    GLKMatrixStackMultiplyMatrix4(matrixStack, scaleMatrix);

    GLKMatrixStackPush(matrixStack);
    self.modelMatrix = GLKMatrixStackGetMatrix4(matrixStack);
    glBindVertexArrayOES(_vertexArray);
    [self prepareEffectWithModelMatrix:self.modelMatrix viewMatrix:self.viewMatrix projectionMatrix:self.projectionMatrix];
    glDrawElements(GL_TRIANGLES, sizeof(IndicesTrianglesCube) / sizeof(IndicesTrianglesCube[0]), GL_UNSIGNED_BYTE, 0);
    glBindVertexArrayOES(0);

    CFRelease(matrixStack);
}

#pragma mark - GLKViewControllerDelegate

- (void)update {
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
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    if (_slerping) {
        
        _slerpCur += self.timeSinceLastUpdate;
        float slerpAmt = _slerpCur / _slerpMax;
        if (slerpAmt > 1.0) {
            slerpAmt = 1.0;
            _slerping = NO;
        }
        
        _quat = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quat);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotation);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
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
    
//    [self pickAtX: location.x Y:location.y];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint position = [touch locationInView:self.view];
    
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
    
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    _slerping = YES;
    _slerpCur = 0;
    _slerpMax = 1.0;
    _slerpStart = _quat;
    _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
    
}

- (NSDictionary*) intersectsTriangleAtNear: (GLKVector3)near  far:(GLKVector3)far a: (GLKVector3)a b: (GLKVector3)b c: (GLKVector3)c normal:(GLKVector3)normal {
    //follow http://sarvanz.blogspot.com/2012/03/probing-using-ray-casting-in-opengl.html
    
    GLKVector3 ray = GLKVector3Subtract(far, near);
    float nDotL = GLKVector3DotProduct(normal, ray);
    //是否跟三角面在同一平面或者背对三角面
    if (nDotL >= 0) {
        return [NSDictionary dictionaryWithObjectsAndKeys: NO, @"intersect", nil, @"result", nil];
    }
    
    float d = GLKVector3DotProduct(normal, GLKVector3Subtract(a, near)) / nDotL;
    //是否在最近点和最远点之外
    if (d < 0 || d > 1) {
        return [NSDictionary dictionaryWithObjectsAndKeys: NO, @"intersect", nil, @"result", nil];
    }
    
    GLKVector3 p = GLKVector3Add(near, GLKVector3MultiplyScalar(ray, d));
    GLKVector3 n1 = GLKVector3CrossProduct( GLKVector3Subtract(b, a),  GLKVector3Subtract(p, a));
    GLKVector3 n2 = GLKVector3CrossProduct( GLKVector3Subtract(c, b),  GLKVector3Subtract(p, b));
    GLKVector3 n3 = GLKVector3CrossProduct( GLKVector3Subtract(a, c),  GLKVector3Subtract(p, c));
    
    if (GLKVector3DotProduct(normal, n1) >= 0 &&
        GLKVector3DotProduct(normal, n2) >= 0 &&
        GLKVector3DotProduct(normal, n3) >= 0) {
        return [NSDictionary dictionaryWithObjectsAndKeys: @YES, @"intersect", p, @"result", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys: NO, @"intersect", nil, @"result", nil];
    }
}

//-(GLKVector4)pickAtX:(GLuint)x Y:(GLuint)y {
//    GLKView *glkView = (GLKView*)[self view];
//    UIImage *snapshot = [glkView snapshot];
//    GLKVector4 objColor = [snapshot pickPixelAtX:x Y:y];
//    return objColor;
//}

-(NSUInteger)pickAtX:(GLuint)x Y:(GLuint)y {
    NSInteger height = ((GLKView *)self.view).drawableHeight;
    NSInteger width = ((GLKView *)self.view).drawableWidth;
    Byte pixelColor[4] = {0,};
    GLuint colorRenderbuffer;
    GLuint framebuffer;
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER, colorRenderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Framebuffer status: %x", (int)status);
        return 0;
    }
    
    [self render:DM_SELECT];
    
    CGFloat scale = UIScreen.mainScreen.scale;
    glReadPixels(x * scale, (height - (y * scale)), 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixelColor);
    
    glDeleteRenderbuffers(1, &colorRenderbuffer);
    glDeleteFramebuffers(1, &framebuffer);
    NSLog(@"R: %x, G: %x, B: %x, A: %x", (NSUInteger)pixelColor[0], (NSUInteger)pixelColor[1], (NSUInteger)pixelColor[2], (NSUInteger)pixelColor[3]);
    return pixelColor[0];
}

- (void) render:(DrawMode)mode
{
    if (mode == DM_RENDER)
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    else
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
}

@end
