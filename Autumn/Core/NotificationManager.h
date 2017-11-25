//
//  NotificationManager.h
//  Autumn
//
//  Created by Steven Degutis on 11/24/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject <NSUserNotificationCenterDelegate>

+ (void) setupOnce;
+ (void) reset;

+ (void) deliverNotification:(NSUserNotification*)note
                     clicked:(void(^)(void))clicked
                   forceShow:(BOOL(^)(void))forceShow
                  resettable:(BOOL)resettable;

@end
