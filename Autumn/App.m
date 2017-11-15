//
//  App.m
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "App.h"
#import "Window.h"

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

/// Returns any running apps that have the given bundleID.
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

/// Returns all running apps.
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

/// Returns the main window of the given app, or nil.
- (Window*) mainWindow {
    CFTypeRef window;
    return (AXUIElementCopyAttributeValue(_app, kAXMainWindowAttribute, &window) == kAXErrorSuccess
            ? [[Window alloc] initWithElement: window]
            : nil);
}

/// Returns all open windows owned by the given app.
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

- (BOOL) isUnresponsive {
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
    return CGSEventIsAppUnresponsive(conn, &psn);
}

- (BOOL) internal_bringToFront:(BOOL)allwindows {
    ProcessSerialNumber psn;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    GetProcessForPID(_pid, &psn);
    return (SetFrontProcessWithOptions(&psn, allwindows ? 0 : kSetFrontProcessFrontWindowOnly) == noErr);
#pragma clang diagnostic pop
}

/// Returns the localized name of the app (in UTF8).
- (NSString*) title {
    return [_runningApp localizedName];
}

/// Returns the bundle identifier of the app.
- (NSString*) bundleID {
    return [_runningApp bundleIdentifier];
}

/// Unhides the app (and all its windows) if it's hidden.
- (BOOL) unhide {
    return (AXUIElementSetAttributeValue(_app, (CFStringRef)NSAccessibilityHiddenAttribute, kCFBooleanFalse) == kAXErrorSuccess);
}

/// Hides the app (and all its windows).
- (BOOL) hide {
    return (AXUIElementSetAttributeValue(_app, (CFStringRef)NSAccessibilityHiddenAttribute, kCFBooleanTrue) == kAXErrorSuccess);
}

/// Tries to terminate the app.
- (void) kill {
    [_runningApp terminate];
}

/// Definitely terminates the app.
- (void) forceKill {
    [_runningApp forceTerminate];
}

/// Returns whether the app is currently hidden.
- (BOOL) isHidden {
    CFBooleanRef isHidden;
    AXUIElementCopyAttributeValue(_app, (CFStringRef)NSAccessibilityHiddenAttribute, (CFTypeRef*)&isHidden);
    return CFBooleanGetValue(isHidden);
}

/// Returns the app's process identifier.
- (pid_t) pid {
    return _pid;
}

/// Returns the string 'dock' if the app is in the dock, 'no-dock' if not, and 'no-gui' if it can't even have GUI elements if it wanted to.
- (NSString*) kind {
    switch ([_runningApp activationPolicy]) {
        case NSApplicationActivationPolicyAccessory:  return @"no-dock";
        case NSApplicationActivationPolicyProhibited: return @"no-gui";
        case NSApplicationActivationPolicyRegular:    return @"dock";
    }
}

/// Launches the app with the given name, or activates it if it's already running.
/// Returns true if it launched or was already launched; otherwise false (presumably only if the app doesn't exist).
- (BOOL) launchOrFocus:(NSString*)name {
    return [[NSWorkspace sharedWorkspace] launchApplication: name];
}

@end
