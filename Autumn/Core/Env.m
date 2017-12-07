//
//  Env.m
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Env.h"

#import "Core.h"
#import "Alert.h"
#import "Hotkey.h"
#import "Keyboard.h"
#import "App.h"
#import "Window.h"
#import "Screen.h"
#import "Notification.h"

#import "JS.h"

#import "Module.h"

static Env* env;

@interface Env ()
@property (readwrite) JS* js;
@end

@implementation Env

+ (Env*) current {
    return env;
}

- (NSArray<id<Module>>*) modules {
    return (id)@[[Core class],
                 [Alert class],
                 [Hotkey class],
                 [Keyboard class],
                 [App class],
                 [Window class],
                 [Screen class],
                 [Notification class]];
}

- (void) start {
    _js = [[JS alloc] init];
    
    for (id<Module> module in [self modules]) {
        JSValue* moduleNamespace = [_js addModule: module];
        [module startModule: moduleNamespace];
    }
    
    [_js loadUserConfig];
}

- (void) stop {
    for (id<Module> module in [self modules]) {
        [module stopModule];
    }
}

+ (void) reset {
    [env stop];
    env = [[Env alloc] init];
    [env start];
}

@end
