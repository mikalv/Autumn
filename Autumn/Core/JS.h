//
//  JavaScriptBridge.h
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JS : NSObject

- (JSValue*) addModule:(id)module;

- (NSString*) runString:(NSString*)str;
- (JSValue*) loadFile:(NSString*)path;

@end
