//
//  MasterVCTemplate.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "MasterVCTemplate.h"

#import "DetailViewController.h"
#import "ItemInputController.h"
#import "WordSetInputController.h"
#import "AppDelegate.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "Relation.h"
#import "Relation+RelationAccessors.h"
#import "AppDelegate.h"
#import "RecordingsHandler.h"
#import "Recording.h"
#import "Recording+Additions.h"
#import "NSManagedObject+Serialization.h"

@implementation MasterVCTemplate

@synthesize myKeyword;
@synthesize managedObjectContext;
@synthesize itemInputNC;
@synthesize docInteractionController;
@synthesize recordingInputController;
@synthesize exportButton;

- (void)awakeFromNib {
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //init top bar buttons
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    //init bottom bar buttons
    UIBarButtonItem *recordsButton = [[UIBarButtonItem alloc] initWithTitle:@"Recordings" style:UIBarButtonItemStylePlain target:self action:@selector(showRecords:)];
    UIBarButtonItem *wordsButton = [[UIBarButtonItem alloc] initWithTitle:@"Word Sets" style:UIBarButtonItemStylePlain target:self action:@selector(showWords:)];
    self.exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(export:)];
    [self setToolbarItems:@[wordsButton,recordsButton,self.exportButton]];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    if (self.detailViewController == nil) {
        NSLog(@"Something went wrong assigning detailViewController!");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (self.tableView.dataSource == self.recordingsHandler) {
        [self performSegueWithIdentifier:@"addRecording" sender:self];
        if (self.recordingInputController == nil) {
            NSLog(@"ItemInputController is nil!");
        }
        [self.recordingInputController prepareForNewRecordingFromDelegate:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addRecording"]) {
        self.recordingInputController = (WordSetInputController *)[segue.destinationViewController topViewController];
        [self.recordingInputController prepareForNewRecordingFromDelegate:self];
    } else if ([segue.identifier isEqualToString:@"editRecording"]) {
        self.recordingInputController = (WordSetInputController *)[segue.destinationViewController topViewController];
        [self.recordingInputController prepareForEditingRecording:(Recording *)sender fromDelegate:self];
    }
}

#pragma mark - ItemInputDelegate Methods

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color {
    Keyword *newKeyword = [Keyword createNewKeyword:keyword withLabel:label color:color inContext:self.managedObjectContext];
    newKeyword.keyword = keyword;
    newKeyword.label = label;
    newKeyword.color = color;
    if (self.myKeyword != nil) {
        [myKeyword addChildrenObject:newKeyword];
    }
    NSLog(@"Created entity with keyword: %@",keyword);
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self reload];
}

- (void)createNewRecording:(NSString *)recording withDate:(NSDate *)date active:(BOOL)active {
    Recording *newRecording = [Recording createRecording:recording inContext:self.managedObjectContext];
    newRecording.name = recording;
    newRecording.dateCreated = date;
    newRecording.isActive = active;
    
    // Save the context.
    [self.managedObjectContext save:nil];
    [self reload];
}

- (void)reload {
    [self.tableView reloadData];
    [self.detailViewController reload];
}

#pragma mark - Methods for Toolbar buttons

- (void)showRecords:(id)sender {
    if (self.recordingsHandler == nil) {
        NSLog(@"RecordingsHandler is nil!");
    }
    //self.recordingsHandler.managedObjectContext = self.managedObjectContext;
    self.tableView.dataSource = self.recordingsHandler;
    self.title = @"Recordings";
    [self reload];
}

- (void)showWords:(id)sender {
    if (self.tableView.dataSource == self && self.tableView.delegate == self) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        self.tableView.dataSource = self;
    }
    self.title = @"Word Sets";
    [self reload];
}

- (void)export:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Name and Export" message:@"Please enter a file name and choose whether you want to export the active recording or the active word set." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Active Recording",@"Active Word Set",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.delegate = self;
    [alertView show];
}

- (void)exportActiveWordSetToFilepath:(NSString *)filepath {
    Keyword *wordset = [Keyword getActiveWordSetForContext:self.managedObjectContext];
    wordset.isActive = NO;
    NSDictionary *wordsetDictionary = [wordset toDictionary];
    wordset.isActive = YES;
    
    NSString *extension = @".wordset";
    while ([[NSFileManager defaultManager] fileExistsAtPath:[filepath stringByAppendingString:extension]]) {
        filepath = [filepath stringByAppendingString:@"-1"];
    }
    filepath = [filepath stringByAppendingString:extension];
    NSLog(@"Filename: %@",filepath);
    
    if(![[NSManagedObject dataFromDictionary:wordsetDictionary] writeToFile:filepath atomically:YES]) {
        NSLog(@"Something went wrong when storing file!");
    }
    [self showDocInteractionControllerForFilepath:filepath];
    [self.managedObjectContext save:nil];
}

