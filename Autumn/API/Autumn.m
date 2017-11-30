//
//  Autumn.m
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Autumn.h"

#import <Cocoa/Cocoa.h>
#import "JS.h"
#import "ReplWindowController.h"

@implementation Autumn

+ (void) quit {
    [NSApp terminate: nil];
}

+ (void) reloadConfigs {
    [JS runConfig];
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
    return [JS loadFile: path];
}

@end
