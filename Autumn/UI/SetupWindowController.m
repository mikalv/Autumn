//
//  SetupWindowController.m
//  Autumn
//
//  Created by Steven Degutis on 12/7/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "SetupWindowController.h"
#import "Accessibility.h"
#import "Env.h"

@interface SetupWindowController ()

@property Accessibility* accessibility;
@property BOOL canCopySampleConfigs;

@end

static SetupWindowController* singleton;

@implementation SetupWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.canCopySampleConfigs = ![[NSFileManager defaultManager] fileExistsAtPath: Env.userConfigPath];
    self.accessibility = [Accessibility sharedAccessibility];
    
    [self.window center];
    self.window.movableByWindowBackground = YES;
    [NSApp activateIgnoringOtherApps: YES];
}

- (NSString*) windowNibName {
    return [self className];
}

- (IBAction) enableAccessibility:(id)sender {
    [Accessibility openPanel];
}

- (IBAction) startWithSampleConfigs:(id)sender {
    self.canCopySampleConfigs = NO;
    [Env copySampleConfigs];
}

- (void) windowWillClose:(NSNotification *)notification {
    singleton = nil;
}

+ (void) show {
    if (!singleton) {
        singleton = [[SetupWindowController alloc] init];
    }
    
    [singleton showWindow: nil];
}

@end

@interface AccessibilityEnabledImageValueTransformer : NSValueTransformer
@end
@implementation AccessibilityEnabledImageValueTransformer
- (NSImage*)transformedValue:(NSNumber*)enabled {
    return [NSImage imageNamed: enabled.boolValue ? NSImageNameStatusAvailable : NSImageNameStatusPartiallyAvailable];
}
@end

@interface AccessibilityEnabledTitleValueTransformer : NSValueTransformer
@end
@implementation AccessibilityEnabledTitleValueTransformer
- (NSString*)transformedValue:(NSNumber*)enabled {
    return enabled.boolValue ? @"Accessibility is Enabled" : @"Enable Accessibility";
}
@end
