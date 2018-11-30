//
//  ViewController.swift
//  OpenGLPicking
//
//  Created by Kares Qin on 10/21/15.
//  Copyright © 2015 Kares Qin. All rights reserved.
//

import UIKit
import QuartzCore
import OpenGLES
import GLKit
import Foundation


func F3(x:Float, _ y:Float, _ z:Float) -> (x:Float, y:Float, z:Float){
    return (x:x, y:y, z:z)
}

//helper extensions to pass arguments to GL land
extension Int32 {
    func __conversion() -> GLenum {
        return GLuint(self)
    }
    
    func __conversion() -> GLboolean {
        return GLboolean(UInt8(self))
    }
}

extension Int {
    func __conversion() -> Int32 {
        return Int32(self)
    }
    
    func __conversion() -> GLubyte {
        return GLubyte(self)
    }
    
}

/// Array extension to help with size/memory calculations when working with OpenGL.
extension Array {
    
    //
    // MARK: - Instance Methods
    //
    
    /// Returns the momory size/footprint (in bytes) of a given array.
    ///
    /// - Returns: Integer value representing the memory size the array.
    func size () -> Int {
        return count * MemoryLayout.size(ofValue: self[0])
    }
}

struct Utils {
    
    static var timeRecorder = NSMutableDictionary()
    static var analysisRecorder = NSMutableDictionary()
    static var delayRecorder:[Bool] = []
    
    static func setDelay(time:Double = 1, closure:@escaping ()->()) -> Int {
        let index:Int = delayRecorder.count
        delayRecorder.append(true)
        
        //        dispatch_after(
        //            dispatch_time(
        //                dispatch_time_t(DISPATCH_TIME_NOW),
        //                Int64(time * Double(NSEC_PER_SEC))
        //            ),
        //            dispatch_get_main_queue(), {
        //                if self.delayRecorder[index]{
        //                    closure()
        //                }
        //        })
        
        let mainQueue = DispatchQueue.main
        let deadline = DispatchTime.now() + time
        mainQueue.asyncAfter(deadline: deadline) {
            if self.delayRecorder[index]{
                closure()
            }
        }
        
        return index
    }
    
    static func cancelDelay(index:Int = -1){
        if -1 < index && index < delayRecorder.count && delayRecorder[index]{
            delayRecorder[index] = false
        }
    }
}


