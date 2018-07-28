//
//  SummerParticles.swift
//  Summer
//
//  Created by Taylor Whatley on 2018-07-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import SummerEngine

class Particle: SummerObject {
    public static var parent: SummerEngine!
    public static var color: SummerTexture!
    public static var instances = [Particle]()
    
    public static var spawnX = Float(0), spawnY = Float(0)
    public static var minSize = 10, maxSize = 30
    
    private var velocityX, velocityY: Float
    
    private func step() {
        x += velocityX
        y += velocityY
        
        velocityX *= 0.98
        velocityY *= 0.98
        
        transform.scale(x: 0.98, y: 0.98)
        transform.rotate(degree: 1)
        transform.opacity *= 0.98
        transform.setOrigin(centerOf: self)
        
        save()
    }
    
    public static func step() { for inst in instances { inst.step() } }
    
    override func delete() {
        super.delete()
        
        transform.delete()
        
        Particle.instances.removeAll { (p) -> Bool in return p === self }
    }
    
    init() {
        let genWidth = Int.random(in: Particle.minSize ... Particle.maxSize),
            genHeight = Int.random(in: Particle.minSize ... Particle.maxSize)
        
        velocityX = Float.random(in: -4 ... 4)
        velocityY = Float.random(in: -4 ... 4)
        
        super.init(Particle.parent,
                   draw: Particle.parent.globalDraw, transform: Particle.parent.globalTransform,
                   x: Particle.spawnX, y: Particle.spawnY, width: Float(genWidth), height: Float(genHeight), texture: Particle.color)
        
        makeTransform()
        setDisposable()
        
        Particle.instances.append(self)
    }
}

class SummerParticles: SummerProgram {
    var engine: SummerEngine!
    
    var red, circle: SummerTexture!
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        circle = engine.makeTexture(fromFile: "circle.png")
        red = engine.makeColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        Particle.parent = engine
        Particle.color = red
        
        Particle.spawnX = Float(Particle.parent.settings.displayWidth / 2)
        Particle.spawnY = Float(Particle.parent.settings.displayHeight / 2)
        
        //engine.beforeUpdateEvents.append { Particle.step() }
    }
    
    func update() {
        Particle.step()
        _ = Particle()
    }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) {
        if state == .pressed && key == .vkL {
            if Particle.color === red {
                Particle.color = circle
            } else {
                Particle.color = red
            }
        }
    }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) {
        if state == .movement {
            Particle.spawnX = Float(x)
            Particle.spawnY = Float(y)
        }
    }
}
