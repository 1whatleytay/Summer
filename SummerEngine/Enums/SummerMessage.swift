//
//  SummerMessage.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-28.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

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
