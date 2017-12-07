//
//  NotificationManager.h
//  Autumn
//
//  Created by Steven Degutis on 11/24/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Module.h"

@protocol JSExport_Notification <JSExport>

+ (void) post:(JSValue*)options;

@end

@interface Notification : NSObject <JSExport_Notification, Module>

+ (void) deliverNotification:(NSUserNotification*)notification
                     clicked:(void(^)(void))clicked
                   forceShow:(BOOL)forceShow;

@end
