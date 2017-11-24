//
//  JavaScriptBridge.m
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "JavaScriptBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Window.h"
#import "App.h"
#import "Hotkey.h"
#import "Alert.h"

static JSContext* ctx;

@implementation JavaScriptBridge

+ (void) runConfig {
    [self reset];
    
    NSString* pwd = [@"~/.autumnjs/" stringByStandardizingPath];
    NSString* configFile = [pwd stringByAppendingPathComponent:@"init.js"];
    NSString* script = [NSString stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:NULL];
    
    [ctx evaluateScript: script];
}

+ (void) setup {
    JSVirtualMachine* vm = [[JSVirtualMachine alloc] init];
    ctx = [[JSContext alloc] initWithVirtualMachine: vm];
    
    ctx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"JS exception: %@", exception);
    };
    
    ctx[@"Window"] = [Window class];
    ctx[@"App"] = [App class];
    ctx[@"Hotkey"] = [Hotkey class];
    ctx[@"Alert"] = [Alert class];
    
    ctx[@"console"][@"log"] = ^(id x) {
        NSLog(@"CONSOLE.LOG: %@", x);
    };
}

+ (void) destroy {
    [Hotkey resetHandlers];
}

+ (void) reset {
    [self destroy];
    [self setup];
}

@end
