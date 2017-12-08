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
    
    [_js loadFile: Env.userConfigPath];
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

+ (NSString*) userConfigPath {
    return @"~/.autumnjs/init.js".stringByStandardizingPath;
}

+ (void) copySampleConfigs {
    NSString* configDir = @"~/.autumnjs/".stringByStandardizingPath;
    NSString* configInFile = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"js"];
    NSString* configOutFile = [configDir stringByAppendingPathComponent: @"init.js"];
    
    NSString* typingInFile = [[NSBundle mainBundle] pathForResource:@"types" ofType:@"ts"];
    NSString* typingOutFile = [configDir stringByAppendingPathComponent: @"/node_modules/@types/autumnjs/index.d.ts"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath: typingOutFile.stringByDeletingLastPathComponent
                              withIntermediateDirectories: YES
                                               attributes: nil
                                                    error: NULL];
    
    [[NSFileManager defaultManager] copyItemAtPath: typingInFile
                                            toPath: typingOutFile
                                             error: NULL];
    
    [[NSFileManager defaultManager] copyItemAtPath: configInFile
                                            toPath: configOutFile
                                             error: NULL];
    
    [[NSWorkspace sharedWorkspace] selectFile: configOutFile
                     inFileViewerRootedAtPath: configDir];
    
    [self reset];
}

@end
