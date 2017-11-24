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
#import "DocsWindowController.h"
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
    [[DocsWindowController sharedInstance] showWindow: nil];
}

+ (void) showRepl {
    [NSApp activateIgnoringOtherApps:YES];
    [[ReplWindowController sharedInstance] showWindow: nil];
}

@end
