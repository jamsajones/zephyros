//
//  BindkeyOp.h
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <JSCocoa/JSCocoa.h>

@interface SDKeyBinder : NSObject

+ (SDKeyBinder*) sharedKeyBinder;

- (void) bind:(NSString*)key modifiers:(NSArray*)mods fn:(JSValueRefAndContextRef)fn;

- (void) removeKeyBindings;
- (NSArray*) finalizeNewKeyBindings;

@end
