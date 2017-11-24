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
#import "Hotkey.h"
#import "Keycodes.h"

@interface AppDelegate ()
@end

@implementation AppDelegate {
    NSStatusItem* item;
    IBOutlet NSMenu* statusItemMenu;
}

- (IBAction) quitApp:(id)sender {
    [NSApp terminate: nil];
}

- (IBAction) runScript:(id)sender {
    [JavaScriptBridge reset];
    [JavaScriptBridge runConfig];
}

- (IBAction) showDocsWindow:(id)sender {
    [[DocsWindowController sharedInstance] showWindow: nil];
}

- (IBAction) showREPL:(id)sender {
    [[ReplWindowController sharedInstance] showWindow: nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Keycodes setup];
    [Hotkey setup];
    
    [JavaScriptBridge runConfig];
    
    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength: NSSquareStatusItemLength];
    item.image = [NSImage imageNamed:@"StatusIcon"];
    item.menu = statusItemMenu;
    
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL trusted = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    NSLog(@"trusted = %d", trusted);
    [Alert show:@"Loading config..." options: nil];
}

@end
