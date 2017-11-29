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
+ (NSArray*) orderedWindows;
+ (NSArray<Window*>*) allWindows;

+ (Window*) windowForID:(NSNumber*)winid;

- (NSString*) title;
- (NSString*) subrole;
- (NSString*) role;
- (BOOL) isStandardWindow;
- (NSPoint) topLeft;
- (NSSize) size;
- (void) setTopLeft:(NSPoint)thePoint;
- (BOOL) isEqual:(Window*)object;
- (void) setSize:(NSSize)theSize;
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

- (NSRect) frame;
- (void) setFrame:(NSRect)frame;

- (NSArray*) otherWindows:(BOOL)allScreens;

+ (NSArray*) visibleWindows;

- (BOOL) focus;

- (Screen*) screen;

- (void) maximize;

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
