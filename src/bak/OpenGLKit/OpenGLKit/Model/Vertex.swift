/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import GLKit

//
// MARK: - Vertex
//

/// Structure to hold a vertex's position and color data.
//struct Vertex (
//
//  /// Stores the X coordinate of a vertex.
//  var x: GLfloat
//
//  /// Stores the Y coordinate of a vertex.
//  var y: GLfloat
//
//  /// Stores the Z coordinate of a vertex.
//  var z: GLfloat
//
//  /// Stores the red color value of a vertex.
//  var r: GLfloat
//
//  /// Stores the green color value of a vertex.
//  var g: GLfloat
//
//  /// Stores the blue color value of a vertex.
//  var b: GLfloat
//
//  /// Stores the alpha value of a vertex.
//  var a: GLfloat
//
//)

struct Vertex {
    var Position: (x:Float, y:Float, z:Float)
    var Color:  (r:Float, g:Float, b:Float, a:Float)
//    var TexCoord: (x:Float, y:Float)
    var Normal:  (x:Float, y:Float, z:Float)
}

struct Position {
    var x:Float
    var y:Float
    var z:Float
}

struct Color{
    var r:Float
    var g:Float
    var b:Float
    var a:Float
}

struct Normal {
    var x:Float
    var y:Float
    var z:Float
}

var VerticesCube:[Vertex] = [
    // Front
    Vertex(Position: (1, -1, 1),    Color: (1, 0, 0, 1), Normal: (0, 0, 1)),
    Vertex(Position: (1, 1, 1),     Color: (0, 1, 0, 1), Normal: (0, 0, 1)),
    Vertex(Position: (-1, 1, 1),    Color: (0, 0, 1, 1), Normal: (0, 0, 1)),
    Vertex(Position: (-1, -1, 1),   Color: (0, 0, 0, 1), Normal: (0, 0, 1)),
    // Back
    Vertex(Position: (1, 1, -1),    Color: (1, 0, 0, 1), Normal: (0, 0, -1)),
    Vertex(Position: (1, -1, -1),   Color: (0, 0, 1, 1), Normal: (0, 0, -1)),
    Vertex(Position: (-1, -1, -1),  Color: (0, 1, 0, 1), Normal: (0, 0, -1)),
    Vertex(Position: (-1, 1, -1),   Color: (0, 0, 0, 1), Normal: (0, 0, -1)),
    // Left
    Vertex(Position: (-1, -1, 1),   Color: (1, 0, 0, 1), Normal: (-1, 0, 0)),
    Vertex(Position: (-1, 1, 1),    Color: (0, 1, 0, 1), Normal: (-1, 0, 0)),
    Vertex(Position: (-1, 1, -1),   Color: (0, 0, 1, 1), Normal: (-1, 0, 0)),
    Vertex(Position: (-1, -1, -1),  Color: (0, 0, 0, 1), Normal: (-1, 0, 0)),
    // Right
    Vertex(Position: (1, -1, -1),   Color: (1, 0, 0, 1), Normal: (1, 0, 0)),
    Vertex(Position: (1, 1, -1),    Color: (0, 1, 0, 1), Normal: (1, 0, 0)),
    Vertex(Position: (1, 1, 1),     Color: (0, 0, 1, 1), Normal: (1, 0, 0)),
    Vertex(Position: (1, -1, 1),    Color: (0, 0, 0, 1), Normal: (1, 0, 0)),
    // Top
    Vertex(Position: (1, 1, 1),     Color: (1, 0, 0, 1), Normal: (0, 1, 0)),
    Vertex(Position: (1, 1, -1),    Color: (0, 1, 0, 1), Normal: (0, 1, 0)),
    Vertex(Position: (-1, 1, -1),   Color: (0, 0, 1, 1), Normal: (0, 1, 0)),
    Vertex(Position: (-1, 1, 1),    Color: (0, 0, 0, 1), Normal: (0, 1, 0)),
    // Bottom
    Vertex(Position: (1, -1, -1),   Color: (1, 0, 0, 1), Normal: (0, -1, 0)),
    Vertex(Position: (1, -1, 1),    Color: (0, 1, 0, 1), Normal: (0, -1, 0)),
    Vertex(Position: (-1, -1, 1),   Color: (0, 0, 1, 1), Normal: (0, -1, 0)),
    Vertex(Position: (-1, -1, -1),  Color: (0, 0, 0, 1), Normal: (0, -1, 0))

]

var IndicesTrianglesCube:[GLubyte] = [
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 6, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
]
