//
//  Math.m
//  Autumn
//
//  Created by Steven Degutis on 11/29/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Math.h"

@implementation Math

+ (NSPoint) rotateCounterClockwise:(NSPoint)point around:(NSPoint)aroundPoint times:(int)times {
    NSPoint p = point;
    for (int i = 1; i < times; i++) {
        CGFloat px = p.x;
        p.x = (aroundPoint.x - (p.y - aroundPoint.y));
        p.y = (aroundPoint.y + (px - aroundPoint.x));
    }
    return p;
}

+ (NSPoint) midPointOfRect:(NSRect)r {
    return NSMakePoint(NSMidX(r), NSMidY(r));
}

@end
