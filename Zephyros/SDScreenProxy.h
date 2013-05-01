//
//  NSScreenProxy.h
//  Zephyros
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDScreenProxy : NSObject

@property NSScreen* actualScreenObject;

+ (SDScreenProxy*) mainScreen;
+ (NSArray*) allScreens;

- (CGRect) frameIncludingDockAndMenu;
- (CGRect) frameWithoutDockOrMenu;

- (SDScreenProxy*) nextScreen;
- (SDScreenProxy*) previousScreen;

@end
