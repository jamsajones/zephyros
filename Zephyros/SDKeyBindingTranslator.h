//
//  BindkeyLegacyTranslator.h
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKeyBindingTranslator : NSObject

+ (NSUInteger) keyCodeForString:(NSString*)str;
+ (NSUInteger) modifierFlagsForStrings:(NSArray*)strs;

@end
