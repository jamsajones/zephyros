//
//  BindkeyLegacyTranslator.m
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDKeyBindingTranslator.h"

// sigh

enum {
    kVK_ANSI_A                    = 0x00,
    kVK_ANSI_S                    = 0x01,
    kVK_ANSI_D                    = 0x02,
    kVK_ANSI_F                    = 0x03,
    kVK_ANSI_H                    = 0x04,
    kVK_ANSI_G                    = 0x05,
    kVK_ANSI_Z                    = 0x06,
    kVK_ANSI_X                    = 0x07,
    kVK_ANSI_C                    = 0x08,
    kVK_ANSI_V                    = 0x09,
    kVK_ANSI_B                    = 0x0B,
    kVK_ANSI_Q                    = 0x0C,
    kVK_ANSI_W                    = 0x0D,
    kVK_ANSI_E                    = 0x0E,
    kVK_ANSI_R                    = 0x0F,
    kVK_ANSI_Y                    = 0x10,
    kVK_ANSI_T                    = 0x11,
    kVK_ANSI_1                    = 0x12,
    kVK_ANSI_2                    = 0x13,
    kVK_ANSI_3                    = 0x14,
    kVK_ANSI_4                    = 0x15,
    kVK_ANSI_6                    = 0x16,
    kVK_ANSI_5                    = 0x17,
    kVK_ANSI_Equal                = 0x18,
    kVK_ANSI_9                    = 0x19,
    kVK_ANSI_7                    = 0x1A,
    kVK_ANSI_Minus                = 0x1B,
    kVK_ANSI_8                    = 0x1C,
    kVK_ANSI_0                    = 0x1D,
    kVK_ANSI_RightBracket         = 0x1E,
    kVK_ANSI_O                    = 0x1F,
    kVK_ANSI_U                    = 0x20,
    kVK_ANSI_LeftBracket          = 0x21,
    kVK_ANSI_I                    = 0x22,
    kVK_ANSI_P                    = 0x23,
    kVK_ANSI_L                    = 0x25,
    kVK_ANSI_J                    = 0x26,
    kVK_ANSI_Quote                = 0x27,
    kVK_ANSI_K                    = 0x28,
    kVK_ANSI_Semicolon            = 0x29,
    kVK_ANSI_Backslash            = 0x2A,
    kVK_ANSI_Comma                = 0x2B,
    kVK_ANSI_Slash                = 0x2C,
    kVK_ANSI_N                    = 0x2D,
    kVK_ANSI_M                    = 0x2E,
    kVK_ANSI_Period               = 0x2F,
    kVK_ANSI_Grave                = 0x32,
    kVK_ANSI_KeypadDecimal        = 0x41,
    kVK_ANSI_KeypadMultiply       = 0x43,
    kVK_ANSI_KeypadPlus           = 0x45,
    kVK_ANSI_KeypadClear          = 0x47,
    kVK_ANSI_KeypadDivide         = 0x4B,
    kVK_ANSI_KeypadEnter          = 0x4C,
    kVK_ANSI_KeypadMinus          = 0x4E,
    kVK_ANSI_KeypadEquals         = 0x51,
    kVK_ANSI_Keypad0              = 0x52,
    kVK_ANSI_Keypad1              = 0x53,
    kVK_ANSI_Keypad2              = 0x54,
    kVK_ANSI_Keypad3              = 0x55,
    kVK_ANSI_Keypad4              = 0x56,
    kVK_ANSI_Keypad5              = 0x57,
    kVK_ANSI_Keypad6              = 0x58,
    kVK_ANSI_Keypad7              = 0x59,
    kVK_ANSI_Keypad8              = 0x5B,
    kVK_ANSI_Keypad9              = 0x5C
};

