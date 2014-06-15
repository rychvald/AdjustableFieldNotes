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
@synthesize activeTextField;
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
    self.name.placeholder = NSLocalizedString(@"New Word Set", nil);
    self.title = NSLocalizedString(@"New Word Set", nil);
    self.activeTextField.text = NSLocalizedString(@"Make this the active word set", nil);
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
    self.activeTextField.text = NSLocalizedString(@"Make this the active word set", nil);
    [self.tableView reloadData];
}

- (void)prepareForNewRecordingFromDelegate:(id)delegate {
    self.recordingDelegate = delegate;
    self.name.placeholder = NSLocalizedString(@"New Recording", nil);
    self.title = NSLocalizedString(@"New Recording", nil);
    self.activeTextField.text = NSLocalizedString(@"Make this the active recording", nil);
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
    self.activeTextField.text = NSLocalizedString(@"Make this the active word set", nil);
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

#pragma mark - UITableView DataSource method

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header;
    NSString *active = @"";
    if (self.recordingDelegate != nil) {
        active = NSLocalizedString(@"Active Recording", nil);
    } else if (self.inputDelegate != nil) {
        active = NSLocalizedString(@"Active Word Set", nil);
    }
    switch (section) {
        case 0:
            header = NSLocalizedString(@"Name", nil);
            break;
        case 1:
            header = NSLocalizedString(@"Creation Date", nil);
            break;
        case 2:
            header = active;
            break;
        default:
            header = @"";
            break;
    }
    return header;
}

#pragma mark - UITextField Delegate method

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self saveItem];
    return YES;
}

@end
