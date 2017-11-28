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

+ (NSArray<Window*>*) allWindows {
    return [FnUtils flatMap:[App runningApps] with:^NSArray*(App* app) {
        return [app allWindows];
    }];
}

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

- (void) setTopLeft:(NSPoint)thePoint {
    CFTypeRef positionStorage = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
    AXUIElementSetAttributeValue(_win, (CFStringRef)NSAccessibilityPositionAttribute, positionStorage);
    CFRelease(positionStorage);
}

- (BOOL) isEqual:(Window*)object {
    return ([object isKindOfClass: [Window class]] && CFEqual(_win, object->_win));
}

- (void) setSize:(NSSize)theSize {
    CFTypeRef intermediate = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
    AXUIElementSetAttributeValue(_win, (CFStringRef)NSAccessibilitySizeAttribute, intermediate);
    CFRelease(intermediate);
}

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

- (BOOL) setFullScreen:(BOOL)shouldBeFullScreen {
    return (AXUIElementSetAttributeValue(_win, CFSTR("AXFullScreen"), shouldBeFullScreen ? kCFBooleanTrue : kCFBooleanFalse) == kAXErrorSuccess);
}

- (NSNumber*) isFullScreen {
    CFBooleanRef fullscreen;
    if (AXUIElementCopyAttributeValue(_win, CFSTR("AXFullScreen"), (CFTypeRef*)&fullscreen) != kAXErrorSuccess) return nil;
    return (__bridge NSNumber*)fullscreen;
}

- (BOOL) minimize {
    return (AXUIElementSetAttributeValue(_win, (CFStringRef)(NSAccessibilityMinimizedAttribute), kCFBooleanTrue) == kAXErrorSuccess);
}

- (BOOL) unminimize {
    return (AXUIElementSetAttributeValue(_win, (CFStringRef)(NSAccessibilityMinimizedAttribute), kCFBooleanFalse) == kAXErrorSuccess);
}

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

- (BOOL) isVisible {
    return !self.app.isHidden && !self.isMinimized;
}

- (BOOL) becomeMain {
    return (AXUIElementSetAttributeValue(_win, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue) == kAXErrorSuccess);
}

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

- (App*) app {
    NSNumber* pid = [self pid];
    if (!pid) return nil;
    return [App appForPid: [pid intValue]];
}

- (NSRect) frame {
    NSSize s = self.size;
    NSPoint p = self.topLeft;
    return NSMakeRect(p.x, p.y, s.width, s.height);
}

- (void) setFrame:(NSRect)frame {
    [self setSize: frame.size];
    [self setTopLeft: frame.origin];
    [self setSize: frame.size];
}

@end