/* keycodes for keys that are independent of keyboard layout*/
enum {
    kVK_Return                    = 0x24,
    kVK_Tab                       = 0x30,
    kVK_Space                     = 0x31,
    kVK_Delete                    = 0x33,
    kVK_Escape                    = 0x35,
    kVK_Command                   = 0x37,
    kVK_Shift                     = 0x38,
    kVK_CapsLock                  = 0x39,
    kVK_Option                    = 0x3A,
    kVK_Control                   = 0x3B,
    kVK_RightShift                = 0x3C,
    kVK_RightOption               = 0x3D,
    kVK_RightControl              = 0x3E,
    kVK_Function                  = 0x3F,
    kVK_F17                       = 0x40,
    kVK_VolumeUp                  = 0x48,
    kVK_VolumeDown                = 0x49,
    kVK_Mute                      = 0x4A,
    kVK_F18                       = 0x4F,
    kVK_F19                       = 0x50,
    kVK_F20                       = 0x5A,
    kVK_F5                        = 0x60,
    kVK_F6                        = 0x61,
    kVK_F7                        = 0x62,
    kVK_F3                        = 0x63,
    kVK_F8                        = 0x64,
    kVK_F9                        = 0x65,
    kVK_F11                       = 0x67,
    kVK_F13                       = 0x69,
    kVK_F16                       = 0x6A,
    kVK_F14                       = 0x6B,
    kVK_F10                       = 0x6D,
    kVK_F12                       = 0x6F,
    kVK_F15                       = 0x71,
    kVK_Help                      = 0x72,
    kVK_Home                      = 0x73,
    kVK_PageUp                    = 0x74,
    kVK_ForwardDelete             = 0x75,
    kVK_F4                        = 0x76,
    kVK_End                       = 0x77,
    kVK_F2                        = 0x78,
    kVK_PageDown                  = 0x79,
    kVK_F1                        = 0x7A,
    kVK_LeftArrow                 = 0x7B,
    kVK_RightArrow                = 0x7C,
    kVK_DownArrow                 = 0x7D,
    kVK_UpArrow                   = 0x7E
};

/* ISO keyboards only*/
enum {
    kVK_ISO_Section               = 0x0A
};

/* JIS keyboards only*/
enum {
    kVK_JIS_Yen                   = 0x5D,
    kVK_JIS_Underscore            = 0x5E,
    kVK_JIS_KeypadComma           = 0x5F,
    kVK_JIS_Eisu                  = 0x66,
    kVK_JIS_Kana                  = 0x68
};

@implementation SDKeyBindingTranslator

