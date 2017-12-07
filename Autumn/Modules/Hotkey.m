//
//  Hotkey.m
//  Autumn
//
//  Created by Steven Degutis on 11/21/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Hotkey.h"
#import "Keyboard.h"
#import <Carbon/Carbon.h>
#import "JS.h"

@implementation Hotkey {
    UInt32 _mods;
    UInt32 _keycode;
    UInt32 _uid;
    JSManagedValue* _callback;
    BOOL _enabled;
    EventHotKeyRef _carbonHotKey;
}

static EventHandlerRef eventHandler;
static UInt32 hotkeysNextKey;
static NSMutableDictionary<NSNumber*, Hotkey*>* hotkeys;

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

- (NSNumber*) equals:(Hotkey*)other {
    return (self == other) ? @YES : @NO;
}

- (BOOL) isEqual:(id)other {
    return [self equals: other].boolValue;
}

- (NSUInteger) hash {
    return (NSUInteger)self;
}

+ (Hotkey*) hotkeyForId:(UInt32)uid {
    return hotkeys[@(uid)];
}

+ (Hotkey*) create:(NSNumber*)mods key:(NSString*)key callback:(JSValue*)callback {
    Hotkey* hotkey = [[Hotkey alloc] init];
    hotkey->_keycode = [[Keyboard keyCodes][key] unsignedIntValue];
    hotkey->_mods = mods.intValue;
    hotkey->_callback = [JSManagedValue managedValueWithValue:callback andOwner:hotkey];
    return [hotkey enable] ? hotkey : nil;
}

- (void) runCallback {
    [_callback.value callWithArguments: @[]];
}

- (NSNumber*) enable {
    if (_enabled)
        return @YES;
    
    _enabled = YES;
    _uid = [Hotkey store: self];
    EventHotKeyID hotKeyID = { .signature = 'MJLN', .id = _uid };
    _carbonHotKey = NULL;
    OSStatus err = RegisterEventHotKey(_keycode, _mods, hotKeyID, GetEventDispatcherTarget(), kEventHotKeyExclusive, &_carbonHotKey);
    return (err != eventHotKeyExistsErr) ? @YES : @NO;
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
    [_callback.value.context.virtualMachine removeManagedReference:_callback withOwner:self];
}

static OSStatus callback(EventHandlerCallRef __attribute__ ((unused)) inHandlerCallRef, EventRef inEvent, void *inUserData) {
    EventHotKeyID eventID;
    GetEventParameter(inEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(eventID), NULL, &eventID);
    
    Hotkey* hotkey = [Hotkey hotkeyForId: eventID.id];
    [hotkey runCallback];
    
    return noErr;
}

+ (void)startModule:(JSValue *)ctor {
    hotkeys = [NSMutableDictionary dictionary];
    
    EventTypeSpec hotKeyPressedSpec[] = {
        {kEventClassKeyboard, kEventHotKeyPressed},
    };
    InstallEventHandler(GetEventDispatcherTarget(),
                        callback,
                        sizeof(hotKeyPressedSpec) / sizeof(EventTypeSpec),
                        hotKeyPressedSpec,
                        NULL,
                        &eventHandler);
    
    ctor[@"Cmd"]   = @(cmdKey);
    ctor[@"Ctrl"]  = @(controlKey);
    ctor[@"Alt"]   = @(optionKey);
    ctor[@"Opt"]   = @(optionKey);
    ctor[@"Shift"] = @(shiftKey);
}

+ (void)stopModule {
    for (Hotkey* hotkey in hotkeys.allValues) {
        [hotkey disable];
    }
    
    RemoveEventHandler(eventHandler);
}

@end
