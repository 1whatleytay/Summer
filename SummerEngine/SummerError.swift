//
//  SummerError.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-28.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

public enum SummerError: Error {
    case cannotCreateDevice
    case cannotCreateQueue
    case noDefaultLibrary
    case cannotCreatePipelineState
    case cannotCreateObjectBuffer
    case cannotCreateTexture
    case viewInUse
}
