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
#import "AppDelegate.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "Relation.h"
#import "Relation+RelationAccessors.h"
#import "AppDelegate.h"
#import "RecordingsHandler.h"

@implementation MasterVCTemplate

@synthesize myKeyword;
@synthesize managedObjectContext;
@synthesize itemInputNC;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    //init top bar buttons
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    //init bottom bar buttons
    UIBarButtonItem *recordsButton = [[UIBarButtonItem alloc] initWithTitle:@"Records" style:UIBarButtonItemStylePlain target:self action:@selector(showRecords:)];
    UIBarButtonItem *wordsButton = [[UIBarButtonItem alloc] initWithTitle:@"Words" style:UIBarButtonItemStylePlain target:self action:@selector(showWords:)];
    UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(import:)];
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(export:)];
    [self setToolbarItems:@[recordsButton,wordsButton,importButton,exportButton]];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    return;
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
    
    [self.tableView reloadData];
}

#pragma mark - Methods for Toolbar buttons

- (void)showRecords:(id)sender {
    RecordingsHandler *handler = [(AppDelegate *)[[UIApplication sharedApplication] delegate] recordingsHandler];
    self.tableView.dataSource = handler;
    self.tableView.delegate = handler;
    [self.tableView reloadData];
}

- (void)showWords:(id)sender {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
}

- (void)import:(id)sender {
    
}

- (void)export:(id)sender {
    
}

- (void)reload {
    [self.tableView reloadData];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self getManagedObjectAtIndexPath:indexPath] == nil)
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case 0:
                [self.myKeyword removeObjectFromChildrenAtIndex:indexPath.row];
                break;
            case 1:
                [self.myKeyword removeObjectFromRelationsAtIndex:indexPath.row];
                break;
            default:
                break;
        }
    } else
        return;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (fromIndexPath.section != toIndexPath.section) {
        return;
    }
    Keyword *movingKeyword;
    Relation *movingRelation;
    switch (fromIndexPath.section) {
        case 0:
            movingKeyword = [self.myKeyword.children objectAtIndex:fromIndexPath.row];
            [self.myKeyword removeObjectFromChildrenAtIndex:fromIndexPath.row];
            [self.myKeyword insertObject:movingKeyword inChildrenAtIndex:toIndexPath.row];
            break;
        case 1:
            movingRelation = [self.myKeyword.relations objectAtIndex:fromIndexPath.row];
            [self.myKeyword removeObjectFromRelationsAtIndex:fromIndexPath.row];
            [self.myKeyword insertObject:movingRelation inRelationsAtIndex:toIndexPath.row];
            break;
        default:
            break;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    //if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
    //   return sourceIndexPath;
    //} else {
    return proposedDestinationIndexPath;
    //}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *editingObject = [self getManagedObjectAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            [self performSegueWithIdentifier:@"editKeyword" sender:editingObject];
            break;
        case 1:
            [self performSegueWithIdentifier:@"editRelation" sender:editingObject];
            break;
        default:
            break;
    }
    NSLog(@"Pressed Accessory Button");
}

//helper method for dividing indexPaths between the two object types
- (NSManagedObject *)getManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Fetching object for section: %ld with row: %ld", (long)indexPath.section, (long)indexPath.row);
    //NSFetchedResultsController *controller;
    //NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    AbstractWord *returnWord;
    switch (indexPath.section) {
        case 0:
            if ([self.myKeyword.children count] < indexPath.row+1)
                returnWord = nil;
            else
                returnWord = [self.myKeyword.children objectAtIndex:indexPath.row];
            //controller = self.fetchedKeywordResultsController;
            break;
        case 1:
            if ([self.myKeyword.relations count] < indexPath.row+1)
                returnWord = nil;
            else
                returnWord = [self.myKeyword.relations objectAtIndex:indexPath.row];
            //controller = self.fetchedRelationResultsController;
            break;
        default:
            return nil;;
            break;
    }
    /*if ([[controller fetchedObjects] count] == 0) {
     return nil;
     }
     return [controller objectAtIndexPath:myIndexPath];*/
    return returnWord;
}

@end
