//
//  WordSetsInputController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 27.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "WordSetInputController.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"

@implementation WordSetInputController

@synthesize activeSwitch;
@synthesize name;
@synthesize picker;
@synthesize currentWordSet;
@synthesize inputDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveItem)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)prepareForNewEntryFromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.name.placeholder = @"New Word Set";
    [self.tableView reloadData];
}

- (void)prepareForEditingWordSet:(Keyword *)keyword fromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.currentWordSet = keyword;
    self.name.text = keyword.keyword;
    self.picker.date = keyword.dateCreated;
    if (keyword.isActive == YES) {
        self.activeSwitch.on = YES;
        self.activeSwitch.enabled = NO;
    } else {
        self.activeSwitch.on = NO;
    }
    [self.tableView reloadData];
}

- (void)saveItem {
    NSLog(@"Saving item...");
    if (self.inputDelegate == nil) {
        NSLog(@"inputDelegate is nil!");
    }
    if (self.currentWordSet == nil) {
        [self.inputDelegate createNewWordSet:self.name.text withDate:self.picker.date active:self.activeSwitch.on];
    } else {
        self.currentWordSet.keyword = self.name.text;
        self.currentWordSet.dateCreated = self.picker.date;
        self.currentWordSet.isActive = self.activeSwitch.on;
    }
    [self.currentWordSet.managedObjectContext save:nil];
    [self cancel];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.currentWordSet = nil;
    [self.inputDelegate reload];
}

#pragma mark - UITextField Delegate method

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self saveItem];
    return YES;
}

@end
