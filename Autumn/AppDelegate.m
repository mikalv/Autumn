//
//  AppDelegate.m
//  Autumn
//
//  Created by Steven Degutis on 11/14/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "AppDelegate.h"

#import "Autumn.h"
#import "JS.h"
#import "Alert.h"

@implementation AppDelegate {
    NSStatusItem* item;
    IBOutlet NSMenu* statusItemMenu;
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL trusted = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    NSLog(@"trusted = %d", trusted);
    
    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength: NSSquareStatusItemLength];
    item.image = [NSImage imageNamed:@"StatusIcon"];
    item.menu = statusItemMenu;
    
    [Alert show:@"Loading config..." options: nil];
    [JS runConfig];
}

@end
