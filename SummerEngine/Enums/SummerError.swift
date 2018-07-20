//
//  SummerError.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-28.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

/// An enum of errors that can be thrown while creating a SummerEngine object.
///
/// - cannotCreateDevice: Could not create a metal device on this platform.
/// - cannotCreateResources: Could not create metal resources.
/// - noDefaultLibrary: Could not find a default library.
/// - viewInUse: The view object is already in use by another SummerEngine.
public enum SummerError: Error {
    case cannotCreateDevice
    case cannotCreateResources
    case noDefaultLibrary
    case viewInUse
}
