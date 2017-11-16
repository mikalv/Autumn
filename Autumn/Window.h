//
//  Window.h
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "JS.h"

@class App;

CLASS_START(Window)

+ (Window*) focusedWindow;
+ (NSArray<NSNumber*>*) orderedWindowIDs;

- (NSString*) title;
- (NSString*) subrole;
- (NSString*) role;
- (BOOL) isStandardWindow;
- (NSPoint) topLeft;
- (NSSize) size;
- (BOOL) isEqual:(Window*)object;
- (BOOL) close;
- (BOOL) setFullScreen:(BOOL)shouldBeFullScreen;
- (NSNumber*) isFullScreen;
- (BOOL) minimize;
- (BOOL) unminimize;
- (NSNumber*) isMinimized;
- (NSNumber*) pid;
- (BOOL) isVisible;
- (BOOL) becomeMain;
- (NSNumber*) windowID;
- (App*) app;

CLASS_END(Window)

@interface Window (Private)

- (instancetype) initWithElement:(AXUIElementRef)element; // private

@end
