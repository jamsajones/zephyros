//
//  SDConfigLoader.m
//  Zephyros
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDConfigLoader.h"

#import <JSCocoa/JSCocoa.h>

#import "SDWindowProxy.h"
#import "SDScreenProxy.h"
#import "SDAPI.h"

#import "SDEventListener.h"
#import "SDKeyBinder.h"
#import "SDAlertWindowController.h"
#import "SDLogWindowController.h"

@interface SDConfigLoader ()

@property JSCocoa* jscocoa;

- (void) reloadConfigIfWatchEnabled;

@property NSDictionary* langsMap;

@end


void fsEventsCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    [[SDConfigLoader sharedConfigLoader] reloadConfigIfWatchEnabled];
}

@implementation SDConfigLoader

+ (SDConfigLoader*) sharedConfigLoader {
    static SDConfigLoader* sharedConfigLoader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfigLoader = [[SDConfigLoader alloc] init];
    });
    return sharedConfigLoader;
}

- (void) prepareScriptingBridge {
    self.jscocoa = [JSCocoa new];
    self.jscocoa.delegate = self;
    self.jscocoa.useAutoCall = YES;
    self.jscocoa.useSplitCall = NO;
    self.jscocoa.useJSLint = NO;
    self.jscocoa.useAutoCall = NO;
    
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"coffee-script" ofType:@"js"]];
    [self.jscocoa eval:@"function coffeeToJS(coffee) { return CoffeeScript.compile(coffee, { bare: true }); };"];
    [self evalCoffeeFile:[[NSBundle mainBundle] pathForResource:@"api" ofType:@"coffee"]];
    
    [self updateAltLangsMap];
    [self watchConfigFiles];
}

- (void) updateAltLangsMap {
    NSData* langsData = [NSData dataWithContentsOfFile:[@"~/.zephyros/langs.json" stringByStandardizingPath]];
    if (langsData != nil) {
        self.langsMap = [NSJSONSerialization JSONObjectWithData:langsData options:0 error:NULL];
    }
}

- (void) reloadConfigIfWatchEnabled {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoReloadConfigs"]) {
        // this (hopefully?) guards against there sometimes being 2 notifications in a row
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadConfig) object:nil];
        [self performSelector:@selector(reloadConfig) withObject:nil afterDelay:0.1];
    }
}

- (void) evalCoffeeFile:(NSString*)path {
    NSString* contents = [NSString stringWithContentsOfFile:[path stringByStandardizingPath]
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    [self evalString:contents asCoffee:YES];
}

- (void) reloadConfig {
    [self updateAltLangsMap];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* file = [self configFileToUse];
        
        if (!file) {
            [[SDAlertWindowController sharedAlertWindowController]
             show:@"Can't find either ~/.zephyros.{coffee,js}\n\nMake one exist and try Reload Config again."
             delay:@7.0];
            return;
        }
        
        [[SDKeyBinder sharedKeyBinder] removeKeyBindings];
        [[SDEventListener sharedEventListener] removeListeners];
        
        if (![self require:file])
            return;
        
        [[SDEventListener sharedEventListener] finalizeNewListeners];
        
        NSArray* failures = [[SDKeyBinder sharedKeyBinder] finalizeNewKeyBindings];
        
        if ([failures count] > 0) {
            NSString* str = [@"The following hot keys could not be bound:\n\n" stringByAppendingString: [failures componentsJoinedByString:@"\n"]];
            [[SDLogWindowController sharedLogWindowController] show:str
                                                               type:SDLogMessageTypeError];
        }
        else {
            static BOOL loaded;
            [[SDAlertWindowController sharedAlertWindowController]
             show:[NSString stringWithFormat:@"%s %@", (loaded ? "Reloaded" : "Loaded"), file]
             delay:nil];
            loaded = YES;
        }
        
    });
}

