//
//  Autumn.m
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Core.h"

#import <Cocoa/Cocoa.h>
#import "JS.h"
#import "Env.h"
#import "ReplWindowController.h"

@implementation Core

+ (void) quit {
    [NSApp terminate: nil];
}

+ (void) reloadConfigs {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Env reset];
    });
}

+ (void) showDocs {
    [NSApp activateIgnoringOtherApps:YES];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://sdegutis.github.io/Autumn/"]];
}

+ (void) showRepl {
    [NSApp activateIgnoringOtherApps:YES];
    [[ReplWindowController sharedInstance] showWindow: nil];
}

+ (JSValue*) loadFile:(NSString*)path {
    return [Env.current.js loadFile: path];
}

+ (void)startModule:(JSValue *)ctor {
}

+ (void)stopModule {
}

@end
