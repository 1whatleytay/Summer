//
//  SummerResourceList.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-08-17.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// Represents a list of resources that make up an object.
public struct SummerResourceList {
    /// The objects that make up this resource.
    public var objects: [SummerObject?]
    /// The textures that make up this resource.
    public var textures: [SummerTexture?]
    /// The transforms that make up this resource.
    public var transforms: [SummerTransform?]
    /// The draws that make up this resource.
    public var draws: [SummerDraw?]
    /// More resources that make up this resource.
    public var resources: [SummerResource?]
    
    internal func allocate(_ engine: SummerEngine) {
        for nObject in objects {
            guard let object = nObject else { continue }
            if object.isDisposable { continue }
            object.allocate()
            object.texture.allocate()
            if object.transform.isGlobal {
                object.transform = engine.globalTransform
            } else {
                object.transform.allocate()
            }
            if object.draw.isGlobal {
                engine.globalDraw.addObject(object)
            } else {
                engine.draws.append(object.draw)
            }
        }
        for texture in textures { texture?.allocate() }
        for transform in transforms { transform?.allocate() }
        for nDraw in draws {
            guard let draw = nDraw else { continue }
            engine.draws.append(draw)
        }
        for resource in resources {
            resource?.resourceList().allocate(engine)
        }
    }
    
    /// Constructor.
    ///
    /// - Parameters:
    ///   - objects: The objects that make up this resource.
    ///   - textures: The textures that make up this resource.
    ///   - transforms: The transforms that make up this resource.
    ///   - draws: The draws that make up this resource.
    ///   - resources: More resources that make up this resource.
    public init(objects: [SummerObject?] = [],
         textures: [SummerTexture?] = [],
         transforms: [SummerTransform?] = [],
         draws: [SummerDraw?] = [],
         resources: [SummerResource?] = []) {
        self.objects = objects
        self.textures = textures
        self.transforms = transforms
        self.draws = draws
        self.resources = resources
    }
}
