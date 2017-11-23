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

@protocol JSExport_Window <JSExport>

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

@end

@interface Window : NSObject <JSExport_Window>

- (instancetype) initWithElement:(AXUIElementRef)element;

@end
