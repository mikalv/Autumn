//
//  Keycodes.m
//  Autumn
//
//  Created by Steven Degutis on 11/22/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Keycodes.h"
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

static JSValue* inputSourceChangedCallback;
static NSMutableDictionary* map;

@implementation Keycodes

+ (void) setup {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputSourceChanged:)
                                                 name:NSTextInputContextKeyboardSelectionDidChangeNotification
                                               object:nil];
    
    [self recacheKeycodes];
}

+ (void) inputSourceChanged:(NSNotification*)note {
    [self recacheKeycodes];
    
    if (inputSourceChangedCallback) {
        [inputSourceChangedCallback callWithArguments:@[]];
    }
}

+ (void) setInputSourceChangedHandler:(JSValue*)fn {
    inputSourceChangedCallback = fn;
}

+ (NSDictionary*) map {
    return map;
}

+ (void) recacheKeycodes {
    map = [NSMutableDictionary dictionary];
    
    int relocatableKeyCodes[] = {
        kVK_ANSI_A, kVK_ANSI_B, kVK_ANSI_C, kVK_ANSI_D, kVK_ANSI_E, kVK_ANSI_F,
        kVK_ANSI_G, kVK_ANSI_H, kVK_ANSI_I, kVK_ANSI_J, kVK_ANSI_K, kVK_ANSI_L,
        kVK_ANSI_M, kVK_ANSI_N, kVK_ANSI_O, kVK_ANSI_P, kVK_ANSI_Q, kVK_ANSI_R,
        kVK_ANSI_S, kVK_ANSI_T, kVK_ANSI_U, kVK_ANSI_V, kVK_ANSI_W, kVK_ANSI_X,
        kVK_ANSI_Y, kVK_ANSI_Z, kVK_ANSI_0, kVK_ANSI_1, kVK_ANSI_2, kVK_ANSI_3,
        kVK_ANSI_4, kVK_ANSI_5, kVK_ANSI_6, kVK_ANSI_7, kVK_ANSI_8, kVK_ANSI_9,
        kVK_ANSI_Grave, kVK_ANSI_Equal, kVK_ANSI_Minus, kVK_ANSI_RightBracket,
        kVK_ANSI_LeftBracket, kVK_ANSI_Quote, kVK_ANSI_Semicolon, kVK_ANSI_Backslash,
        kVK_ANSI_Comma, kVK_ANSI_Slash, kVK_ANSI_Period,
    };
    
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData = TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
    
    if (layoutData) {
        const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
        UInt32 keysDown = 0;
        UniChar chars[4];
        UniCharCount realLength;
        
        for (int i = 0 ; i < (int)(sizeof(relocatableKeyCodes)/sizeof(relocatableKeyCodes[0])) ; i++) {
            UCKeyTranslate(keyboardLayout,
                           relocatableKeyCodes[i],
                           kUCKeyActionDisplay,
                           0,
                           LMGetKbdType(),
                           kUCKeyTranslateNoDeadKeysBit,
                           &keysDown,
                           sizeof(chars) / sizeof(chars[0]),
                           &realLength,
                           chars);
            
            NSString* name = [NSString stringWithCharacters:chars length:1];
            
            map[name] = @(relocatableKeyCodes[i]);
        }
    }
    else {
        map[@"a"] = @(kVK_ANSI_A);
        map[@"b"] = @(kVK_ANSI_B);
        map[@"c"] = @(kVK_ANSI_C);
        map[@"d"] = @(kVK_ANSI_D);
        map[@"e"] = @(kVK_ANSI_E);
        map[@"f"] = @(kVK_ANSI_F);
        map[@"g"] = @(kVK_ANSI_G);
        map[@"h"] = @(kVK_ANSI_H);
        map[@"i"] = @(kVK_ANSI_I);
        map[@"j"] = @(kVK_ANSI_J);
        map[@"k"] = @(kVK_ANSI_K);
        map[@"l"] = @(kVK_ANSI_L);
        map[@"m"] = @(kVK_ANSI_M);
        map[@"n"] = @(kVK_ANSI_N);
        map[@"o"] = @(kVK_ANSI_O);
        map[@"p"] = @(kVK_ANSI_P);
        map[@"q"] = @(kVK_ANSI_Q);
        map[@"r"] = @(kVK_ANSI_R);
        map[@"s"] = @(kVK_ANSI_S);
        map[@"t"] = @(kVK_ANSI_T);
        map[@"u"] = @(kVK_ANSI_U);
        map[@"v"] = @(kVK_ANSI_V);
        map[@"w"] = @(kVK_ANSI_W);
        map[@"x"] = @(kVK_ANSI_X);
        map[@"y"] = @(kVK_ANSI_Y);
        map[@"z"] = @(kVK_ANSI_Z);
        map[@"0"] = @(kVK_ANSI_0);
        map[@"1"] = @(kVK_ANSI_1);
        map[@"2"] = @(kVK_ANSI_2);
        map[@"3"] = @(kVK_ANSI_3);
        map[@"4"] = @(kVK_ANSI_4);
        map[@"5"] = @(kVK_ANSI_5);
        map[@"6"] = @(kVK_ANSI_6);
        map[@"7"] = @(kVK_ANSI_7);
        map[@"8"] = @(kVK_ANSI_8);
        map[@"9"] = @(kVK_ANSI_9);
        map[@"`"] = @(kVK_ANSI_Grave);
        map[@"="] = @(kVK_ANSI_Equal);
        map[@"-"] = @(kVK_ANSI_Minus);
        map[@"]"] = @(kVK_ANSI_RightBracket);
        map[@"["] = @(kVK_ANSI_LeftBracket);
        map[@"\""] = @(kVK_ANSI_Quote);
        map[@";"] = @(kVK_ANSI_Semicolon);
        map[@"\\"] = @(kVK_ANSI_Backslash);
        map[@","] = @(kVK_ANSI_Comma);
        map[@"/"] = @(kVK_ANSI_Slash);
        map[@"."] = @(kVK_ANSI_Period);
    }
    
    CFRelease(currentKeyboard);
    
    map[@"f1"] = @(kVK_F1);
    map[@"f2"] = @(kVK_F2);
    map[@"f3"] = @(kVK_F3);
    map[@"f4"] = @(kVK_F4);
    map[@"f5"] = @(kVK_F5);
    map[@"f6"] = @(kVK_F6);
    map[@"f7"] = @(kVK_F7);
    map[@"f8"] = @(kVK_F8);
    map[@"f9"] = @(kVK_F9);
    map[@"f10"] = @(kVK_F10);
    map[@"f11"] = @(kVK_F11);
    map[@"f12"] = @(kVK_F12);
    map[@"f13"] = @(kVK_F13);
    map[@"f14"] = @(kVK_F14);
    map[@"f15"] = @(kVK_F15);
    map[@"f16"] = @(kVK_F16);
    map[@"f17"] = @(kVK_F17);
    map[@"f18"] = @(kVK_F18);
    map[@"f19"] = @(kVK_F19);
    map[@"f20"] = @(kVK_F20);
    
    map[@"pad."] = @(kVK_ANSI_KeypadDecimal);
    map[@"pad*"] = @(kVK_ANSI_KeypadMultiply);
    map[@"pad+"] = @(kVK_ANSI_KeypadPlus);
    map[@"pad/"] = @(kVK_ANSI_KeypadDivide);
    map[@"pad-"] = @(kVK_ANSI_KeypadMinus);
    map[@"pad="] = @(kVK_ANSI_KeypadEquals);
    map[@"pad0"] = @(kVK_ANSI_Keypad0);
    map[@"pad1"] = @(kVK_ANSI_Keypad1);
    map[@"pad2"] = @(kVK_ANSI_Keypad2);
    map[@"pad3"] = @(kVK_ANSI_Keypad3);
    map[@"pad4"] = @(kVK_ANSI_Keypad4);
    map[@"pad5"] = @(kVK_ANSI_Keypad5);
    map[@"pad6"] = @(kVK_ANSI_Keypad6);
    map[@"pad7"] = @(kVK_ANSI_Keypad7);
    map[@"pad8"] = @(kVK_ANSI_Keypad8);
    map[@"pad9"] = @(kVK_ANSI_Keypad9);
    map[@"padclear"] = @(kVK_ANSI_KeypadClear);
    map[@"padenter"] = @(kVK_ANSI_KeypadEnter);
    
    map[@"return"] = @(kVK_Return);
    map[@"tab"] = @(kVK_Tab);
    map[@"space"] = @(kVK_Space);
    map[@"delete"] = @(kVK_Delete);
    map[@"escape"] = @(kVK_Escape);
    map[@"help"] = @(kVK_Help);
    map[@"home"] = @(kVK_Home);
    map[@"pageup"] = @(kVK_PageUp);
    map[@"forwarddelete"] = @(kVK_ForwardDelete);
    map[@"end"] = @(kVK_End);
    map[@"pagedown"] = @(kVK_PageDown);
    map[@"left"] = @(kVK_LeftArrow);
    map[@"right"] = @(kVK_RightArrow);
    map[@"down"] = @(kVK_DownArrow);
    map[@"up"] = @(kVK_UpArrow);
}

@end