- (void)exportActiveRecordingToFilepath:(NSString *)filepath {
    NSString *exportData = [[Recording getActiveRecordingForContext:self.managedObjectContext] serialise];
    
    NSString *extension = @".csv";
    
    while ([[NSFileManager defaultManager] fileExistsAtPath:[filepath stringByAppendingString:extension]]) {
        filepath = [filepath stringByAppendingString:@"-1"];
    }
    filepath = [filepath stringByAppendingString:extension];
    NSLog(@"Filename: %@",filepath);
    [[NSFileManager defaultManager] createFileAtPath:filepath contents:nil attributes:nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[exportData dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    [self showDocInteractionControllerForFilepath:filepath];
}

- (void)showDocInteractionControllerForFilepath:(NSString *)filepath {
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filepath]];
    } else {
        self.docInteractionController.URL = [NSURL fileURLWithPath:filepath];
    }
    if ([self exportButton] == nil) {
        NSLog(@"ExportButton is nil!!");
    }
    [self.docInteractionController presentOptionsMenuFromBarButtonItem:[self exportButton] animated:YES];
}

#pragma mark - Methods for Toolbar buttons

- (RecordingsHandler *)recordingsHandler {
    RecordingsHandler *handler = [(AppDelegate *)[[UIApplication sharedApplication] delegate] recordingsHandler];
    handler.managedObjectContext = self.managedObjectContext;
    return handler;
}

#pragma mark - FileName Input Controller

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    UITextField *fileNameInput = [alertView textFieldAtIndex:0];
    NSString *filename;
    if (fileNameInput.text == nil || [fileNameInput.text isEqualToString:@""]) {
        filename = @"untitled";
    } else {
        filename = fileNameInput.text;
    }
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    filename = [docPath stringByAppendingPathComponent:filename];
    NSLog(@"Button index: %li",(long)buttonIndex);
    switch (buttonIndex) {
        case 1:
            [self exportActiveRecordingToFilepath:filename];
            break;
        case 2:
            [self exportActiveWordSetToFilepath:filename];
            break;
        default:
            NSLog(@"Wrong index: %li",(long)buttonIndex);
            break;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    //return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header;
    switch (section) {
        case 0:
            header = @"Keywords";
            break;
        case 1:
            header = @"Relations";
            break;
        default:
            header = @"";
            break;
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSFetchedResultsController *controller;
    NSInteger retVal = 0;
    
    switch (section) {
        case 0:
            retVal = [self.myKeyword.children count];
            break;
        case 1:
            retVal = [self.myKeyword.relations count];
            break;
        default:
            break;
    }
    
    //id <NSFetchedResultsSectionInfo> sectionInfo = [controller sections][0];
    //NSInteger retVal = [sectionInfo numberOfObjects];
    
    if (retVal == 0) {
        retVal = 1;
    }
    
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    Keyword *keyword = (Keyword *)[self getManagedObjectAtIndexPath:indexPath];
    if (keyword != nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.detailTextLabel.textColor =[UIColor grayColor];
        cell.textLabel.textColor = [UIColor blackColor];
        if (keyword.label == nil) {
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = keyword.keyword;
        } else {
            cell.detailTextLabel.text = keyword.label;
            cell.textLabel.text = keyword.keyword;
        }
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoneCell"];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"None";
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self getManagedObjectAtIndexPath:indexPath] == nil)
        return NO;
    else
        return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Querying movement possibility for row: %li",(long)indexPath.row);
    if ([self getManagedObjectAtIndexPath:indexPath] == nil)
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    return;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.dataSource == self.recordingsHandler) {
        if (self.isEditing) {
            Recording *selectedRecording = [self.recordingsHandler getRecordingAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"editRecording" sender:selectedRecording];
            [self.recordingInputController prepareForEditingRecording:selectedRecording fromDelegate:self];
        }
    } else
        return;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reload];
    [self.detailViewController reload];
}

#pragma mark - helper method for dividing indexPaths between the two object types
- (NSManagedObject *)getManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
