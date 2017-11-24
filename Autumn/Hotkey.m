//
//  Hotkey.m
//  Autumn
//
//  Created by Steven Degutis on 11/21/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Hotkey.h"
#import "Keycodes.h"
#import <Carbon/Carbon.h>

@implementation Hotkey {
    UInt32 _mods;
    UInt32 _keycode;
    UInt32 _uid;
    JSManagedValue* _pressedFn;
    JSManagedValue* _releasedFn;
    BOOL _enabled;
    EventHotKeyRef _carbonHotKey;
}

static UInt32 hotkeysNextKey;
static NSMutableDictionary* hotkeys;

+ (UInt32) store:(Hotkey*)hotkey {
    UInt32 i = hotkeysNextKey++;
    hotkeys[@(i)] = hotkey;
    return i;
}

+ (void) unstore:(UInt32)uid {
    [hotkeys removeObjectForKey:@(uid)];
    if (hotkeys.count == 0) {
        // not 100% safe from duplicates but close enough
        hotkeysNextKey = 0;
    }
}

+ (Hotkey*) hotkeyForId:(UInt32)uid {
    return hotkeys[@(uid)];
}

+ (void) resetHandlers {
    hotkeys = [NSMutableDictionary dictionary];
    hotkeysNextKey = 0;
}

- (instancetype) initWithMap:(JSValue*)spec {
    if (self = [super init]) {
        NSString* key = [spec[@"key"] toString];
        _keycode = [[Keycodes map][key] unsignedIntValue];
        
        JSValue* mods = spec[@"mods"];
        if ([mods[@"cmd"] toBool])   _mods |= cmdKey;
        if ([mods[@"ctrl"] toBool])  _mods |= controlKey;
        if ([mods[@"alt"] toBool])   _mods |= optionKey;
        if ([mods[@"shift"] toBool]) _mods |= shiftKey;
        
        JSValue* pressed = spec[@"pressed"];
        JSValue* released = spec[@"released"];
        
        _pressedFn = pressed.isObject ? [JSManagedValue managedValueWithValue:pressed andOwner:self] : nil;
        _releasedFn = released.isObject ? [JSManagedValue managedValueWithValue:released andOwner:self] : nil;
    }
    return self;
}

- (void) runCallback:(BOOL)stateIsPressed {
    JSManagedValue* fn = stateIsPressed ? _pressedFn : _releasedFn;
    if (fn) {
        [fn.value callWithArguments: @[]];
    }
}

- (BOOL) enable {
    if (_enabled)
        return YES;
    
    _enabled = YES;
    _uid = [Hotkey store: self];
    EventHotKeyID hotKeyID = { .signature = 'MJLN', .id = _uid };
    _carbonHotKey = NULL;
    OSStatus err = RegisterEventHotKey(_keycode, _mods, hotKeyID, GetEventDispatcherTarget(), kEventHotKeyExclusive, &_carbonHotKey);
    return err != eventHotKeyExistsErr;
}

- (void) disable {
    if (!_enabled)
        return;
    
    _enabled = NO;
    [Hotkey unstore: _uid];
    UnregisterEventHotKey(_carbonHotKey);
}

- (void) dealloc {
    [self disable];
    
    [_pressedFn.value.context.virtualMachine removeManagedReference:_pressedFn withOwner:self];
    [_releasedFn.value.context.virtualMachine removeManagedReference:_releasedFn withOwner:self];
}

static OSStatus callback(EventHandlerCallRef __attribute__ ((unused)) inHandlerCallRef, EventRef inEvent, void *inUserData) {
    EventHotKeyID eventID;
    GetEventParameter(inEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(eventID), NULL, &eventID);
    
    Hotkey* hotkey = [Hotkey hotkeyForId: eventID.id];
    [hotkey runCallback: GetEventKind(inEvent) == kEventHotKeyPressed];
    
    return noErr;
}

+ (void) setup {
    [self resetHandlers];
    
    EventTypeSpec hotKeyPressedSpec[] = {
        {kEventClassKeyboard, kEventHotKeyPressed},
        {kEventClassKeyboard, kEventHotKeyReleased},
    };
    InstallEventHandler(GetEventDispatcherTarget(),
                        callback,
                        sizeof(hotKeyPressedSpec) / sizeof(EventTypeSpec),
                        hotKeyPressedSpec,
                        NULL,
                        NULL);
}

@end
