//
//  NotificationManager.m
//  Autumn
//
//  Created by Steven Degutis on 11/24/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "NotificationManager.h"

@interface NotificationDelegate : NSObject
@property (copy) void(^clicked)(void);
@property (copy) BOOL(^forceShow)(void);
@property BOOL resettable;
@end

@implementation NotificationDelegate
@end

@implementation NotificationManager

static NSMutableDictionary<NSString*, NotificationDelegate*>* delegates;

+ (void) setupOnce {
    static NotificationManager* singleton;
    singleton = [[NotificationManager alloc] init];
    delegates = [NSMutableDictionary dictionary];
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = singleton;
}

+ (void) reset {
    for (NSString* uuid in delegates.allKeys) {
        NotificationDelegate* delegate = delegates[uuid];
        if (delegate.resettable) {
            [delegates removeObjectForKey: uuid];
        }
    }
}

+ (void) deliverNotification:(NSUserNotification*)note clicked:(void(^)(void))clicked forceShow:(BOOL(^)(void))forceShow resettable:(BOOL)resettable {
    note.identifier = [NSUUID UUID].UUIDString;
    
    NotificationDelegate* noteDelegate = [[NotificationDelegate alloc] init];
    noteDelegate.clicked = clicked;
    noteDelegate.forceShow = forceShow;
    noteDelegate.resettable = resettable;
    delegates[note.identifier] = noteDelegate;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: note];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NotificationDelegate* delegate = delegates[notification.identifier];
    if (delegate && delegate.forceShow) {
        delegate.clicked();
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    NotificationDelegate* delegate = delegates[notification.identifier];
    return (delegate && delegate.forceShow) ? delegate.forceShow() : NO;
}

@end
