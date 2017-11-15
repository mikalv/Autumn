//
//  JS.h
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#ifndef JS_h
#define JS_h

#import <JavaScriptCore/JavaScriptCore.h>
#define CLASS_START(ClassName) @class ClassName; @protocol JSExport_##ClassName <JSExport>
#define CLASS_END(ClassName) @end @interface ClassName : NSObject <JSExport_##ClassName> @end

#endif /* JS_h */
