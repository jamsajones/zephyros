//
//  SDJSBlockWrapper.m
//  Zephyros
//
//  Created by Steven on 4/17/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDJSBlockWrapper.h"

@interface SDJSBlockWrapper ()

@property JSContextRef mainContext;
@property JSValueRef actualFn;

@end

@implementation SDJSBlockWrapper

- (id) initWithJavaScriptFn:(JSValueRefAndContextRef)fn {
    if (self = [super init]) {
        self.mainContext = [[JSCocoa controllerFromContext:fn.ctx] ctx];
        self.actualFn = fn.value;
        
        JSValueProtect(self.mainContext, self.actualFn);
    }
    return self;
}

- (void) call:(NSArray*)args {
    [[JSCocoa controllerFromContext:self.mainContext] callJSFunction:(JSObjectRef)(self.actualFn)
                                                       withArguments:args];
}

- (void) dealloc {
    JSValueUnprotect(self.mainContext, self.actualFn);
}

@end
