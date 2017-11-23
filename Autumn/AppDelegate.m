//
//  AppDelegate.m
//  Autumn
//
//  Created by Steven Degutis on 11/14/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "AppDelegate.h"
#import "JavaScriptBridge.h"

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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Keycodes setup];
    [Hotkey setup];
    
    [Alert show:@"Loading config..." duration: NAN];
    [JavaScriptBridge runConfig];
    
    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength: NSSquareStatusItemLength];
    item.image = [NSImage imageNamed:@"StatusIcon"];
    item.menu = statusItemMenu;
    
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL trusted = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    NSLog(@"trusted = %d", trusted);
}

@end
