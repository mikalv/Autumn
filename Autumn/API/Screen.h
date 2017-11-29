//
//  Screen.h
//  Autumn
//
//  Created by Steven Degutis on 11/28/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class Screen;

@protocol JSExport_Screen <JSExport>

+ (NSArray*) allScreens;
+ (Screen*) focusedScreen;

- (NSNumber*) equals:(Screen*)other;

- (NSNumber*) screenId;
- (NSString*) name;

- (NSRect) fullFrame;
- (NSRect) frame;

- (Screen*) nextScreen;
- (Screen*) previousScreen;

- (Screen*) screenToEast;
- (Screen*) screenToNorth;
- (Screen*) screenToWest;
- (Screen*) screenToSouth;

@end

@interface Screen : NSObject <JSExport_Screen>

@end
