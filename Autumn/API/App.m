//
//  App.m
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "App.h"
#import "Window.h"
#import "FnUtils.h"

@implementation App {
    pid_t _pid;
    AXUIElementRef _app;
    NSRunningApplication* _runningApp;
}

+ (App*) appForPid:(pid_t)pid {
    NSRunningApplication* runningApp = [NSRunningApplication runningApplicationWithProcessIdentifier: pid];
    if (!runningApp) return nil;
    
    App* app = [[App alloc] init];
    app->_pid = pid;
    app->_app = AXUIElementCreateApplication(pid);
    app->_runningApp = runningApp;
    return app;
}

+ (NSArray<App*>*) appsForBundleID:(NSString*)bundleIdentifier {
    NSMutableArray<App*>* matchingApps = [NSMutableArray array];
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    for (NSRunningApplication* runningApp in runningApps) {
        [matchingApps addObject: [App appForPid: [runningApp processIdentifier]]];
    }
    return matchingApps;
}

- (void) dealloc {
    CFRelease(_app);
}

+ (NSArray<App*>*) runningApps {
    NSMutableArray<App*>* apps = [NSMutableArray array];
    for (NSRunningApplication* runningApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
        [apps addObject: [App appForPid: [runningApp processIdentifier]]];
    }
    return apps;
}

- (BOOL) isEqual:(App*)object {
    return ([object isKindOfClass: [App class]] && _pid == object->_pid);
}

- (Window*) mainWindow {
    CFTypeRef window;
    return (AXUIElementCopyAttributeValue(_app, kAXMainWindowAttribute, &window) == kAXErrorSuccess
            ? [[Window alloc] initWithElement: window]
            : nil);
}

- (NSArray<Window*>*) allWindows {
    NSMutableArray<Window*>* returningWindows = [NSMutableArray array];
    CFArrayRef wins;
    AXError result = AXUIElementCopyAttributeValues(_app, kAXWindowsAttribute, 0, 100, &wins);
    if (result == kAXErrorSuccess) {
        for (NSInteger i = 0; i < CFArrayGetCount(wins); i++) {
            AXUIElementRef win = CFArrayGetValueAtIndex(wins, i);
            [returningWindows addObject: [[Window alloc] initWithElement: CFRetain(win)]];
        }
        CFRelease(wins);
    }
    return returningWindows;
}

- (NSArray<Window*>*) visibleWindows {
    return [FnUtils filter:[self allWindows] with:^BOOL(Window* win) {
        return [win isVisible].boolValue;
    }];
}

- (NSNumber*) isUnresponsive {
    // lol apple
    typedef int CGSConnectionID;
    CG_EXTERN CGSConnectionID CGSMainConnectionID(void);
    bool CGSEventIsAppUnresponsive(CGSConnectionID cid, const ProcessSerialNumber *psn);
    // srsly come on now
    
    ProcessSerialNumber psn;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    GetProcessForPID(_pid, &psn);
#pragma clang diagnostic pop
    
    CGSConnectionID conn = CGSMainConnectionID();
    return CGSEventIsAppUnresponsive(conn, &psn) ? @YES : @NO;
}

- (NSString*) title {
    return [_runningApp localizedName];
}

- (NSString*) bundleID {
    return [_runningApp bundleIdentifier];
}

- (void) unhide {
    AXUIElementSetAttributeValue(_app, (CFStringRef)NSAccessibilityHiddenAttribute, kCFBooleanFalse);
}

- (void) hide {
    AXUIElementSetAttributeValue(_app, (CFStringRef)NSAccessibilityHiddenAttribute, kCFBooleanTrue);
}

- (void) kill {
    [_runningApp terminate];
}

- (void) forceKill {
    [_runningApp forceTerminate];
}

- (NSNumber*) isHidden {
    CFBooleanRef isHidden;
    AXUIElementCopyAttributeValue(_app, (CFStringRef)NSAccessibilityHiddenAttribute, (CFTypeRef*)&isHidden);
    return (__bridge_transfer NSNumber*)isHidden;
}

- (pid_t) pid {
    return _pid;
}

- (NSString*) kind {
    switch ([_runningApp activationPolicy]) {
        case NSApplicationActivationPolicyAccessory:  return @"no-dock";
        case NSApplicationActivationPolicyProhibited: return @"no-gui";
        case NSApplicationActivationPolicyRegular:    return @"dock";
    }
}

+ (void) open:(NSString*)name {
    [[NSWorkspace sharedWorkspace] launchApplication: name];
}

- (void) activate:(BOOL)allWindows {
    if ([self isUnresponsive])
        return;
    
    Window* win = [self internal_focusedWindow];
    if (win) {
        [win becomeMain];
        [self internal_bringToFront:allWindows];
    }
    else {
        [self internal_activate: allWindows];
    }
}

// a few private methods for -activate

- (BOOL) internal_activate:(BOOL)allWindows {
    return [_runningApp activateWithOptions:NSApplicationActivateIgnoringOtherApps | (allWindows ? NSApplicationActivateAllWindows : 0)];
}

- (Window*) internal_focusedWindow {
    CFTypeRef window;
    if (AXUIElementCopyAttributeValue(_app, (CFStringRef)NSAccessibilityFocusedWindowAttribute, &window) == kAXErrorSuccess)
        return [[Window alloc] initWithElement: window];
    
    return nil;
}

- (BOOL) internal_bringToFront:(BOOL)allWindows {
    ProcessSerialNumber psn;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    GetProcessForPID(_pid, &psn);
    return (SetFrontProcessWithOptions(&psn, allWindows ? 0 : kSetFrontProcessFrontWindowOnly) == noErr);
#pragma clang diagnostic pop
}

@end
