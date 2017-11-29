//
//  Math.h
//  Autumn
//
//  Created by Steven Degutis on 11/29/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Math : NSObject

+ (NSPoint) rotateCounterClockwise:(NSPoint)point around:(NSPoint)aroundPoint times:(int)times;

+ (NSPoint) midPointOfRect:(NSRect)r;

@end
