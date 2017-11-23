//
//  Window.m
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "Window.h"
#import "App.h"
#import "FnUtils.h"

/// Functions for managing any window.
///
/// To get windows, see `Window.focusedWindow` and `Window.visibleWindows`.
///
/// To get window geometrical attributes, see `Window.{frame,size,topleft}`.
///
/// To move and resize windows, see `Window.set{frame,size,topleft}`.
///
/// It may be handy to get a window's app or screen via `Window.app` and `Window.screen`.
///
/// See the `Screen` class for detailed explanation of how Mjolnir uses window/screen coordinates.

@implementation Window {
    AXUIElementRef _win;
    NSNumber* _id;
}

static AXUIElementRef system_wide_element() {
    static AXUIElementRef element;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        element = AXUIElementCreateSystemWide();
    });
    return element;
}

- (instancetype) initWithElement:(AXUIElementRef)element {
    if (self = [super init]) {
        _win = element;
    }
    return self;
}

- (void) dealloc {
    CFRelease(_win);
}

+ (Window*) focusedWindow {
    CFTypeRef app;
    AXUIElementCopyAttributeValue(system_wide_element(), kAXFocusedApplicationAttribute, &app);
    if (!app) return nil;
    
    CFTypeRef win;
    AXError result = AXUIElementCopyAttributeValue(app, (CFStringRef)NSAccessibilityFocusedWindowAttribute, &win);
    CFRelease(app);
    
    return (result == kAXErrorSuccess) ? [[Window alloc] initWithElement: win] : nil;
}

/// Returns all windows
+ (NSArray<Window*>*) allWindows {
    return [FnUtils flatMap:[App runningApps] with:^NSArray*(App* app) {
        return [app allWindows];
    }];
}

/// Returns the window for the given id, or nil if it's an invalid id.
+ (Window*) windowForID:(NSNumber*)winid {
    return [FnUtils findIn:[Window allWindows] where:^BOOL(Window* win) {
        return [win.windowID isEqualToNumber: winid];
    }];
}

- (id) getWindowProp:(NSString*)propType {
    CFTypeRef _someProperty;
    if (AXUIElementCopyAttributeValue(_win, (CFStringRef)propType, &_someProperty) == kAXErrorSuccess)
        return CFBridgingRelease(_someProperty);
    
    return nil;
}

- (NSString*) title {
    return [self getWindowProp: NSAccessibilityTitleAttribute];
}

- (NSString*) subrole {
    return [self getWindowProp: NSAccessibilitySubroleAttribute];
}

- (NSString*) role {
    return [self getWindowProp: NSAccessibilityRoleAttribute];
}

- (BOOL) isStandardWindow {
    return [[self subrole] isEqualToString: (NSString*)kAXStandardWindowSubrole];
}

/// The top-left corner of the window in absolute coordinates.
- (NSPoint) topLeft {
    AXValueRef positionStorage = NULL;
    AXError result = AXUIElementCopyAttributeValue(_win, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef*)&positionStorage);
    if (result == kAXErrorSuccess && positionStorage) {
        CGPoint topLeft;
        AXValueGetValue(positionStorage, kAXValueCGPointType, &topLeft);
        CFRelease(positionStorage);
        return topLeft;
    }
    return CGPointZero;
}

/// The size of the window.
- (NSSize) size {
    AXValueRef intermediate = NULL;
    AXError result = AXUIElementCopyAttributeValue(_win, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef*)&intermediate);
    if (result == kAXErrorSuccess && intermediate) {
        CGSize size;
        AXValueGetValue(intermediate, kAXValueCGSizeType, &size);
        CFRelease(intermediate);
        return size;
    }
    return CGSizeZero;
}

/// Moves the window to the given point in absolute coordinate.
- (void) setTopLeft:(NSPoint)thePoint {
    CFTypeRef positionStorage = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
    AXUIElementSetAttributeValue(_win, (CFStringRef)NSAccessibilityPositionAttribute, positionStorage);
    CFRelease(positionStorage);
}

- (BOOL) isEqual:(Window*)object {
    return ([object isKindOfClass: [Window class]] && CFEqual(_win, object->_win));
}

/// Resizes the window.
- (void) setSize:(NSSize)theSize {
    CFTypeRef intermediate = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
    AXUIElementSetAttributeValue(_win, (CFStringRef)NSAccessibilitySizeAttribute, intermediate);
    CFRelease(intermediate);
}