+ (NSUInteger) keyCodeForString:(NSString*)str {
    str = [str uppercaseString];
    
    // you should prefer typing these in upper-case in your config file,
    // since they look more unique (and less confusing) that way
    
    if ([str isEqualToString:@"A"]) return kVK_ANSI_A;
    if ([str isEqualToString:@"B"]) return kVK_ANSI_B;
    if ([str isEqualToString:@"C"]) return kVK_ANSI_C;
    if ([str isEqualToString:@"D"]) return kVK_ANSI_D;
    if ([str isEqualToString:@"E"]) return kVK_ANSI_E;
    if ([str isEqualToString:@"F"]) return kVK_ANSI_F;
    if ([str isEqualToString:@"G"]) return kVK_ANSI_G;
    if ([str isEqualToString:@"H"]) return kVK_ANSI_H;
    if ([str isEqualToString:@"I"]) return kVK_ANSI_I;
    if ([str isEqualToString:@"J"]) return kVK_ANSI_J;
    if ([str isEqualToString:@"K"]) return kVK_ANSI_K;
    if ([str isEqualToString:@"L"]) return kVK_ANSI_L;
    if ([str isEqualToString:@"M"]) return kVK_ANSI_M;
    if ([str isEqualToString:@"N"]) return kVK_ANSI_N;
    if ([str isEqualToString:@"O"]) return kVK_ANSI_O;
    if ([str isEqualToString:@"P"]) return kVK_ANSI_P;
    if ([str isEqualToString:@"Q"]) return kVK_ANSI_Q;
    if ([str isEqualToString:@"R"]) return kVK_ANSI_R;
    if ([str isEqualToString:@"S"]) return kVK_ANSI_S;
    if ([str isEqualToString:@"T"]) return kVK_ANSI_T;
    if ([str isEqualToString:@"U"]) return kVK_ANSI_U;
    if ([str isEqualToString:@"V"]) return kVK_ANSI_V;
    if ([str isEqualToString:@"W"]) return kVK_ANSI_W;
    if ([str isEqualToString:@"X"]) return kVK_ANSI_X;
    if ([str isEqualToString:@"Y"]) return kVK_ANSI_Y;
    if ([str isEqualToString:@"Z"]) return kVK_ANSI_Z;
    if ([str isEqualToString:@"0"]) return kVK_ANSI_0;
    if ([str isEqualToString:@"1"]) return kVK_ANSI_1;
    if ([str isEqualToString:@"2"]) return kVK_ANSI_2;
    if ([str isEqualToString:@"3"]) return kVK_ANSI_3;
    if ([str isEqualToString:@"4"]) return kVK_ANSI_4;
    if ([str isEqualToString:@"5"]) return kVK_ANSI_5;
    if ([str isEqualToString:@"6"]) return kVK_ANSI_6;
    if ([str isEqualToString:@"7"]) return kVK_ANSI_7;
    if ([str isEqualToString:@"8"]) return kVK_ANSI_8;
    if ([str isEqualToString:@"9"]) return kVK_ANSI_9;
    
    if ([str isEqualToString:@"F1"]) return kVK_F1;
    if ([str isEqualToString:@"F2"]) return kVK_F2;
    if ([str isEqualToString:@"F3"]) return kVK_F3;
    if ([str isEqualToString:@"F4"]) return kVK_F4;
    if ([str isEqualToString:@"F5"]) return kVK_F5;
    if ([str isEqualToString:@"F6"]) return kVK_F6;
    if ([str isEqualToString:@"F7"]) return kVK_F7;
    if ([str isEqualToString:@"F8"]) return kVK_F8;
    if ([str isEqualToString:@"F9"]) return kVK_F9;
    if ([str isEqualToString:@"F10"]) return kVK_F10;
    if ([str isEqualToString:@"F11"]) return kVK_F11;
    if ([str isEqualToString:@"F12"]) return kVK_F12;
    if ([str isEqualToString:@"F13"]) return kVK_F13;
    if ([str isEqualToString:@"F14"]) return kVK_F14;
    if ([str isEqualToString:@"F15"]) return kVK_F15;
    if ([str isEqualToString:@"F16"]) return kVK_F16;
    if ([str isEqualToString:@"F17"]) return kVK_F17;
    if ([str isEqualToString:@"F18"]) return kVK_F18;
    if ([str isEqualToString:@"F19"]) return kVK_F19;
    if ([str isEqualToString:@"F20"]) return kVK_F20;
    
    if ([str isEqualToString:@"`"]) return kVK_ANSI_Grave;
    if ([str isEqualToString:@"="]) return kVK_ANSI_Equal;
    if ([str isEqualToString:@"-"]) return kVK_ANSI_Minus;
    if ([str isEqualToString:@"]"]) return kVK_ANSI_RightBracket;
    if ([str isEqualToString:@"["]) return kVK_ANSI_LeftBracket;
    if ([str isEqualToString:@"'"]) return kVK_ANSI_Quote;
    if ([str isEqualToString:@";"]) return kVK_ANSI_Semicolon;
    if ([str isEqualToString:@"\\"]) return kVK_ANSI_Backslash;
    if ([str isEqualToString:@","]) return kVK_ANSI_Comma;
    if ([str isEqualToString:@"/"]) return kVK_ANSI_Slash;
    if ([str isEqualToString:@"."]) return kVK_ANSI_Period;
    
    // you should prefer typing these in lower-case in your config file,
    // since there's no concern for ambiguity/confusion with words, just with chars.
    
    if ([str isEqualToString:@"PAD."]) return kVK_ANSI_KeypadDecimal;
    if ([str isEqualToString:@"PAD*"]) return kVK_ANSI_KeypadMultiply;
    if ([str isEqualToString:@"PAD+"]) return kVK_ANSI_KeypadPlus;
    if ([str isEqualToString:@"PAD/"]) return kVK_ANSI_KeypadDivide;
    if ([str isEqualToString:@"PAD-"]) return kVK_ANSI_KeypadMinus;
    if ([str isEqualToString:@"PAD="]) return kVK_ANSI_KeypadEquals;
    if ([str isEqualToString:@"PAD0"]) return kVK_ANSI_Keypad0;
    if ([str isEqualToString:@"PAD1"]) return kVK_ANSI_Keypad1;
    if ([str isEqualToString:@"PAD2"]) return kVK_ANSI_Keypad2;
    if ([str isEqualToString:@"PAD3"]) return kVK_ANSI_Keypad3;
    if ([str isEqualToString:@"PAD4"]) return kVK_ANSI_Keypad4;
    if ([str isEqualToString:@"PAD5"]) return kVK_ANSI_Keypad5;
    if ([str isEqualToString:@"PAD6"]) return kVK_ANSI_Keypad6;
    if ([str isEqualToString:@"PAD7"]) return kVK_ANSI_Keypad7;
    if ([str isEqualToString:@"PAD8"]) return kVK_ANSI_Keypad8;
    if ([str isEqualToString:@"PAD9"]) return kVK_ANSI_Keypad9;
    if ([str isEqualToString:@"PAD_CLEAR"]) return kVK_ANSI_KeypadClear;
    if ([str isEqualToString:@"PAD_ENTER"]) return kVK_ANSI_KeypadEnter;
    
    if ([str isEqualToString:@"RETURN"]) return kVK_Return;
    if ([str isEqualToString:@"TAB"]) return kVK_Tab;
    if ([str isEqualToString:@"SPACE"]) return kVK_Space;
    if ([str isEqualToString:@"DELETE"]) return kVK_Delete;
    if ([str isEqualToString:@"ESCAPE"]) return kVK_Escape;
    if ([str isEqualToString:@"HELP"]) return kVK_Help;
    if ([str isEqualToString:@"HOME"]) return kVK_Home;
    if ([str isEqualToString:@"PAGE_UP"]) return kVK_PageUp;
    if ([str isEqualToString:@"FORWARD_DELETE"]) return kVK_ForwardDelete;
    if ([str isEqualToString:@"END"]) return kVK_End;
    if ([str isEqualToString:@"PAGE_DOWN"]) return kVK_PageDown;
    if ([str isEqualToString:@"LEFT"]) return kVK_LeftArrow;
    if ([str isEqualToString:@"RIGHT"]) return kVK_RightArrow;
    if ([str isEqualToString:@"DOWN"]) return kVK_DownArrow;
    if ([str isEqualToString:@"UP"]) return kVK_UpArrow;
    
//    // aww, this would have been really cool. oh well.
//    if ([str isEqualToString:@"VOL_UP"]) return kVK_VolumeUp;
//    if ([str isEqualToString:@"VOL_DOWN"]) return kVK_VolumeDown;
//    if ([str isEqualToString:@"RIGHT_SHIFT"]) return kVK_RightShift;
    
    // TODO: make this do something smarter than return -1 for unknowns
    
    return -1;
}

+ (NSUInteger) modifierFlagsForStrings:(NSArray*)strs {
    strs = [strs valueForKeyPath:@"uppercaseString"];
    
    NSUInteger result = 0;
    
    if ([strs containsObject:@"SHIFT"]) result |= NSShiftKeyMask;
    if ([strs containsObject:@"CTRL"]) result |= NSControlKeyMask;
    if ([strs containsObject:@"ALT"]) result |= NSAlternateKeyMask;
    if ([strs containsObject:@"CMD"]) result |= NSCommandKeyMask;
    
    return result;
}

@end
