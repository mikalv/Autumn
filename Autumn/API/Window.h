//
//  Window.h
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

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

- (BOOL) isEqual:(Window*)object;

- (NSString*) title;
- (NSString*) subrole;
- (NSString*) role;

- (App*) app;

- (BOOL) isStandardWindow;
- (NSNumber*) isFullScreen;
- (NSNumber*) isMinimized;
- (BOOL) isVisible;

- (NSPoint) topLeft;
- (void) setTopLeft:(NSPoint)thePoint;

- (NSSize) size;
- (void) setSize:(NSSize)theSize;

- (NSRect) frame;
- (void) setFrame:(NSRect)frame;

- (BOOL) close;
- (BOOL) setFullScreen:(BOOL)shouldBeFullScreen;
- (BOOL) minimize;
- (BOOL) unminimize;
- (void) maximize;

- (BOOL) becomeMain;
- (BOOL) focus;

- (Screen*) screen;

- (NSArray*) windowsToEast;
- (NSArray*) windowsToNorth;
- (NSArray*) windowsToWest;
- (NSArray*) windowsToSouth;

- (void) focusFiristWindowToEast;
- (void) focusFiristWindowToNorth;
- (void) focusFiristWindowToWest;
- (void) focusFiristWindowToSouth;

- (void) moveToPercentOfScreen:(NSRect)unit;

@end

@interface Window : NSObject <JSExport_Window>

- (instancetype) initWithElement:(AXUIElementRef)element;

@end