/// Closes the window; returns whether it succeeded.
- (BOOL) close {
    BOOL worked = NO;
    AXUIElementRef button = NULL;
    
    if (AXUIElementCopyAttributeValue(_win, kAXCloseButtonAttribute, (CFTypeRef*)&button) != kAXErrorSuccess) goto cleanup;
    if (AXUIElementPerformAction(button, kAXPressAction) != kAXErrorSuccess) goto cleanup;
    worked = YES;
    
cleanup:
    if (button) CFRelease(button);
    return worked;
}

/// Sets whether the window is full screen; returns whether it succeeded.
- (BOOL) setFullScreen:(BOOL)shouldBeFullScreen {
    return (AXUIElementSetAttributeValue(_win, CFSTR("AXFullScreen"), shouldBeFullScreen ? kCFBooleanTrue : kCFBooleanFalse) == kAXErrorSuccess);
}

/// Returns whether the window is full screen, or nil if asking that question fails.
- (NSNumber*) isFullScreen {
    CFBooleanRef fullscreen;
    if (AXUIElementCopyAttributeValue(_win, CFSTR("AXFullScreen"), (CFTypeRef*)&fullscreen) != kAXErrorSuccess) return nil;
    return (__bridge NSNumber*)fullscreen;
}

/// Minimizes the window; returns whether it succeeded.
- (BOOL) minimize {
    return (AXUIElementSetAttributeValue(_win, (CFStringRef)(NSAccessibilityMinimizedAttribute), kCFBooleanTrue) == kAXErrorSuccess);
}

/// Un-minimizes the window; returns whether it succeeded.
- (BOOL) unminimize {
    return (AXUIElementSetAttributeValue(_win, (CFStringRef)(NSAccessibilityMinimizedAttribute), kCFBooleanFalse) == kAXErrorSuccess);
}

/// Returns whether the window is currently minimized in the dock.
- (NSNumber*) isMinimized {
    CFBooleanRef isMinimized;
    if (AXUIElementCopyAttributeValue(_win, (CFStringRef)(NSAccessibilityMinimizedAttribute), (CFTypeRef*)&isMinimized) != kAXErrorSuccess) return nil;
    return (__bridge NSNumber*)isMinimized;
}

- (NSNumber*) pid {
    pid_t pid;
    if (AXUIElementGetPid(_win, &pid) != kAXErrorSuccess) return nil;
    return @(pid);
}

/// True if the app is not hidden and the window is not minimized.
/// NOTE: some apps (e.g. in Adobe Creative Cloud) have literally-invisible windows and also like to put them very far offscreen; this method may return true for such windows.
- (BOOL) isVisible {
    return !self.app.isHidden && !self.isMinimized;
}

/// Make this window the main window of the given application; deos not implicitly focus the app.
- (BOOL) becomeMain {
    return (AXUIElementSetAttributeValue(_win, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue) == kAXErrorSuccess);
}

/// Returns a unique number identifying this window.
- (NSNumber*) windowID {
    if (_id) return _id;
    CGWindowID winid;
    extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);
    AXError err = _AXUIElementGetWindow(_win, &winid);
    if (err) return nil;
    return _id = @(winid);
}

+ (NSArray<NSNumber*>*) orderedWindowIDs {
    NSMutableArray<NSNumber*>* winids = [NSMutableArray array];
    
    CFArrayRef wins = CGWindowListCreate(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    
    for (int i = 0; i < CFArrayGetCount(wins); i++) {
        int winid = (int)CFArrayGetValueAtIndex(wins, i);
        [winids addObject: @(winid)];
    }
    
    CFRelease(wins);
    
    return winids;
}

/// Returns the app that the window belongs to; may be nil.
- (App*) app {
    NSNumber* pid = [self pid];
    if (!pid) return nil;
    return [App appForPid: [pid intValue]];
}

/// Get the frame of the window in absolute coordinates.
- (NSRect) frame {
    NSSize s = self.size;
    NSPoint p = self.topLeft;
    return NSMakeRect(p.x, p.y, s.width, s.height);
}

/// Set the frame of the window in absolute coordinates.
- (void) setFrame:(NSRect)frame {
    [self setSize: frame.size];
    [self setTopLeft: frame.origin];
    [self setSize: frame.size];
}

@end
