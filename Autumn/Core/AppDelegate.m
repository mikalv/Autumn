//
//  AppDelegate.m
//  Autumn
//
//  Created by Steven Degutis on 11/14/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "AppDelegate.h"

#import "Autumn.h"
#import "Env.h"
#import "JS.h"
#import "Alert.h"
#import "LoginLauncher.h"

@implementation AppDelegate {
    NSStatusItem* item;
    IBOutlet NSMenu* statusItemMenu;
    __weak IBOutlet NSMenuItem* launchAtLoginMenuItem;
    __weak IBOutlet NSMenuItem* enableAccessibilityMenuItem;
}

- (IBAction) quitApp:(id)sender {
    [Autumn quit];
}

- (IBAction) runScript:(id)sender {
    [Autumn reloadConfigs];
}

- (IBAction) showDocsWindow:(id)sender {
    [Autumn showDocs];
}

- (IBAction) showREPL:(id)sender {
    [Autumn showRepl];
}

- (IBAction) toggleLaunchAtLogin:(NSMenuItem*)sender {
    [LoginLauncher setEnabled: sender.state != NSOnState];
}

- (IBAction) enableAccessibility:(id)sender {
    [self maybeEnableAccessibility];
}

- (IBAction) showCredits:(id)sender {
    [NSApp activateIgnoringOtherApps: YES];
    [NSApp orderFrontStandardAboutPanel: nil];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem == enableAccessibilityMenuItem) {
        return ![self isAccessibilityEnabled];
    }
    return YES;
}

- (void)menuWillOpen:(NSMenu *)menu {
    launchAtLoginMenuItem.state = [LoginLauncher isEnabled] ? NSOnState : NSOffState;
    
    BOOL accessibilityEnabled = [self isAccessibilityEnabled];
    enableAccessibilityMenuItem.image = [NSImage imageNamed: accessibilityEnabled ? NSImageNameStatusAvailable : NSImageNameStatusPartiallyAvailable];
    enableAccessibilityMenuItem.title = accessibilityEnabled ? @"Accessibility is enabled" : @"Enable Accessibility";
}

- (BOOL) isAccessibilityEnabled {
    return AXIsProcessTrustedWithOptions(NULL);
}

- (void) maybeEnableAccessibility {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self maybeEnableAccessibility];
    
    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength: NSSquareStatusItemLength];
    item.image = [NSImage imageNamed:@"StatusIcon"];
    item.menu = statusItemMenu;
    
    [Alert show:@"Loading config..." options: nil];
    [Env setupOnce];
    [JS runConfig];
}

@end