- (BOOL) require:(NSString*)filename {
    if ([filename isAbsolutePath] == NO)
        filename = [@"~/.zephyros/" stringByAppendingPathComponent:filename];
    
    NSString* contents = [NSString stringWithContentsOfFile:[filename stringByStandardizingPath]
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    
    if (!contents)
        return NO;
    
    if ([filename hasSuffix:@".js"]) {
        [self evalString:contents asCoffee:NO];
        return YES;
    }
    
    if ([filename hasSuffix:@".coffee"]) {
        [self evalString:contents asCoffee:YES];
        return YES;
    }
    
    NSString* suffix = [filename pathExtension];
    NSString* compiler = [[self.langsMap objectForKey:suffix] stringByStandardizingPath];
    if (compiler) {
        NSDictionary* result = [SDAPI shell:@"/bin/bash"
                                       args:@[@"-lc", compiler]
                                    options:@{@"input": contents, @"pwd":[compiler stringByDeletingLastPathComponent]}];
        NSString* output = [result objectForKey:@"stdout"];
        [self.jscocoa eval:output];
        return YES;
    }
    
    [[SDAlertWindowController sharedAlertWindowController]
     show:[NSString stringWithFormat:@"Don't know how to load %@", filename]
     delay:@4.0];
    return NO;
}

- (NSString*) evalString:(NSString*)str asCoffee:(BOOL)useCoffee {
    if (useCoffee)
        return [self evalString:[self.jscocoa callFunction:@"coffeeToJS" withArguments:@[str]]
                       asCoffee:NO];
    else
        return [[self.jscocoa eval:str] description];
}

- (void) JSCocoa:(JSCocoaController*)controller hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url {
    NSString* msg = [NSString stringWithFormat: @"Error in config file on line: %ld\n\n%@", lineNumber, error];
    [[SDLogWindowController sharedLogWindowController] show:msg type:SDLogMessageTypeError];
}

- (void) watchConfigFiles {
    NSArray *pathsToWatch = @[[@"~/.zephyros.js" stringByStandardizingPath],
                              [@"~/.zephyros.coffee" stringByStandardizingPath],
                              [@"~/.zephyros" stringByStandardizingPath]];
    FSEventStreamContext context;
    context.info = NULL;
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    FSEventStreamRef stream = FSEventStreamCreate(NULL,
                                                  fsEventsCallback,
                                                  &context,
                                                  (__bridge CFArrayRef)pathsToWatch,
                                                  kFSEventStreamEventIdSinceNow,
                                                  0.4,
                                                  kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}

- (NSArray*) contentsOfDir:(NSString*)dir withPrefix:(NSString*)prefix {
    NSMutableArray* paths = [NSMutableArray array];
    
    NSArray* allPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[dir stringByStandardizingPath] error:NULL];
    NSArray* matchingPaths = [allPaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString* path, NSDictionary *bindings) {
        return [path hasPrefix:prefix];
    }]];
    
    for (NSString* path in matchingPaths) {
        [paths addObject:[NSString stringWithFormat:@"%@%@", dir, path]];
    }
    
    return paths;
}

- (NSString*) configFileToUse {
    NSArray* rootConfigPaths = [self contentsOfDir:@"~/" withPrefix:@".zephyros."];
    NSArray* subrootConfigPaths = [self contentsOfDir:@"~/.zephyros/" withPrefix:@"config."];
    
    NSArray* prettyChoices = [rootConfigPaths arrayByAddingObjectsFromArray:subrootConfigPaths];
    NSArray* choices = [prettyChoices valueForKeyPath:@"stringByStandardizingPath"];
    
    NSDictionary* results = [NSDictionary dictionaryWithObjects:prettyChoices forKeys:choices];
    
    NSMutableArray* finalContenders = [NSMutableArray array];
    
    for (NSString* candidate in choices) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:candidate] && [[NSFileManager defaultManager] isReadableFileAtPath:candidate]) {
            NSURL* url = [[NSURL fileURLWithPath:candidate] URLByResolvingSymlinksInPath];
            NSDictionary* attrs = [url resourceValuesForKeys:@[NSURLContentModificationDateKey] error:NULL];
            [finalContenders addObject:@{@"file": candidate, @"timestamp": [attrs objectForKey:NSURLContentModificationDateKey]}];
        }
    }
    
    if ([finalContenders count] >= 2) {
        [finalContenders sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
            NSDate* date1 = [obj1 objectForKey:@"timestamp"];
            NSDate* date2 = [obj2 objectForKey:@"timestamp"];
            return [date1 compare: date2];
        }];
    }
    
    return [results objectForKey:[[finalContenders lastObject] objectForKey:@"file"]];
}

@end
