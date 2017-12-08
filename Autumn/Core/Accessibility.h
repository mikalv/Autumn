//
//  Accessibility.h
//  Autumn
//
//  Created by Steven Degutis on 12/8/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Accessibility : NSObject

+ (Accessibility*) sharedAccessibility;

@property (readonly) BOOL enabled;

+ (void) openPanel;

@end
