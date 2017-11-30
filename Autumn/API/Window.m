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
#import "Screen.h"
#import "Math.h"

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

- (NSNumber*) isStandardWindow {
    return [[self subrole] isEqualToString: (NSString*)kAXStandardWindowSubrole] ? @YES : @NO;
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

- (void) close {
//    BOOL worked = NO;
    AXUIElementRef button = NULL;
    
    if (AXUIElementCopyAttributeValue(_win, kAXCloseButtonAttribute, (CFTypeRef*)&button) != kAXErrorSuccess) goto cleanup;
    if (AXUIElementPerformAction(button, kAXPressAction) != kAXErrorSuccess) goto cleanup;
//    worked = YES;
    
cleanup:
    if (button) CFRelease(button);
//    return worked;
}

- (void) setFullScreen:(BOOL)shouldBeFullScreen {
    AXUIElementSetAttributeValue(_win, CFSTR("AXFullScreen"), shouldBeFullScreen ? kCFBooleanTrue : kCFBooleanFalse);
}

- (NSNumber*) isFullScreen {
    CFBooleanRef fullscreen;
    if (AXUIElementCopyAttributeValue(_win, CFSTR("AXFullScreen"), (CFTypeRef*)&fullscreen) != kAXErrorSuccess) return nil;
    return (__bridge NSNumber*)fullscreen;
}

- (void) minimize {
    AXUIElementSetAttributeValue(_win, (CFStringRef)(NSAccessibilityMinimizedAttribute), kCFBooleanTrue);
}

- (void) unminimize {
    AXUIElementSetAttributeValue(_win, (CFStringRef)(NSAccessibilityMinimizedAttribute), kCFBooleanFalse);
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

- (NSNumber*) isVisible {
    return (!self.app.isHidden && !self.isMinimized) ? @YES : @NO;
}

- (void) becomeMain {
    AXUIElementSetAttributeValue(_win, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue);
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

- (NSArray*) otherWindows:(BOOL /* default: false */)allScreens {
    return [FnUtils filter:[Window visibleWindows] with:^BOOL(Window* win) {
        if ([self isEqual: win]) return NO;
        if (!allScreens && [[self screen] isEqual: [win screen]]) return NO;
        return YES;
    }];
}

+ (NSArray*) visibleWindows {
    return [FnUtils filter:[Window allWindows] with:^BOOL(Window* win) {
        return [win isVisible].boolValue;
    }];
}

- (void) focus {
    [self becomeMain];
    [self.app internal_bringToFront:NO];
}

+ (NSArray*) orderedWindows {
    NSArray* winids = [self orderedWindowIDs];
    NSArray* allWindows = [Window allWindows];
    NSMutableArray<Window*>* orderedWindows = [NSMutableArray array];
    
    for (NSNumber* winid in winids) {
        Window* win = [FnUtils findIn:allWindows where:^BOOL(Window* win) {
            return [win.windowID isEqualToNumber: winid];
        }];
        
        if (win) {
            [orderedWindows addObject: win];
        }
    }
    
    return orderedWindows;
}

- (Screen*) screen {
    NSRect windowFrame = [self frame];
    
    CGFloat lastVolume = 0;
    Screen* lastScreen;
    
    for (Screen* screen in [Screen allScreens]) {
        NSRect screenFrame = [screen fullFrame];
        NSRect intersection = NSIntersectionRect(windowFrame, screenFrame);
        CGFloat volume = intersection.size.width * intersection.size.height;
        
        if (volume > lastVolume) {
            lastVolume = volume;
            lastScreen = screen;
        }
    }
    
    return lastScreen;
}

- (void) maximize {
    NSRect screenRect = self.screen.frame;
    [self setFrame: screenRect];
}

- (NSArray*) windowsInDirection:(int)numRotations {
    // assume looking to east
    
    // use the score distance/cos(A/2), where A is the angle by which it
    // differs from the straight line in the direction you're looking
    // for. (may have to manually prevent division by zero.)
    
    NSPoint startingPoint = [Math midPointOfRect: [self frame]];
    
    NSArray* otherWindows = [FnUtils filter:[Window allWindows] with:^BOOL(Window* win) {
        return (win.isVisible && win.isStandardWindow && ![self isEqual: win]);
    }];
    
    NSMutableArray* orderedWindows = [NSMutableArray array];
    
    int position = 0;
    for (Window* win in otherWindows) {
        NSPoint otherPoint = [Math rotateCounterClockwise:[Math midPointOfRect: [win frame]]
                                                   around:startingPoint
                                                    times:numRotations];
        
        NSPoint delta = NSMakePoint(otherPoint.x - startingPoint.x,
                                    otherPoint.y - startingPoint.y);
        
        if (delta.x > 0) {
            double angle = atan2(delta.y, delta.x);
            double distance = hypot(delta.x, delta.y);
            double angleDiff = -angle;
            double score = (distance / cos(angleDiff / 2.0)) + (++position);
            
            [orderedWindows addObject: @{@"score": @(score),
                                         @"win": win}];
        }
        
    }
    
    [orderedWindows sortUsingComparator:^NSComparisonResult(NSDictionary* _Nonnull a, NSDictionary* _Nonnull b) {
        return [a[@"score"] compare: b[@"score"]];
    }];
    
    return [FnUtils map:orderedWindows with:^Window*(NSDictionary* dict) {
        return dict[@"win"];
    }];
}

- (NSArray*) windowsToEast  { return [self windowsInDirection: 0]; }
- (NSArray*) windowsToNorth { return [self windowsInDirection: 1]; }
- (NSArray*) windowsToWest  { return [self windowsInDirection: 2]; }
- (NSArray*) windowsToSouth { return [self windowsInDirection: 3]; }

- (void) focusFiristWindowToEast  { [[self windowsToEast].firstObject focus]; }
- (void) focusFiristWindowToNorth { [[self windowsToNorth].firstObject focus]; }
- (void) focusFiristWindowToWest  { [[self windowsToWest].firstObject focus]; }
- (void) focusFiristWindowToSouth { [[self windowsToSouth].firstObject focus]; }

- (void) moveToPercentOfScreen:(NSRect)unit {
    NSRect screenRect = [[self screen] frame];
    
    [self setFrame:NSMakeRect(screenRect.origin.x + (unit.origin.x * screenRect.size.width),
                              screenRect.origin.y + (unit.origin.y * screenRect.size.height),
                              unit.size.width * screenRect.size.width,
                              unit.size.height * screenRect.size.height)];
}

@end

