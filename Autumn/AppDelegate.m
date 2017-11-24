//
//  AppDelegate.m
//  Autumn
//
//  Created by Steven Degutis on 11/14/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "AppDelegate.h"

#import "JavaScriptBridge.h"

#import "DocsWindowController.h"
#import "ReplWindowController.h"

#import "Alert.h"

@implementation AppDelegate {
    NSStatusItem* item;
    IBOutlet NSMenu* statusItemMenu;
}

- (IBAction) quitApp:(id)sender {
    [NSApp terminate: nil];
}

- (IBAction) runScript:(id)sender {
    [JavaScriptBridge runConfig];
}

- (IBAction) showDocsWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[DocsWindowController sharedInstance] showWindow: nil];
}

- (IBAction) showREPL:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[ReplWindowController sharedInstance] showWindow: nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL trusted = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    NSLog(@"trusted = %d", trusted);
    
    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength: NSSquareStatusItemLength];
    item.image = [NSImage imageNamed:@"StatusIcon"];
    item.menu = statusItemMenu;
    
    [Alert show:@"Loading config..." options: nil];
    [JavaScriptBridge runConfig];
}

@end
