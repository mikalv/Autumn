//
//  FnUtils.h
//  Autumn
//
//  Created by Steven Degutis on 11/16/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FnUtils : NSObject

+ (NSArray*) map:(NSArray*)i with:(id(^)(id))fn;
+ (NSArray*) flatMap:(NSArray*)i with:(NSArray*(^)(id))fn;
+ (NSArray*) filter:(NSArray*)i with:(BOOL(^)(id))fn;
+ (id) findIn:(NSArray*)i where:(BOOL(^)(id))fn;

@end
