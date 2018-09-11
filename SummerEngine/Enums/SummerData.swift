//
//  SummerData.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-11.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// The location of a file path.
///
/// - folder: The file path is global.
/// - bundle: The file path is relative to the application.
public enum SummerFileLocation {
    case folder
    case bundle
}

public enum SummerFilter {
    case linear
    case nearest
}
