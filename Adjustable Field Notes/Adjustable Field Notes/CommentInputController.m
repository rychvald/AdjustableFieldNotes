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
@synthesize popoverVC;
@synthesize delegate;

- (void)viewDidAppear:(BOOL)animated {
    [self.textView becomeFirstResponder];
}

- (void)prepareForEditingEntry:(Entry *)entry fromDelegate:(id)myDelegate withPopover:(UIPopoverController *)popover {
    self.currentEntry = entry;
    self.delegate = myDelegate;
    if (popover == nil || self.delegate == nil) {
        NSLog(@"Popover or delegate  is nil!");
    }
    self.popoverVC = popover;
    self.popoverVC.delegate = self;
    
    self.textView.text = self.currentEntry.comment;
    [self.view reloadInputViews];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.currentEntry.comment = self.textView.text;
    [self.currentEntry.managedObjectContext save:nil];
    [self.delegate releaseSelection];
}

- (IBAction)clearButtonPressed:(id)sender {
    self.textView.text = @"";
    [self.view reloadInputViews];
}

- (IBAction)closeAndSaveButtonPressed:(id)sender {
    [self popoverControllerDidDismissPopover:self.popoverVC];
    [self.popoverVC dismissPopoverAnimated:YES];
}

@end
