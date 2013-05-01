//
//  SDConfigProblemReporter.m
//  Zephyros
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDLogWindowController.h"

#import <WebKit/WebKit.h>

#import "SDConfigLoader.h"

@interface SDLogWindowController ()

@property IBOutlet NSTextField* replTextField;
@property NSMutableArray* replHistory;
@property NSInteger replHistoryPos;

@property IBOutlet WebView* webView;
@property (copy) dispatch_block_t beforeReady;
@property BOOL ready;

@end

@implementation SDLogWindowController

+ (SDLogWindowController*) sharedLogWindowController {
    static SDLogWindowController* sharedMessageWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMessageWindowController = [[SDLogWindowController alloc] init];
    });
    return sharedMessageWindowController;
}

- (NSString*) windowNibName {
    return @"LogWindow";
}

- (IBAction) evalFromRepl:(id)sender {
    NSString* command = [sender stringValue];
    NSString* str = [[SDConfigLoader sharedConfigLoader] evalString:command
                                                           asCoffee:[[NSUserDefaults standardUserDefaults] boolForKey:@"replUsesCoffee"]];
    [self show:str type:SDLogMessageTypeREPL];
    [sender setStringValue:@""];
    
    [self.replHistory addObject:command];
    self.replHistoryPos = [self.replHistory count];
}

- (IBAction) clearLog:(id)sender {
    DOMDocument* doc = [self.webView mainFrameDocument];
    [doc body].innerHTML = @"";
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    self.ready = YES;
    
    if (self.beforeReady) {
        self.beforeReady();
        self.beforeReady = nil;
    }
}

- (void) showCurrentReplHistoryItem {
    NSString* str = @"";
    
    if (self.replHistoryPos < [self.replHistory count])
        str = [self.replHistory objectAtIndex:self.replHistoryPos];
    
    [self.replTextField setStringValue:str];
    NSText* fieldEditor = [[self.replTextField window] fieldEditor:YES forObject:self.replTextField];
    [fieldEditor moveToEndOfLine:self];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (command == @selector(moveUp:)) {
        // move LOWER in list
        self.replHistoryPos = MAX(self.replHistoryPos - 1, 0);
        [self showCurrentReplHistoryItem];
        return YES;
    }
    else if (command == @selector(moveDown:)) {
        // move HIGHER in list
        self.replHistoryPos = MIN(self.replHistoryPos + 1, [self.replHistory count]);
        [self showCurrentReplHistoryItem];
        return YES;
    }
    return NO;
}

- (void) keyDown:(NSEvent *)theEvent {
    NSLog(@"key down! %@", theEvent);
}

- (void) windowDidBecomeKey:(NSNotification *)notification {
    self.window.level = NSNormalWindowLevel;
}

- (void) windowDidLoad {
    self.replHistory = [NSMutableArray array];
    self.webView.frameLoadDelegate = self;
    
    NSURL* path = [[NSBundle mainBundle] URLForResource:@"logwindow" withExtension:@"html"];
    NSString* html = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:NULL];
    [[self.webView mainFrame] loadHTMLString:html baseURL:[NSURL URLWithString:@""]];
    
    [[self window] center];
}

- (void) doWhenReady:(dispatch_block_t)blk {
    if (self.ready)
        blk();
    else
        self.beforeReady = blk;
}

- (void) show:(NSString*)message type:(NSString*)type {
    if (!self.window.isVisible) {
        self.window.level = NSFloatingWindowLevel;
        [self showWindow:nil];
    }
    
    [self doWhenReady:^{
        DOMDocument* doc = [self.webView mainFrameDocument];
        
        NSString* classname = [@{SDLogMessageTypeError: @"error",
                               SDLogMessageTypeUser: @"user",
                               SDLogMessageTypeREPL: @"repl"} objectForKey:type];
        
        NSDateFormatter* stampFormatter = [[NSDateFormatter alloc] init];
        stampFormatter.dateStyle = NSDateFormatterNoStyle;
        stampFormatter.timeStyle = NSDateFormatterShortStyle;
        
        DOMHTMLDivElement* div = (id)[doc createElement:@"div"];
        div.className = classname;
        [[doc body] appendChild:div];
        
        DOMHTMLElement* stamp = (id)[doc createElement:@"small"];
        stamp.innerText = [stampFormatter stringFromDate:[NSDate date]];
        [div appendChild:stamp];
        
        DOMHTMLParagraphElement* p = (id)[doc createElement:@"p"];
        p.innerText = message;
        [div appendChild:p];
        
        [[self.webView windowScriptObject] evaluateWebScript:@"window.scrollTo(0, document.body.scrollHeight);"];
    }];
}

@end
