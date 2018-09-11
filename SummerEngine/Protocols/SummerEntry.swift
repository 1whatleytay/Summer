//
//  SummerEntry.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-08-16.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// An extended program that takes control over the features and settings of the engine.
public protocol SummerEntry: SummerProgram {
    /// Returns a features object.
    /// Summer Engine will use these features if possible.
    ///
    /// - Returns: A features object.
    func features() -> SummerFeatures
    
    /// Returns a settings object.
    /// Summer Engine will always use these settings.
    ///
    /// - Returns: A settings object.
    func settings() -> SummerSettings
}
