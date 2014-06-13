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
#import "Recording.h"
#import "Recording+Additions.h"

@implementation WordSetInputController

@synthesize activeSwitch;
@synthesize name;
@synthesize picker;
@synthesize currentWordSet;
@synthesize currentRecording;
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
    self.title = @"New Word Set";
    [self.tableView reloadData];
}

- (void)prepareForEditingWordSet:(Keyword *)keyword fromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.currentWordSet = keyword;
    self.title = keyword.keyword;
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

- (void)prepareForNewRecordingFromDelegate:(id)delegate {
    self.recordingDelegate = delegate;
    self.name.placeholder = @"New Recording";
    self.title = @"New Recording";
    [self.tableView reloadData];
}

- (void)prepareForEditingRecording:(Recording *)recording fromDelegate:(id)delegate {
    self.recordingDelegate = delegate;
    self.currentRecording = recording;
    self.title = recording.name;
    self.name.text = recording.name;
    self.picker.date = recording.dateCreated;
    if (recording.isActive == YES) {
        self.activeSwitch.on = YES;
        self.activeSwitch.enabled = NO;
    } else {
        self.activeSwitch.on = NO;
    }
    [self.tableView reloadData];
}

- (void)saveItem {
    if (self.recordingDelegate == nil && self.inputDelegate != nil) {
        [self saveWordSet];
    } else if (self.recordingDelegate != nil && self.inputDelegate == nil) {
        [self saveRecording];
    } else {
        NSLog(@"Something went wrong in WordSetInputController");
    }
    [self cancel];
}

- (void)saveWordSet {
    NSLog(@"Saving Word Set...");
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
}

- (void)saveRecording {
    NSLog(@"Saving Recording...");
    if (self.recordingDelegate == nil) {
        NSLog(@"inputDelegate is nil!");
    }
    if (self.currentRecording == nil) {
        [self.recordingDelegate createNewRecording:self.name.text withDate:self.picker.date active:self.activeSwitch.on];
    } else {
        self.currentRecording.name = self.name.text;
        self.currentRecording.dateCreated = self.picker.date;
        self.currentRecording.isActive = self.activeSwitch.on;
    }
    [self.currentRecording.managedObjectContext save:nil];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.currentWordSet = nil;
    self.currentRecording = nil;
    [self.inputDelegate reload];
    [self.recordingDelegate reload];
    self.inputDelegate = nil;
    self.recordingDelegate = nil;
}

#pragma mark - UITextField Delegate method

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self saveItem];
    return YES;
}

@end
