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

/// Manipulate running applications.

/// Returns an app object for the given pid.
+ (App*) appForPid:(pid_t)pid;

/// Returns any running apps that have the given bundleID.
+ (NSArray<App*>*) appsForBundleID:(NSString*)bundleIdentifier;

/// Returns all running apps.
+ (NSArray<App*>*) runningApps;

/// Checks whether this app object is the same as another.
- (BOOL) isEqual:(App*)object;

/// Returns the main window of the given app, or nil.
- (Window*) mainWindow;

/// Returns all open windows owned by the given app.
- (NSArray<Window*>*) allWindows;

/// Returns only the app's windows that are visible.
- (NSArray<Window*>*) visibleWindows;

/// True if the app has the spinny circle of death.
- (BOOL) isUnresponsive;

/// Returns the localized name of the app (in UTF8).
- (NSString*) title;

/// Returns the bundle identifier of the app.
- (NSString*) bundleID;

/// Unhides the app (and all its windows) if it's hidden.
- (BOOL) unhide;

/// Hides the app (and all its windows).
- (BOOL) hide;

/// Tries to terminate the app.
- (void) kill;

/// Definitely terminates the app.
- (void) forceKill;

/// Returns whether the app is currently hidden.
- (BOOL) isHidden;

/// Returns the app's process identifier.
- (pid_t) pid;

/// Returns the string 'dock' if the app is in the dock, 'no-dock' if not, and 'no-gui' if it can't even have GUI elements if it wanted to.
- (NSString*) kind;

/// Launches the app with the given name, or activates it if it's already running.
/// Returns true if it launched or was already launched; otherwise false (presumably only if the app doesn't exist).
- (BOOL) launchOrFocus:(NSString*)name;

/// Tries to activate the app (make its key window focused) and returns whether it succeeded; if allwindows is true, all windows of the application are brought forward as well.
- (BOOL) activate:(BOOL)allWindows;

CLASS_END(App)
