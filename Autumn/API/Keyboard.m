//
//  Keycodes.m
//  Autumn
//
//  Created by Steven Degutis on 11/22/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Keyboard.h"
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

static JSValue* layoutChangedCallback;
static NSMutableDictionary* keyCodes;

@implementation Keyboard

+ (void) setupOnce {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputSourceChanged:)
                                                 name:NSTextInputContextKeyboardSelectionDidChangeNotification
                                               object:nil];
    
    [self recacheKeycodes];
}

+ (void) reset {
    [self layoutChanged: nil];
}

+ (void) inputSourceChanged:(NSNotification*)note {
    [self recacheKeycodes];
    
    if (layoutChangedCallback) {
        [layoutChangedCallback callWithArguments:@[]];
    }
}

+ (void) layoutChanged:(JSValue*)fn {
    layoutChangedCallback = fn;
}

+ (NSDictionary*) keyCodes {
    return keyCodes;
}

+ (void) recacheKeycodes {
    keyCodes = [NSMutableDictionary dictionary];
    
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
            
            keyCodes[name] = @(relocatableKeyCodes[i]);
        }
    }
    else {
        keyCodes[@"a"] = @(kVK_ANSI_A);
        keyCodes[@"b"] = @(kVK_ANSI_B);
        keyCodes[@"c"] = @(kVK_ANSI_C);
        keyCodes[@"d"] = @(kVK_ANSI_D);
        keyCodes[@"e"] = @(kVK_ANSI_E);
        keyCodes[@"f"] = @(kVK_ANSI_F);
        keyCodes[@"g"] = @(kVK_ANSI_G);
        keyCodes[@"h"] = @(kVK_ANSI_H);
        keyCodes[@"i"] = @(kVK_ANSI_I);
        keyCodes[@"j"] = @(kVK_ANSI_J);
        keyCodes[@"k"] = @(kVK_ANSI_K);
        keyCodes[@"l"] = @(kVK_ANSI_L);
        keyCodes[@"m"] = @(kVK_ANSI_M);
        keyCodes[@"n"] = @(kVK_ANSI_N);
        keyCodes[@"o"] = @(kVK_ANSI_O);
        keyCodes[@"p"] = @(kVK_ANSI_P);
        keyCodes[@"q"] = @(kVK_ANSI_Q);
        keyCodes[@"r"] = @(kVK_ANSI_R);
        keyCodes[@"s"] = @(kVK_ANSI_S);
        keyCodes[@"t"] = @(kVK_ANSI_T);
        keyCodes[@"u"] = @(kVK_ANSI_U);
        keyCodes[@"v"] = @(kVK_ANSI_V);
        keyCodes[@"w"] = @(kVK_ANSI_W);
        keyCodes[@"x"] = @(kVK_ANSI_X);
        keyCodes[@"y"] = @(kVK_ANSI_Y);
        keyCodes[@"z"] = @(kVK_ANSI_Z);
        keyCodes[@"0"] = @(kVK_ANSI_0);
        keyCodes[@"1"] = @(kVK_ANSI_1);
        keyCodes[@"2"] = @(kVK_ANSI_2);
        keyCodes[@"3"] = @(kVK_ANSI_3);
        keyCodes[@"4"] = @(kVK_ANSI_4);
        keyCodes[@"5"] = @(kVK_ANSI_5);
        keyCodes[@"6"] = @(kVK_ANSI_6);
        keyCodes[@"7"] = @(kVK_ANSI_7);
        keyCodes[@"8"] = @(kVK_ANSI_8);
        keyCodes[@"9"] = @(kVK_ANSI_9);
        keyCodes[@"`"] = @(kVK_ANSI_Grave);
        keyCodes[@"="] = @(kVK_ANSI_Equal);
        keyCodes[@"-"] = @(kVK_ANSI_Minus);
        keyCodes[@"]"] = @(kVK_ANSI_RightBracket);
        keyCodes[@"["] = @(kVK_ANSI_LeftBracket);
        keyCodes[@"\""] = @(kVK_ANSI_Quote);
        keyCodes[@";"] = @(kVK_ANSI_Semicolon);
        keyCodes[@"\\"] = @(kVK_ANSI_Backslash);
        keyCodes[@","] = @(kVK_ANSI_Comma);
        keyCodes[@"/"] = @(kVK_ANSI_Slash);
        keyCodes[@"."] = @(kVK_ANSI_Period);
    }
    
    CFRelease(currentKeyboard);
    
    keyCodes[@"f1"] = @(kVK_F1);
    keyCodes[@"f2"] = @(kVK_F2);
    keyCodes[@"f3"] = @(kVK_F3);
    keyCodes[@"f4"] = @(kVK_F4);
    keyCodes[@"f5"] = @(kVK_F5);
    keyCodes[@"f6"] = @(kVK_F6);
    keyCodes[@"f7"] = @(kVK_F7);
    keyCodes[@"f8"] = @(kVK_F8);
    keyCodes[@"f9"] = @(kVK_F9);
    keyCodes[@"f10"] = @(kVK_F10);
    keyCodes[@"f11"] = @(kVK_F11);
    keyCodes[@"f12"] = @(kVK_F12);
    keyCodes[@"f13"] = @(kVK_F13);
    keyCodes[@"f14"] = @(kVK_F14);
    keyCodes[@"f15"] = @(kVK_F15);
    keyCodes[@"f16"] = @(kVK_F16);
    keyCodes[@"f17"] = @(kVK_F17);
    keyCodes[@"f18"] = @(kVK_F18);
    keyCodes[@"f19"] = @(kVK_F19);
    keyCodes[@"f20"] = @(kVK_F20);
    
    keyCodes[@"pad."] = @(kVK_ANSI_KeypadDecimal);
    keyCodes[@"pad*"] = @(kVK_ANSI_KeypadMultiply);
    keyCodes[@"pad+"] = @(kVK_ANSI_KeypadPlus);
    keyCodes[@"pad/"] = @(kVK_ANSI_KeypadDivide);
    keyCodes[@"pad-"] = @(kVK_ANSI_KeypadMinus);
    keyCodes[@"pad="] = @(kVK_ANSI_KeypadEquals);
    keyCodes[@"pad0"] = @(kVK_ANSI_Keypad0);
    keyCodes[@"pad1"] = @(kVK_ANSI_Keypad1);
    keyCodes[@"pad2"] = @(kVK_ANSI_Keypad2);
    keyCodes[@"pad3"] = @(kVK_ANSI_Keypad3);
    keyCodes[@"pad4"] = @(kVK_ANSI_Keypad4);
    keyCodes[@"pad5"] = @(kVK_ANSI_Keypad5);
    keyCodes[@"pad6"] = @(kVK_ANSI_Keypad6);
    keyCodes[@"pad7"] = @(kVK_ANSI_Keypad7);
    keyCodes[@"pad8"] = @(kVK_ANSI_Keypad8);
    keyCodes[@"pad9"] = @(kVK_ANSI_Keypad9);
    keyCodes[@"padclear"] = @(kVK_ANSI_KeypadClear);
    keyCodes[@"padenter"] = @(kVK_ANSI_KeypadEnter);
    
    keyCodes[@"return"] = @(kVK_Return);
    keyCodes[@"tab"] = @(kVK_Tab);
    keyCodes[@"space"] = @(kVK_Space);
    keyCodes[@"delete"] = @(kVK_Delete);
    keyCodes[@"escape"] = @(kVK_Escape);
    keyCodes[@"help"] = @(kVK_Help);
    keyCodes[@"home"] = @(kVK_Home);
    keyCodes[@"pageup"] = @(kVK_PageUp);
    keyCodes[@"forwarddelete"] = @(kVK_ForwardDelete);
    keyCodes[@"end"] = @(kVK_End);
    keyCodes[@"pagedown"] = @(kVK_PageDown);
    keyCodes[@"left"] = @(kVK_LeftArrow);
    keyCodes[@"right"] = @(kVK_RightArrow);
    keyCodes[@"down"] = @(kVK_DownArrow);
    keyCodes[@"up"] = @(kVK_UpArrow);
}

@end
