//
//  SummerResource.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-08-17.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// When implemented, programs can take more control over the resources of the implementing class.
public protocol SummerResource {
    /// Returns a list of different resources used by this object.
    ///
    /// - Returns: A list of different resources used by this object.
    func resourceList() -> SummerResourceList
}
