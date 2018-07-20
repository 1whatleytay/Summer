//
//  SummerMessage.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-28.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// An enum of messages that can be sent to the program.
///
/// - starting: SummerEngine is starting.
/// - looping: SummerEngine will now be drawing to the screen.
/// - swapping: SummerEngine has swapped programs.
/// - aborting: SummerEngine is aborting.
/// - couldNotFindTexture: Could not find an image file.
/// - outOfObjectMemory: Could not allocate an object because there is too little memory.
/// - outOfTransformMemory: Could not allocate a transform because there is too little memory.
/// - outOfTextureMemory: Could not allocate a texture because there is too little memory.
/// - couldNotCreateTileset: Could not create the resources for a tileset.
/// - couldNotLoadTileset: Could not find image files passed to a tileset.
/// - couldNotCreateMap: Could not create the resources for a map.
public enum SummerMessage {
    case starting
    case looping
    case swapping
    case aborting
    
    case couldNotFindTexture
    case outOfObjectMemory
    case outOfTransformMemory
    case outOfTextureMemory
    case couldNotCreateTileset
    case couldNotLoadTileset
    case couldNotCreateMap
}
