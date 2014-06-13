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

@implementation MasterVCTemplate

@synthesize myKeyword;
@synthesize managedObjectContext;
@synthesize itemInputNC;
@synthesize docInteractionController;
@synthesize recordingInputController;

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
    UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(import:)];
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(export:)];
    [self setToolbarItems:@[wordsButton,recordsButton,importButton,exportButton]];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    if (self.detailViewController == nil) {
        NSLog(@"Something went wrong assigning detailViewController!");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (self.tableView.delegate == self.recordingsHandler) {
        [self performSegueWithIdentifier:@"addRecording" sender:self];
        if (self.recordingInputController == nil) {
            NSLog(@"ItemInputController is nil!");
        }
        [self.recordingInputController prepareForNewRecordingFromDelegate:self];
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
    self.tableView.delegate = self.recordingsHandler;
    self.title = @"Recordings";
    [self reload];
}

- (void)showWords:(id)sender {
    if (self.tableView.dataSource == self && self.tableView.delegate == self) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    self.title = @"Word Sets";
    [self reload];
}

- (void)import:(id)sender {
    
}

- (void)export:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Name" message:@"Please enter a file name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.delegate = self;
    [alertView show];
}

- (UIBarButtonItem *)exportButton {
    return [self.toolbarItems objectAtIndex:3];
}

#pragma mark - Methods for Toolbar buttons

- (RecordingsHandler *)recordingsHandler {
    RecordingsHandler *handler = [(AppDelegate *)[[UIApplication sharedApplication] delegate] recordingsHandler];
    handler.managedObjectContext = self.managedObjectContext;
    return handler;
}

#pragma mark - FileName Input Controller

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UITextField *fileNameInput = [alertView textFieldAtIndex:0];
    NSString *filename;
    if (fileNameInput.text == nil || [fileNameInput.text isEqualToString:@""]) {
        filename = [Recording getActiveRecordingForContext:self.managedObjectContext].name;
    } else {
        filename = fileNameInput.text;
    }
    NSString *exportData = [[Recording getActiveRecordingForContext:self.managedObjectContext] serialise];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    filename = [docPath stringByAppendingPathComponent:filename];
    NSString *extension = @".csv";
    
    while ([[NSFileManager defaultManager] fileExistsAtPath:[filename stringByAppendingString:extension]]) {
        filename = [filename stringByAppendingString:@"-1"];
    }
    filename = [filename stringByAppendingString:extension];
    NSLog(@"Filename: %@",filename);
    [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[exportData dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filename]];
    } else {
        self.docInteractionController.URL = [NSURL fileURLWithPath:filename];
    }
    if ([self exportButton] == nil) {
        NSLog(@"ExportButton is nil!!");
    }
    [self.docInteractionController presentOptionsMenuFromBarButtonItem:[self exportButton] animated:YES];
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
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
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoneCell" forIndexPath:indexPath];
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
    return;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reload];
    [self.detailViewController reload];
}

//helper method for dividing indexPaths between the two object types
- (NSManagedObject *)getManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
