//
//  AppDelegate.h
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <Sparkle/Sparkle.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenu *statusItemMenu;
@property IBOutlet SUUpdater *updater;

@end
