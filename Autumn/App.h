//
//  App.h
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "JS.h"

@class Window;

CLASS_START(App)

+ (App*) appForPid:(pid_t)pid;
+ (NSArray<App*>*) appsForBundleID:(NSString*)bundleIdentifier;
+ (NSArray<App*>*) runningApps;

- (BOOL) isEqual:(App*)object;

- (Window*) mainWindow;
- (NSArray<Window*>*) allWindows;

- (BOOL) isUnresponsive;
- (NSString*) title;
- (NSString*) bundleID;
- (BOOL) unhide;
- (BOOL) hide;
- (void) kill;
- (void) forceKill;
- (BOOL) isHidden;
- (pid_t) pid;
- (NSString*) kind;
- (BOOL) launchOrFocus:(NSString*)name;
- (BOOL) activate:(BOOL)allWindows;

CLASS_END(App)
