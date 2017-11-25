//
//  Env.m
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Env.h"
#import "Hotkey.h"
#import "Keycodes.h"
#import "JS.h"
#import "NotificationManager.h"

@implementation Env

+ (void) setupOnce {
    [Keycodes setupOnce];
    [Hotkey setupOnce];
    [NotificationManager setupOnce];
}

+ (void) reset {
    [Keycodes reset];
    [Hotkey reset];
    [NotificationManager reset];
    [JS reset];
}

@end
