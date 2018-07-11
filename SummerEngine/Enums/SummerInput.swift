//
//  SummerInput.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-10.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

public enum SummerInputState {
    case pressed
    case released
    case movement
}

public enum SummerMouseButton {
    case left
    case right
    case other
    case movement
}

public enum SummerKey: UInt16 {
    case vkA = 0x00
    case vkB = 0x0B
    case vkC = 0x08
    case vkD = 0x02
    case vkE = 0x0E
    case vkF = 0x03
    case vkG = 0x05
    case vkH = 0x04
    case vkI = 0x22
    case vkJ = 0x26
    case vkK = 0x28
    case vkL = 0x25
    case vkM = 0x2E
    case vkN = 0x2D
    case vkO = 0x1F
    case vkP = 0x23
    case vkQ = 0x0C
    case vkR = 0x0F
    case vkS = 0x01
    case vkT = 0x11
    case vkU = 0x20
    case vkV = 0x09
    case vkW = 0x0D
    case vkX = 0x07
    case vkY = 0x10
    case vkZ = 0x06
    
    case vk1 = 0x12
    case vk2 = 0x13
    case vk3 = 0x14
    case vk4 = 0x15
    case vk5 = 0x17
    case vk6 = 0x16
    case vk7 = 0x1A
    case vk8 = 0x1C
    case vk9 = 0x19
    case vk0 = 0x1D
    
    case vkEqual = 0x18
    case vkMinus = 0x1B
    
    case vkLeftBracket = 0x21
    case vkRightBracket = 0x1E
    
    case vkQuote = 0x27
    case vkSemicolon = 0x29
    case vkBackslash = 0x2A
    case vkComma = 0x2B
    case vkSlash = 0x2C
    case vkPeriod = 0x2F
    
    case vkGrave = 0x32
    
    case vkKeypadDecimal = 0x41
    case vkKeypadPlus = 0x45
    case vkKeypadMinus = 0x4E
    case vkKeypadDivide = 0x4B
    case vkKeypadMultiply = 0x43
    case vkKeypadEquals = 0x51
    case vkKeypadEnter = 0x4C
    case vkKeypadClear = 0x47
    
    case vkKeypad1 = 0x53
    case vkKeypad2 = 0x54
    case vkKeypad3 = 0x55
    case vkKeypad4 = 0x56
    case vkKeypad5 = 0x57
    case vkKeypad6 = 0x58
    case vkKeypad7 = 0x59
    case vkKeypad8 = 0x5B
    case vkKeypad9 = 0x5C
    case vkKeypad0 = 0x52
    
    case vkReturn = 0x24
    case vkTab = 0x30
    case vkSpace = 0x31
    case vkDelete = 0x33
    case vkEscape = 0x35
    case vkCommand = 0x37
    case vkShift = 0x38
    case vkCapsLock = 0x39
    case vkOption = 0x3A
    case vkControl = 0x3B
    case vkRightCommand = 0x36
    case vkRightShift = 0x3C
    case vkRightOption = 0x3D
    case vkRightControl = 0x3E
    case vkFunction = 0x3F
    case vkForwardDelete = 0x75
    
    case vkLeft = 0x7B
    case vkRight = 0x7C
    case vkUp = 0x7E
    case vkDown = 0x7D
    
    case vkVolumeUp = 0x48
    case vkVolumeDown = 0x49
    case vkMute = 0x4A
    
    case vkPageUp = 0x74
    case vkPageDown = 0x79
    
    case vkHelp = 0x72
    case vkHome = 0x73
    case vkEnd = 0x77
    
    case vkF1 = 0x7A
    case vkF2 = 0x78
    case vkF3 = 0x63
    case vkF4 = 0x76
    case vkF5 = 0x60
    case vkF6 = 0x61
    case vkF7 = 0x62
    case vkF8 = 0x64
    case vkF9 = 0x65
    case vkF10 = 0x6D
    case vkF11 = 0x67
    case vkF12 = 0x6F
    case vkF13 = 0x69
    case vkF14 = 0x6B
    case vkF15 = 0x71
    case vkF16 = 0x6A
    case vkF17 = 0x40
    case vkF18 = 0x4F
    case vkF19 = 0x50
    case vkF20 = 0x5A
    
    case vkUnknown = 0xFF
}
