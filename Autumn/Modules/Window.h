//
//  Window.h
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Module.h"

@class App;
@class Window;
@class Screen;

@protocol JSExport_Window <JSExport>

+ (Window*) focusedWindow;

+ (NSArray*) allWindows;
+ (NSArray*) visibleWindows;
+ (NSArray*) orderedWindows;

+ (Window*) windowForID:(NSNumber*)winid;
- (NSNumber*) windowID;

- (NSArray*) otherWindows:(BOOL)allScreens;

- (NSNumber*) equals:(Window*)other;

- (NSString*) title;
- (NSString*) subrole;
- (NSString*) role;

- (App*) app;

- (NSNumber*) isStandardWindow;
- (NSNumber*) isFullScreen;
- (NSNumber*) isMinimized;
- (NSNumber*) isVisible;

- (NSPoint) topLeft;
- (NSSize) size;
- (NSRect) frame;

- (void) setTopLeft:(NSPoint)thePoint;
- (void) setSize:(NSSize)theSize;
- (void) setFrame:(NSRect)frame;

- (void) moveToPercentOfScreen:(NSRect)unit;

- (void) close;
- (void) setFullScreen:(BOOL)shouldBeFullScreen;
- (void) minimize;
- (void) unminimize;
- (void) maximize;

- (void) becomeMain;
- (void) focus;

- (Screen*) screen;

- (NSArray*) windowsToEast;
- (NSArray*) windowsToNorth;
- (NSArray*) windowsToWest;
- (NSArray*) windowsToSouth;

- (void) focusFiristWindowToEast;
- (void) focusFiristWindowToNorth;
- (void) focusFiristWindowToWest;
- (void) focusFiristWindowToSouth;

@end

@interface Window : NSObject <JSExport_Window, Module>

- (instancetype) initWithElement:(AXUIElementRef)element;

@end
