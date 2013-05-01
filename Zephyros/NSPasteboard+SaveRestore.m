//
//  NSPasteboard+SaveRestore.m
//
//  Created by Julián Romero on 4/24/13.
//

#import <objc/runtime.h>
#import "NSPasteboard+SaveRestore.h"

static void * kArchiveKey = &kArchiveKey;

@implementation NSPasteboard (SaveRestore)

- (void)setArchive:(NSArray *)newArchive
{
    objc_setAssociatedObject(self, kArchiveKey, newArchive, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray *)archive
{
   	return objc_getAssociatedObject(self, kArchiveKey);
}

- (void)save
{
    NSMutableArray *archive = [NSMutableArray array];
    for (NSPasteboardItem *item in [self pasteboardItems]) {
        NSPasteboardItem *archivedItem = [[NSPasteboardItem alloc] init];
        for (NSString *type in [item types]) {
            NSData *data = [item dataForType:type];
            if (data) {
                [archivedItem setData:data forType:type];
            }
        }
        [archive addObject:archivedItem];
    }
    [self setArchive:archive];
}

- (void)restore
{
    [self clearContents];
    [self writeObjects:[self archive]];
}

@end