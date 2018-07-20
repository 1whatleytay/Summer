//
//  SummerInput.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-10.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// Input states for keyboard and mouse.
///
/// - pressed: Button is pressed.
/// - released: Button is released.
/// - movement: Mouse is being moved.
public enum SummerInputState {
    case pressed
    case released
    case movement
}

/// Mouse buttons.
///
/// - left: The left mouse button.
/// - right: The right mouse button.
/// - other: The middle mouse button.
/// - movement: The mouse is being moved.
public enum SummerMouseButton {
    case left
    case right
    case other
    case movement
}

/// A key on the keyboard.
///
/// - vkA: The A key.
/// - vkB: The B key.
/// - vkC: The C key.
/// - vkD: The D key.
/// - vkE: The E key.
/// - vkF: The F key.
/// - vkG: The G key.
/// - vkH: The H key.
/// - vkI: The I key.
/// - vkJ: The J key.
/// - vkK: The K key.
/// - vkL: The L key.
/// - vkM: The M key.
/// - vkN: The N key.
/// - vkO: The O key.
/// - vkP: The P key.
/// - vkQ: The Q key.
/// - vkR: The R key.
/// - vkS: The S key.
/// - vkT: The T key.
/// - vkU: The U key.
/// - vkV: The V key.
/// - vkW: The W key.
/// - vkX: The X key.
/// - vkY: The Y key.
/// - vkZ: The Z key.
/// - vk1: The 1 key.
/// - vk2: The 2 key.
/// - vk3: The 3 key.
/// - vk4: The 4 key.
/// - vk5: The 5 key.
/// - vk6: The 6 key.
/// - vk7: The 7 key.
/// - vk8: The 8 key.
/// - vk9: The 9 key.
/// - vk0: The 0 key.
/// - vkEqual: The equals key.
/// - vkMinus: The minus key.
/// - vkLeftBracket: The left bracket key.
/// - vkRightBracket: The right bracket key.
/// - vkQuote: The quote key.
/// - vkSemicolon: The semicolor key.
/// - vkBackslash: The backslash key.
/// - vkComma: The comma key.
/// - vkSlash: The slash key.
/// - vkPeriod: The period key.
/// - vkGrave: The grave key.
/// - vkKeypadDecimal: The keypad-decimal key.
/// - vkKeypadPlus: The keypad-plus key.
/// - vkKeypadMinus: The keypad-minus key.
/// - vkKeypadMultiply: The keypad-muliply key.
/// - vkKeypadDivide: The keypad-divide key.
/// - vkKeypadEquals: The keypad-equals key.
/// - vkKeypadEnter: The keypad-enter key.
/// - vkKeypadClear: The keypad-clear key.
/// - vkKeypad1: The keypad-1 key.
/// - vkKeypad2: The keypad-2 key.
/// - vkKeypad3: The keypad-3 key.
/// - vkKeypad4: The keypad-4 key.
/// - vkKeypad5: The keypad-5 key.
/// - vkKeypad6: The keypad-6 key.
/// - vkKeypad7: The keypad-7 key.
/// - vkKeypad8: The keypad-8 key.
/// - vkKeypad9: The keypad-9 key.
/// - vkKeypad0: The keypad-0 key.
/// - vkReturn: The keypad-return key.
/// - vkTab: The tab key.
/// - vkSpace: The space key.
/// - vkDelete: The delete key.
/// - vkEscape: The escape key.
/// - vkCommand: The command key.
/// - vkShift: The shift key.
/// - vkCapsLock: The caps lock key.
/// - vkOption: The option key.
/// - vkControl: The control key.
/// - vkRightCommand: The right command key.
/// - vkRightShift: The right shift key.
/// - vkRightOption: The right option key.
/// - vkRightControl: The right control key.
/// - vkFunction: The function key.
/// - vkForwardDelete: The forward delete key.
/// - vkLeft: The left key.
/// - vkRight: The right key.
/// - vkUp: The up key.
/// - vkDown: The down key.
/// - vkVolumeUp: The volume up key.
/// - vkVolumeDown: The volume down key.
/// - vkMute: The mute key.
/// - vkPageUp: The page up key.
/// - vkPageDown: The page down key.
/// - vkHelp: The help key.
/// - vkHome: The homekey
/// - vkEnd: The end key.
/// - vkF1: The F1 key.
/// - vkF2: The F2 key.
/// - vkF3: The F3 key.
/// - vkF4: The F4 key.
/// - vkF5: The F5 key.
/// - vkF6: The F6 key.
/// - vkF7: The F7 key.
/// - vkF8: The F8 key.
/// - vkF9: The F9 key.
/// - vkF10: The F10 key.
/// - vkF11: The F11 key.
/// - vkF12: The F12 key.
/// - vkF13: The F13 key.
/// - vkF14: The F14 key.
/// - vkF15: The F15 key.
/// - vkF16: The F16 key.
/// - vkF17: The F17 key.
/// - vkF18: The F18 key.
/// - vkF19: The F19 key.
/// - vkF20: The F20 key.
/// - vkUnknown: An unknown key was pressed.
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
    case vkKeypadMultiply = 0x43
    case vkKeypadDivide = 0x4B
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
    
    case vkUnknown = 0xFE
}
