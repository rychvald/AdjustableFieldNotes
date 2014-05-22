//
//  CommentInputController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 22.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "CommentInputController.h"
#import "Entry.h"
#import "Entry+Additions.h"

@implementation CommentInputController

@synthesize currentEntry;

- (void)prepareForEditingEntry:(Entry *)entry fromDelegate:(id)delegate {
    self.currentEntry = entry;
    self.textView.text = self.currentEntry.comment;
    NSLog(@"Showing for Entry %@",[entry asString]);
    UIPopoverController *popoverVC = (UIPopoverController *)self.parentViewController;
    popoverVC.delegate = self;
    [self.view reloadInputViews];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.currentEntry.managedObjectContext save:nil];
    self.currentEntry.comment = self.textView.text;
    [self.currentEntry.managedObjectContext save:nil];
    NSLog(@"edited and saved comment");
}

@end
