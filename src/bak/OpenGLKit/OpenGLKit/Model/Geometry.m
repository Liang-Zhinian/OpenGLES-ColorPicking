//
//  Geometry.m
//  OpenGL Visible Surface Demo
//
//  Created by Christoph Halang on 28/02/15.
//  Copyright (c) 2015 Christoph Halang. All rights reserved.
//

#import "Geometry.h"

// the vertex data consists of Position, Color, Texture Coordinates and Normal

const Vertex VerticesCube[] = {
    /*
    // Front
    {{1, -1, 1},    {1, 0, 0, 1}, {0, 1},               {0, 0, 1}},
    {{1, 1, 1},     {1, 0, 0, 1}, {0, 2.0/3.0},         {0, 0, 1}},
    {{-1, 1, 1},    {1, 0, 0, 1}, {1.0/3.0, 2.0/3.0},   {0, 0, 1}},
    {{-1, -1, 1},   {1, 0, 0, 1}, {1.0/3.0, 1},         {0, 0, 1}},
    // Back
    {{1, 1, -1},    {1, 0, 0, 1}, {1.0/3.0, 1},         {0, 0, -1}},
    {{1, -1, -1},   {1, 0, 0, 1}, {1.0/3.0, 2.0/3.0},   {0, 0, -1}},
    {{-1, -1, -1},  {1, 0, 0, 1}, {2.0/3.0, 2.0/3.0},   {0, 0, -1}},
    {{-1, 1, -1},   {1, 0, 0, 1}, {2.0/3.0, 1},         {0, 0, -1}},
    // Left
    {{-1, -1, 1},   {0, 1, 0, 1}, {2.0/3.0, 1},         {-1, 0, 0}},
    {{-1, 1, 1},    {0, 1, 0, 1}, {2.0/3.0, 2.0/3.0},   {-1, 0, 0}},
    {{-1, 1, -1},   {0, 1, 0, 1}, {1, 2.0/3.0},         {-1, 0, 0}},
    {{-1, -1, -1},  {0, 1, 0, 1}, {1, 1},               {-1, 0, 0}},
    // Right
    {{1, -1, -1},   {0, 1, 0, 1}, {0, 2.0/3.0},         {1, 0, 0}},
    {{1, 1, -1},    {0, 1, 0, 1}, {0, 1.0/3.0},         {1, 0, 0}},
    {{1, 1, 1},     {0, 1, 0, 1}, {1.0/3.0, 1.0/3.0},   {1, 0, 0}},
    {{1, -1, 1},    {0, 1, 0, 1}, {1.0/3.0, 2.0/3.0},   {1, 0, 0}},
    // Top
    {{1, 1, 1},     {0, 0, 1, 1}, {1.0/3.0, 2.0/3.0},   {0, 1, 0}},
    {{1, 1, -1},    {0, 0, 1, 1}, {1.0/3.0, 1.0/3.0},   {0, 1, 0}},
    {{-1, 1, -1},   {0, 0, 1, 1}, {2.0/3.0, 1.0/3.0},   {0, 1, 0}},
    {{-1, 1, 1},    {0, 0, 1, 1}, {2.0/3.0, 2.0/3.0},   {0, 1, 0}},
    // Bottom
    {{1, -1, -1},   {0, 0, 1, 1}, {2.0/3.0, 2.0/3.0},   {0, -1, 0}},
    {{1, -1, 1},    {0, 0, 1, 1}, {2.0/3.0, 1.0/3.0},   {0, -1, 0}},
    {{-1, -1, 1},   {0, 0, 1, 1}, {1, 1.0/3.0},         {0, -1, 0}},
    {{-1, -1, -1},  {0, 0, 1, 1}, {1, 2.0/3.0},         {0, -1, 0}}
    */
    
    // Front
    {{1, -1, 1},    {1, 0, 0, 1}, {0, 1},               {0, 0, 1}},
    {{1, 1, 1},     {0, 1, 0, 1}, {0, 2.0/3.0},         {0, 0, 1}},
    {{-1, 1, 1},    {0, 0, 1, 1}, {1.0/3.0, 2.0/3.0},   {0, 0, 1}},
    {{-1, -1, 1},   {0, 0, 0, 1}, {1.0/3.0, 1},         {0, 0, 1}},
    // Back
    {{1, 1, -1},    {1, 0, 0, 1}, {1.0/3.0, 1},         {0, 0, -1}},
    {{1, -1, -1},   {0, 0, 1, 1}, {1.0/3.0, 2.0/3.0},   {0, 0, -1}},
    {{-1, -1, -1},  {0, 1, 0, 1}, {2.0/3.0, 2.0/3.0},   {0, 0, -1}},
    {{-1, 1, -1},   {0, 0, 0, 1}, {2.0/3.0, 1},         {0, 0, -1}},
    // Left
    {{-1, -1, 1},   {1, 0, 0, 1}, {2.0/3.0, 1},         {-1, 0, 0}},
    {{-1, 1, 1},    {0, 1, 0, 1}, {2.0/3.0, 2.0/3.0},   {-1, 0, 0}},
    {{-1, 1, -1},   {0, 0, 1, 1}, {1, 2.0/3.0},         {-1, 0, 0}},
    {{-1, -1, -1},  {0, 0, 0, 1}, {1, 1},               {-1, 0, 0}},
    // Right
    {{1, -1, -1},   {1, 0, 0, 1}, {0, 2.0/3.0},         {1, 0, 0}},
    {{1, 1, -1},    {0, 1, 0, 1}, {0, 1.0/3.0},         {1, 0, 0}},
    {{1, 1, 1},     {0, 0, 1, 1}, {1.0/3.0, 1.0/3.0},   {1, 0, 0}},
    {{1, -1, 1},    {0, 0, 0, 1}, {1.0/3.0, 2.0/3.0},   {1, 0, 0}},
    // Top
    {{1, 1, 1},     {1, 0, 0, 1}, {1.0/3.0, 2.0/3.0},   {0, 1, 0}},
    {{1, 1, -1},    {0, 1, 0, 1}, {1.0/3.0, 1.0/3.0},   {0, 1, 0}},
    {{-1, 1, -1},   {0, 0, 1, 1}, {2.0/3.0, 1.0/3.0},   {0, 1, 0}},
    {{-1, 1, 1},    {0, 0, 0, 1}, {2.0/3.0, 2.0/3.0},   {0, 1, 0}},
    // Bottom
    {{1, -1, -1},   {1, 0, 0, 1}, {2.0/3.0, 2.0/3.0},   {0, -1, 0}},
    {{1, -1, 1},    {0, 1, 0, 1}, {2.0/3.0, 1.0/3.0},   {0, -1, 0}},
    {{-1, -1, 1},   {0, 0, 1, 1}, {1, 1.0/3.0},         {0, -1, 0}},
    {{-1, -1, -1},  {0, 0, 0, 1}, {1, 2.0/3.0},         {0, -1, 0}}
      
};

const GLubyte IndicesTrianglesCube[] = {
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
};
