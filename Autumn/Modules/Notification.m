//
//  NotificationManager.m
//  Autumn
//
//  Created by Steven Degutis on 11/24/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Notification.h"

@interface Notification ()

@property (copy) void(^clicked)(void);
@property BOOL forceShow;
@property NSUserNotification* original;

@end

@interface NotificationManager : NSObject <NSUserNotificationCenterDelegate>
@end

@implementation NotificationManager {
    NSMutableDictionary<NSString*, Notification*>* notes;
}

+ (NotificationManager*) sharedManager {
    static NotificationManager* singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[NotificationManager alloc] init];
    });
    return singleton;
}

- (instancetype)init {
    if (self = [super init]) {
        notes = [NSMutableDictionary dictionary];
        [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    }
    return self;
}

- (void) deliver:(Notification*)note {
    NSString* uuid = [NSUUID UUID].UUIDString;
    note.original.identifier = uuid;
    notes[uuid] = note;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: note.original];
}

- (void) reset {
    for (Notification* note in notes.allValues) {
        NSLog(@"removing %@", note);
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification: note.original];
    }
    
    [notes removeAllObjects];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    Notification* note = notes[notification.identifier];
    note.clicked();
    [center removeDeliveredNotification: notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    Notification* note = notes[notification.identifier];
    return note.forceShow;
}

@end

@implementation Notification

+ (void) deliverNotification:(NSUserNotification*)notification clicked:(void(^)(void))clicked forceShow:(BOOL)forceShow {
    Notification* note = [[Notification alloc] init];
    note.original = notification;
    note.clicked = clicked;
    note.forceShow = forceShow;
    [[NotificationManager sharedManager] deliver: note];
}

+ (void) post:(JSValue*)options {
    NSString* title = options[@"title"].toString;
    JSValue* subtitle = options[@"subtitle"];
    NSString* body = options[@"body"].toString;
    JSValue* clicked = options[@"clicked"];
    
    NSUserNotification* note = [[NSUserNotification alloc] init];
    note.title = title;
    note.subtitle = subtitle.isString ? subtitle.toObject : nil;
    note.informativeText = body;
    
    [self deliverNotification:note
                      clicked:^{
                          [clicked callWithArguments: @[]];
                      }
                    forceShow:YES];
}

+ (void)startModule:(JSValue *)ctor {
}

+ (void)stopModule {
    [[NotificationManager sharedManager] reset];
}

@end
