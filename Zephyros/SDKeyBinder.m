//
//  BindkeyOp.m
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDKeyBinder.h"

#import "MASShortcut+Monitoring.h"
#import "SDKeyBindingTranslator.h"

#import "SDJSBlockWrapper.h"


@interface SDHotKey : NSObject
@property NSArray* modifiers;
@property NSString* key;
@property SDJSBlockWrapper* fn;
@end

@implementation SDHotKey

- (MASShortcut*) shortcutObject {
    NSUInteger code = [SDKeyBindingTranslator keyCodeForString:self.key];
    NSUInteger mods = [SDKeyBindingTranslator modifierFlagsForStrings:self.modifiers];
    
    return [MASShortcut shortcutWithKeyCode:code modifierFlags:mods];
}

- (NSString*) hotKeyDescription {
    return [NSString stringWithFormat:@"%@ %@",
            [self.modifiers componentsJoinedByString:@"-"],
            self.key];
}

- (id) bindAndReturnHandler {
    return [MASShortcut addGlobalHotkeyMonitorWithShortcut:[self shortcutObject] handler:^{
        [self.fn call:nil];
    }];
}

@end



@interface SDKeyBinder ()

@property NSArray* upcomingHotKeys;
@property NSArray* globalHandlers;

@end

@implementation SDKeyBinder

+ (SDKeyBinder*) sharedKeyBinder {
    static SDKeyBinder* sharedKeyBinder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedKeyBinder = [[SDKeyBinder alloc] init];
    });
    return sharedKeyBinder;
}

- (void) bind:(NSString*)key modifiers:(NSArray*)mods fn:(JSValueRefAndContextRef)fn {
    SDHotKey* hotkey = [[SDHotKey alloc] init];
    hotkey.key = key;
    hotkey.modifiers = mods;
    hotkey.fn = [[SDJSBlockWrapper alloc] initWithJavaScriptFn:fn];
    
    self.upcomingHotKeys = [[NSArray arrayWithArray:self.upcomingHotKeys] arrayByAddingObject:hotkey];
}

- (void) removeKeyBindings {
    for (id oldHandler in self.globalHandlers) {
        [MASShortcut removeGlobalHotkeyMonitor:oldHandler];
    }
}

- (NSArray*) finalizeNewKeyBindings {
    NSMutableArray* handlers = [NSMutableArray array];
    NSMutableArray* failures = [NSMutableArray array];
    
    for (SDHotKey* hotkey in self.upcomingHotKeys) {
        id binding = [hotkey bindAndReturnHandler];
        if (binding)
            [handlers addObject:binding];
        else
            [failures addObject:[hotkey hotKeyDescription]];
    }
    
    self.globalHandlers = handlers;
    self.upcomingHotKeys = nil;
    
    return failures;
}

@end