final class GLController: GLKViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.preferredFramesPerSecond = 60
//        self.cubeView.controller = self
//        self.cubeView.resize()
        // Do any additional setup after loading the view, typically from a nib.
        setupGL()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Reference to provide easy access to our EAGLContext.
    private var context: EAGLContext?
    var _anchor_position:CGPoint!
    var _current_position:CGPoint!
    var _beta:Float!
    var _garma:Float!
    var indexBuffer: GLuint = GLuint()
    var indexBufferSize:Int = 36 * 4 * 1024 * 8
    var vertexBuffer: GLuint = GLuint()
    var vertexBufferSize:Int = 24 * 40 * 1024 * 8
    var vertexArray: GLuint = GLuint()
    var cubeEffect = GLKBaseEffect()
    var controller:GLKViewController?
    var camera:SphereCamera!
    var PI = Float(M_PI)
    let NORMAL:[String:(x:Float, y:Float, z:Float)] = [
        "Y" : F3(x:0,1,0),
        "-Y" : F3(x:0,-1,0),
        "X" : F3(x:1,0,0),
        "-X" : F3(x:-1,0,0),
        "Z" : F3(x:0,0,1),
        "-Z" : F3(x:0,0,-1)
    ]
    var vertices:[Vertex]  = [
        Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
        Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1),
        Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1),
        Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1),
        ]
    var indices:[GLuint] = [
        0, 1, 2,
        2, 3, 0
    ]
    var appendIndex:Int = 0
    var rotation: Float = 0.0
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder:aDecoder)
//
//        setupGL()
//    }
    
    /// Method to deinitialize and perform cleanup when the view controller is removed from memory.
    deinit {
        // Delete buffers, cleanup memory, etc.
        tearDownGL()
    }
    
    /// Setup the current OpenGL context, generate and find necessary buffers, and store geometry data in memory (buffers).
    private func setupGL() {
        // Just like with CoreGraphics, in order to do much with OpenGL, we need a context.
        //   Here we create a new context with the version of the rendering API we want and
        //   tells OpenGL that when we draw, we want to do so within this context.
        self.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        
//        if (self.context?.isEqual(nil)) {
//            print("Failed to initialize OpenGLES 2.0 context!")
//            exit(1)
//        }
        
        if (!EAGLContext.setCurrent(self.context)) {
            print("Failed to set current OpenGL context!")
            exit(1)
        }
        
        EAGLContext.setCurrent(self.context)
        
        // Perform checks and unwrap options in order to perform more OpenGL setup.
        if let view = self.view as? GLKView, let context = context {
            // Set our view's context to the EAGLContext we just created.s
            view.context = context
            
            // Set ourselves as delegates of GLKViewControllerDelegate
            delegate = self as! GLKViewControllerDelegate
        }
        
        // init GL stuff here
        //        glClearColor(0.0, 0.0, 0.0, 1.0);
        //        glEnable(GLenum(GL_CULL_FACE))
        //        glEnable(GLenum(GL_DEPTH_TEST));
        //        glDepthFunc(GLenum(GL_LEQUAL));
        // Enable Transparency
        //        glEnable(GLenum(GL_BLEND));
        //        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        //        self.cubeEffect.colorMaterialEnabled = GLboolean(GL_TRUE)
        //        self.cubeEffect.light0.enabled = GLboolean(GL_TRUE)
        //        self.cubeEffect.light0.position = GLKVector4Make(0, 10, 0, 1)
        //        self.cubeEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1.0);
        //        self.cubeEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
        //        self.cubeEffect.light0.specularColor = GLKVector4Make(0, 0, 0, 1);
        
        //        let ves = genOneCubeVertices(position: GLKVector3Make(0, 0, 0), color: (1,0.5,0,1))
        //        let ins = genOneCubeIndices(index: 0)
        //
        //        vertices.append(contentsOf: ves)
        //        indices.append(contentsOf: ins)
        //
        
        
        //
        //        for var index = 0; index < 1000; ++index {
        //            let ves = genOneCubeVertices(GLKVector3Make(Float(appendIndex % 10), Float(appendIndex%100 / 10), Float(appendIndex/100)), color: (Float(appendIndex % 10) / Float(10), Float(appendIndex % 100) / Float(100), Float(appendIndex)/1000, 1))
        //            let ins = genOneCubeIndices(appendIndex)
        //            vertices.appendContentsOf(ves)
        //            indices.appendContentsOf(ins)
        //            appendIndex++
        //        }
        
        
        
        let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
        let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
        
        // The size, in memory, of a Vertex structure.
        let vertexSize = MemoryLayout<Vertex>.stride
        // The byte offset, in memory, of our color information within a Vertex object.
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        // Swift pointer object that stores the offset of the color information within our Vertex structure.
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        // VAO
        
        // Generate and bind a vertex array object.
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)
        
        // VBO
        
        // Generatea a buffer for our vertex buffer object.
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        vertexBufferSize = vertices.size()
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexBufferSize, vertices, GLenum(GL_DYNAMIC_DRAW))
        
        // Enable the position vertex attribute to then specify information about how the position of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribPosition)
        glVertexAttribPointer(vertexAttribPosition, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), nil)
        
        // Enable the colors vertex attribute to then specify information about how the color of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribColor)
        glVertexAttribPointer(vertexAttribColor, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), colorOffsetPointer)
        
        //        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        //        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(MemoryLayout.size(ofValue:Vertex.self)),  UnsafePointer<Int>(bitPattern: MemoryLayout.size(ofValue:Float.self) * 7))
        
        // EBO
        
        // Generatea a buffer for our element buffer object.
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        indexBufferSize = indices.size()
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBufferSize, &indices, GLenum(GL_DYNAMIC_DRAW))
        
        
        // Unbind all buffers and objects.
        
        // Unbind the vertex buffer and the vertex array object.
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
        
    }
    
    
    /// Perform cleanup, and delete buffers and memory.
    private func tearDownGL() {
        // Set the current EAGLContext to our context. This ensures we are deleting buffers against it and potentially not a
        // different context.
        EAGLContext.setCurrent(self.context)
        
        // Delete the vertex array object, the element buffer object, and the vertex buffer object.
        glDeleteBuffers(1, &vertexArray)
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &indexBuffer)
        
        // Set the current EAGLContext to nil.
        EAGLContext.setCurrent(nil)
        
        // Then nil out or variable that references our EAGLContext.
        //        self.context = nil
    }
    
    func pushVertexBuffer(cubeIndex:Int, number:Int){
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), GLintptr(cubeIndex * 24 * MemoryLayout.size(ofValue:Vertex.self)), GLsizeiptr(number * 24 * MemoryLayout.size(ofValue:Vertex.self)), &vertices + cubeIndex * 24 * MemoryLayout.size(ofValue:Vertex.self))
    }
    func pushIndexBuffer(cubeIndex:Int, number:Int){
        glBufferSubData(GLenum(GL_ELEMENT_ARRAY_BUFFER), cubeIndex * 36 * MemoryLayout.size(ofValue:GLuint.self), number * 36 * MemoryLayout.size(ofValue:GLuint.self), &indices + cubeIndex * 36 * MemoryLayout.size(ofValue:GLuint.self))
    }
    
    func resize(){
        
        if self.controller != nil {
            self.camera = SphereCamera(width: view.bounds.width, height: view.bounds.height)
            //            self.cubeEffect.transform.projectionMatrix = self.camera.projection
            let aspect = fabsf(Float(view.bounds.size.width) / Float(view.bounds.size.height))
            let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0)
            self.cubeEffect.transform.projectionMatrix = projectionMatrix
            
            var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
            rotation += 90 * Float(0.1)
            modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
            self.cubeEffect.transform.modelviewMatrix = modelViewMatrix
            
            //            Utils.setDelay(time: 2, closure: testCreating)
        }
    }
    
    /*
     func genOneCubeVertices(position:GLKVector3, color:(r:Float, g:Float, b:Float, a:Float)) -> [Vertex]{
     
     let x = position.x
     let y = position.y
     let z = position.z
     return [
     Vertex(Position: F3(x:x+0.5, y-0.5, z+0.5) ,   Color: color, Normal:NORMAL["Z"]! ), //0
     Vertex(Position: F3(x:x+0.5, y+0.5, z+0.5)  ,  Color: color, Normal:NORMAL["Z"]! ), //1
     Vertex(Position: F3(x:x-0.5, y+0.5, z+0.5) ,   Color: color, Normal:NORMAL["Z"]! ), //2
     Vertex(Position: F3(x:x-0.5, y-0.5, z+0.5),    Color: color, Normal:NORMAL["Z"]! ), //3
     
     Vertex(Position: F3(x:x+0.5, y+0.5, z-0.5) ,   Color: color, Normal:NORMAL["-Z"]! ), //4
     Vertex(Position: F3(x:x-0.5, y-0.5, z-0.5),    Color: color, Normal:NORMAL["-Z"]! ), //5
     Vertex(Position: F3(x:x+0.5, y-0.5, z-0.5) ,   Color: color, Normal:NORMAL["-Z"]! ), //6
     Vertex(Position: F3(x:x-0.5, y+0.5, z-0.5),    Color: color, Normal:NORMAL["-Z"]! ), //7
     
     Vertex(Position: F3(x:x-0.5, y-0.5, z+0.5),    Color: color, Normal:NORMAL["-X"]! ), //8
     Vertex(Position: F3(x:x-0.5, y+0.5, z+0.5)  ,  Color: color, Normal:NORMAL["-X"]! ), //9
     Vertex(Position: F3(x:x-0.5, y+0.5, z-0.5) ,   Color: color, Normal:NORMAL["-X"]! ), //10
     Vertex(Position: F3(x:x-0.5, y-0.5, z-0.5),    Color: color, Normal:NORMAL["-X"]! ), //11
     
     Vertex(Position: F3(x:x+0.5, y-0.5, z-0.5) ,   Color: color, Normal:NORMAL["X"]! ), // 12
     Vertex(Position: F3(x:x+0.5, y+0.5, z-0.5)  ,  Color: color, Normal:NORMAL["X"]! ), //13
     Vertex(Position: F3(x:x+0.5, y+0.5, z+0.5),    Color: color, Normal:NORMAL["X"]! ), //14
     Vertex(Position: F3(x:x+0.5, y-0.5, z+0.5),    Color: color, Normal:NORMAL["X"]! ), //15
     
     Vertex(Position: F3(x:x+0.5, y+0.5, z+0.5),    Color: color, Normal:NORMAL["Y"]!), //16
     Vertex(Position: F3(x:x+0.5, y+0.5, z-0.5) ,   Color: color, Normal:NORMAL["Y"]! ), //17
     Vertex(Position: F3(x:x-0.5, y+0.5, z-0.5),    Color: color, Normal:NORMAL["Y"]! ), // 18
     Vertex(Position: F3(x:x-0.5, y+0.5, z+0.5),    Color: color, Normal:NORMAL["Y"]! ), //19
     
     Vertex(Position: F3(x:x+0.5, y-0.5, z-0.5) ,   Color: color, Normal:NORMAL["-Y"]! ), //20
     Vertex(Position: F3(x:x+0.5, y-0.5, z+0.5) ,   Color: color, Normal:NORMAL["-Y"]! ), //21
     Vertex(Position: F3(x:x-0.5, y-0.5, z+0.5),    Color: color, Normal:NORMAL["-Y"]! ), //22
     Vertex(Position: F3(x:x-0.5, y-0.5, z-0.5),    Color: color, Normal:NORMAL["-Y"]! ) //23
     ]
     }
     
     func genOneCubeIndices(index:Int) -> [GLuint]{
     
     let vertexCount = GLuint(index * 24)
     return [
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
     ]
     }*/
    
    func intersectsTriangle(near:GLKVector3, far:GLKVector3, a: GLKVector3, b: GLKVector3, c: GLKVector3, normal:GLKVector3) -> (intersect:Bool, result:GLKVector3?){
        //follow http://sarvanz.blogspot.com/2012/03/probing-using-ray-casting-in-opengl.html
        
        let ray = GLKVector3Subtract(far, near)
        let nDotL = GLKVector3DotProduct(normal, ray)
        //是否跟三角面在同一平面或者背对三角面
        if nDotL >= 0 {
            return (intersect:false, result:nil)
        }
        
        let d = GLKVector3DotProduct(normal, GLKVector3Subtract(a, near)) / nDotL
        //是否在最近点和最远点之外
        if (d < 0 || d > 1) {
            return (intersect:false, result:nil)
        }
        
        let p = GLKVector3Add(near, GLKVector3MultiplyScalar(ray, d))
        let n1 = GLKVector3CrossProduct( GLKVector3Subtract(b, a),  GLKVector3Subtract(p, a))
        let n2 = GLKVector3CrossProduct( GLKVector3Subtract(c, b),  GLKVector3Subtract(p, b))
        let n3 = GLKVector3CrossProduct( GLKVector3Subtract(a, c),  GLKVector3Subtract(p, c))
        
        if GLKVector3DotProduct(normal, n1) >= 0 &&
            GLKVector3DotProduct(normal, n2) >= 0 &&
            GLKVector3DotProduct(normal, n3) >= 0{
            return (intersect:true, result:p)
        }else{
            return (intersect:false, result:nil)
        }
    }
    
    func testCreating(){
        
        var delay:Int = -1
        
        
        func delayFn(){
            /*
             let ves = genOneCubeVertices(position: GLKVector3Make(Float(appendIndex % 10), Float(appendIndex%100 / 10), Float(appendIndex/100)), color: (Float(appendIndex % 10) / Float(10), Float(appendIndex % 100) / Float(100), Float(appendIndex)/1000, 1))
             let ins = genOneCubeIndices(index: appendIndex)
             
             vertices.append(contentsOf: ves)
             indices.append(contentsOf: ins)
             
             pushVertexBuffer(cubeIndex: appendIndex, number: 1)
             pushIndexBuffer(cubeIndex: appendIndex, number: 1)
             
             appendIndex += 1*/
            
            if delay < 1000{
                delay = Utils.setDelay(time: 0.005, closure: delayFn)
            }
            
        }
        delayFn()
        
    }
    
    func pick(x:Float, y:Float){
        
        //follow http://schabby.de/picking-opengl-ray-tracing/
        let viewVector3 = GLKVector3Normalize(GLKVector3Subtract(self.camera.target, self.camera.position))
        var hVector3 = GLKVector3Normalize(GLKVector3CrossProduct(viewVector3, self.camera.up))
        var vVector3 = GLKVector3Normalize(GLKVector3CrossProduct(hVector3, viewVector3))
        
        let width = Float(self.camera.width)
        let height = Float(self.camera.height)
        
        // convert fovy to radians
        let rad = self.camera.fov * PI / 180
        let vLength = tan( rad / 2 ) * self.camera.near
        let hLength = vLength * (width / height)
        
        vVector3 = GLKVector3MultiplyScalar(vVector3, vLength)
        hVector3 = GLKVector3MultiplyScalar(hVector3, hLength)
        
        // translate mouse coordinates so that the origin lies in the center
        // of the view port
        var xPoint = x - width / 2
        var yPoint = y - height / 2
        xPoint = xPoint/width * 2
        yPoint = -yPoint/height * 2
        
        
        
        
        // compute direction of picking ray by subtracting intersection point
        
        var direction = GLKVector3Add(GLKVector3MultiplyScalar(viewVector3, self.camera.near), GLKVector3MultiplyScalar(hVector3, xPoint))
        direction = GLKVector3Add(direction, GLKVector3MultiplyScalar(vVector3, yPoint))
        
        // linear combination to compute intersection of picking ray with
        // view port plane
        let near = GLKVector3Add(self.camera.position, direction)
        let far = GLKVector3Add(self.camera.position, GLKVector3MultiplyScalar(direction, self.camera.far / self.camera.near))
        
        //print("near : " + String(near.x) + " " + String(near.y) + " " + String(near.z))
        //print("far : " + String(far.x) + " " + String(far.y) + " " + String(far.z))
        
        for index in (1 ..< (indices.count+1)) {
            if index != 1 && index % 3 == 0{
                //                let aa = vertices[Int(indices[index-3])].Position
                //                let bb = vertices[Int(indices[index-2])].Position
                //                let cc = vertices[Int(indices[index-1])].Position
                //                let nn = vertices[Int(indices[index-1])].Normal
                //                let a = GLKVector3Make(aa.x, aa.y, aa.z)
                //                let b = GLKVector3Make(bb.x, bb.y, bb.z)
                //                let c = GLKVector3Make(cc.x, cc.y, cc.z)
                //                let n = GLKVector3Make(Float(nn.x), Float(nn.y), Float(nn.z))
                //                let data = intersectsTriangle(near: near, far:far,  a: a, b: b, c: c, normal:n)
                //                if data.intersect {
                //                    print(String( data.result!.x) + " " + String( data.result!.y) + " " + String( data.result!.z) + " ")
                //                }
            }
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.controller?.isPaused = false
        let touches = Array(touches)
        if touches.count >= 1{
            let touch:UITouch = touches.first!
            _anchor_position = touch.location(in: view)
            _current_position = _anchor_position
            _beta = self.camera.beta
            _garma = self.camera.garma
            pick(x: Float(_anchor_position.x), y: Float(_anchor_position.y))
            
            //            let previousIndex = appendIndex
            //            for _ in (0 ..< 10) {
            //                let ves = genOneCubeVertices(position: GLKVector3Make(Float(appendIndex % 10), Float(appendIndex%100 / 10), Float(appendIndex/100)), color: (Float(appendIndex % 10) / Float(10), Float(appendIndex % 100) / Float(100), Float(appendIndex)/1000, 1))
            //                let ins = genOneCubeIndices(index: appendIndex)
            //                vertices.append(contentsOf: ves)
            //                indices.append(contentsOf: ins)
            //                appendIndex += 1
            //            }
            //
            //            pushVertexBuffer(cubeIndex: previousIndex, number: 10)
            //            pushIndexBuffer(cubeIndex: previousIndex, number: 10)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.controller?.isPaused = false
        let touches = Array(touches)
        if touches.count >= 1{
            let touch:UITouch = touches.first!
            _current_position = touch.location(in: self.view)
            let diff = CGPoint(x: _current_position.x - _anchor_position.x, y:_current_position.y - _anchor_position.y)
            let beta = GLKMathDegreesToRadians(Float(diff.y) / 2.0);
            let garma = GLKMathDegreesToRadians(Float(diff.x) / 2.0);
            
            self.camera.update(beta: _beta + beta, garma: _garma + garma)
            
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        self.controller?.paused = true
    }
    
}


//
// MARK: - GLKViewController Delegate
//
extension GLController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        let aspect = fabsf(Float(view.bounds.size.width) / Float(view.bounds.size.height))
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0)
        self.cubeEffect.transform.projectionMatrix = projectionMatrix
        
        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
        rotation += 90 * Float(timeSinceLastUpdate)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
        self.cubeEffect.transform.modelviewMatrix = modelViewMatrix
    }
}

//
// MARK: - GLKView Delegate
//

/// Extension to implement the GLKViewDelegate methods.
extension GLController {
    
    /// Draw the view's contents using OpenGL ES.
    ///
    /// - Parameters:
    ///   - view: The GLKView object to redraw contents into.
    ///   - rect: Rectangle that describes the area to draw into.
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // Set the color we want to clear the screen with (before drawing) to black.
        glClearColor(0.85, 0.85, 0.85, 1.0)
        // Clear the contents of the screen (the color buffer) with the black color we just set.
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // Compiles the shaders for drawing and binds them to the current context.
        self.cubeEffect.prepareToDraw()
        
        // We bind our vertex array object, essentially indicating we want to use its information to draw geometry on screen.
        glBindVertexArrayOES(vertexArray);
        // Make the call to draw elements on screen. We indicate we want to draw triangles, specify the number of vertices we
        // want to draw via our indices array, and also tell OpenGL what variable type is used to store the index information.
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        // Unbind the vertex array object so future calls don't accidentally use it.
        glBindVertexArrayOES(0)
    }
}

