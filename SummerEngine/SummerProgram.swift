//
//  SummerProgram.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

public protocol SummerProgram {
    func info() -> SummerInfo
    
    func setup(engine: SummerEngine)
    func update()
    
    func message(message: SummerMessage)
    
    func key()
}
