//
//  Screen.m
//  Autumn
//
//  Created by Steven Degutis on 11/28/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Screen.h"
#import "FnUtils.h"

@implementation Screen {
    NSScreen* _screen;
}

- (instancetype) initWithScreen:(NSScreen*)screen {
    if (self = [super init]) {
        _screen = screen;
    }
    return self;
}

+ (NSArray*) allScreens {
    return [FnUtils map:[NSScreen screens] with:^Screen*(NSScreen* screen) {
        return [[Screen alloc] initWithScreen: screen];
    }];
}

+ (Screen*) focusedScreen {
    return [[Screen alloc] initWithScreen: [NSScreen mainScreen]];
}

- (NSNumber*) equals:(Screen*)other {
    if (self == other) return @YES;
    if (![other isKindOfClass: [self class]]) return @NO;
    return [_screen isEqual: other->_screen] ? @YES : @NO;
}

- (BOOL) isEqual:(id)other {
    return [self equals: other].boolValue;
}

- (NSUInteger) hash {
    return _screen.hash + 1;
}

- (NSNumber*) screenId {
    return [[_screen deviceDescription] objectForKey:@"NSScreenNumber"];
}

- (NSString*) name {
    CGDirectDisplayID screen_id = [[self screenId] intValue];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDictionary *deviceInfo = (__bridge_transfer NSDictionary*)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(screen_id), kIODisplayOnlyPreferredName);
#pragma clang diagnostic pop
    NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
    
    return [localizedNames count] ? [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]] : nil;
}

- (NSRect) fullFrame {
    Screen* primaryScreen = [Screen allScreens].firstObject;
    NSRect f = _screen.frame;
    f.origin.y = primaryScreen->_screen.frame.size.height - f.size.height - f.origin.y;
    return f;
}

- (NSRect) frame {
    Screen* primaryScreen = [Screen allScreens].firstObject;
    NSRect f = _screen.visibleFrame;
    f.origin.y = primaryScreen->_screen.frame.size.height - f.size.height - f.origin.y;
    return f;
}

- (Screen*) nextScreen {
    NSArray* screens = [Screen allScreens];
    NSInteger i = [screens indexOfObject: self] + 1;
    if (i >= screens.count) i = 0;
    return screens[i];
}

- (Screen*) previousScreen {
    NSArray* screens = [Screen allScreens];
    NSInteger i = [screens indexOfObject: self] - 1;
    if (i < 0) i = screens.count - 1;
    return screens[i];
}

- (Screen*) firstScreenInDirection:(int) numRotations {
    NSArray<Screen*>* allScreens = [Screen allScreens];
    
    if (allScreens.count == 1)
        return nil;
    
    // assume looking to east
    
    // use the score distance/cos(A/2), where A is the angle by which it
    // differs from the straight line in the direction you're looking
    // for. (may have to manually prevent division by zero.)
    
    NSMutableArray* otherScreens = [allScreens mutableCopy];
    [otherScreens removeObject: self];
    
    NSRect myFullFrame = self.fullFrame;
    NSPoint startingPoint = NSMakePoint(NSMidX(myFullFrame), NSMidY(myFullFrame));
    
    Screen* screenWithLowestScore;
    double lastScore = CGFLOAT_MAX; // only here to silence warning
    
    for (Screen* maybeScreen in otherScreens) {
        NSRect otherFullFrame = maybeScreen.fullFrame;
        NSPoint otherPoint = NSMakePoint(NSMidX(otherFullFrame), NSMidY(otherFullFrame));
        otherPoint = rotateccw(otherPoint, startingPoint, numRotations);
        
        NSPoint delta = NSMakePoint(otherPoint.x - startingPoint.x,
                                    otherPoint.y - startingPoint.y);
        
        if (delta.x > 0) {
            double angle = atan2(delta.y, delta.x);
            double distance = hypot(delta.x, delta.y);
            double angleDiff = -angle;
            double score = distance / cos(angleDiff / 2.0);
            
            if (screenWithLowestScore == nil || score < lastScore) {
                lastScore = score;
                screenWithLowestScore = maybeScreen;
            }
        }
    }
    
    return screenWithLowestScore;
}

static NSPoint rotateccw(NSPoint point, NSPoint aroundPoint, int times) {
    NSPoint p = point;
    for (int i = 1; i < times; i++) {
        CGFloat px = p.x;
        p.x = (aroundPoint.x - (p.y - aroundPoint.y));
        p.y = (aroundPoint.y + (px - aroundPoint.x));
    }
    return p;
}

- (Screen*) screenToEast  { return [self firstScreenInDirection: 0]; }
- (Screen*) screenToNorth { return [self firstScreenInDirection: 1]; }
- (Screen*) screenToWest  { return [self firstScreenInDirection: 2]; }
- (Screen*) screenToSouth { return [self firstScreenInDirection: 3]; }

@end

