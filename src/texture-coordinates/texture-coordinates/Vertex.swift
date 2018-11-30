//
//  Vertex.swift
//  texture-coordinates
//
//  Created by sprite on 2018/11/29.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

import GLKit

//
// MARK: - Vertex
//

/// Structure to hold a vertex's position and color data.
//struct Vertex {
//    var Position: (x:Float, y:Float, z:Float)
//    var Color:  (r:Float, g:Float, b:Float, a:Float)
//    var Normal:  (x:Float, y:Float, z:Float)
//}


/// Structure to hold a vertex's position and color data.
struct Vertex {
    
    /// Stores the X coordinate of a vertex.
    var x: GLfloat
    
    /// Stores the Y coordinate of a vertex.
    var y: GLfloat
    
    /// Stores the Z coordinate of a vertex.
    var z: GLfloat
    
    /// Stores the red color value of a vertex.
    var r: GLfloat
    
    /// Stores the green color value of a vertex.
    var g: GLfloat
    
    /// Stores the blue color value of a vertex.
    var b: GLfloat
    
    /// Stores the alpha value of a vertex.
    var a: GLfloat
}
