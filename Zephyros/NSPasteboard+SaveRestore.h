//
//  NSPasteboard+SaveRestore.h
//
//  Created by Julián Romero on 4/24/13.
//

#import <Cocoa/Cocoa.h>

@interface NSPasteboard (SaveRestore)

- (void)save;
- (void)restore;

@end
