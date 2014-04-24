//
//  MasterViewController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 17.03.14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "ItemInputController.h"
#import "AppDelegate.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "Relation.h"
#import "Relation+RelationAccessors.h"

@implementation MasterViewController

@synthesize myKeyword;
@synthesize managedObjectContext;
@synthesize itemInputController;
@synthesize itemInputNC;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    self.isRoot = NO;
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (NSManagedObject *)createRootKeywordInContext:(NSManagedObjectContext *)context {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Root" inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue:@"root" forKey:@"keyword"];
    [context insertObject:newManagedObject];
    return newManagedObject;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    [self performSegueWithIdentifier:@"addItem" sender:self];
    if (self.itemInputController == nil) {
        NSLog(@"ItemInputController is nil!");
    }
    [self.itemInputController prepareForNewEntryFromDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"addItem"]) {
        self.itemInputController = (ItemInputController *)[segue.destinationViewController topViewController];
        [self.itemInputController prepareForNewEntryFromDelegate:self];
    } else if ([segue.identifier isEqual:@"editKeyword"]) {
        self.itemInputController = (ItemInputController *)[segue.destinationViewController topViewController];
        [self.itemInputController prepareForEditingKeyword:(NSManagedObject *)sender fromDelegate:self];
    } else if ([segue.identifier isEqual:@"editRelation"]) {
        self.itemInputController = (ItemInputController *)[segue.destinationViewController topViewController];
        [self.itemInputController prepareForEditingRelation:(NSManagedObject *)sender fromDelegate:self];
    } else
        NSLog(@"No handler defined for segue %@", segue.identifier);
}

#pragma mark - ItemInputDelegate Methods

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color {
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    Keyword *newKeyword = [Keyword createNewKeyword:keyword withLabel:label color:color inContext:self.managedObjectContext];
    newKeyword.keyword = keyword;
    newKeyword.label = label;
    newKeyword.color = color;
    [rootKeyword addChildrenObject:newKeyword];
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

- (void)createNewRelation:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color {
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    Relation *newRelation = [Relation createNewRelation:keyword withLabel:label color:color inContext:self.managedObjectContext];
    newRelation.keyword = keyword;
    newRelation.label = label;
    newRelation.color = color;
    [rootKeyword addRelationsObject:newRelation];
    NSLog(@"Created entity with relation: %@",keyword);
    
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

- (NSManagedObject *)changeTypeOfObject:(NSManagedObject *)managedObject {
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    if (managedObject.entity == [NSEntityDescription entityForName:@"Keyword" inManagedObjectContext:self.managedObjectContext]) {
        Keyword *keyword = (Keyword *)managedObject;
        Relation *newRelation = [Relation createNewRelation:keyword.keyword withLabel:keyword.label color:keyword.color inContext:self.managedObjectContext];
        [rootKeyword removeChildrenObject:keyword];
        [rootKeyword addRelationsObject:newRelation];
        return newRelation;
    } else if (managedObject.entity == [NSEntityDescription entityForName:@"Relation" inManagedObjectContext:self.managedObjectContext]) {
        Relation *relation = (Relation *)managedObject;
        Keyword *newKeyword = [Keyword createNewKeyword:relation.keyword withLabel:relation.label color:relation.color inContext:self.managedObjectContext];
        [rootKeyword removeRelationsObject:relation];
        [rootKeyword addChildrenObject:newKeyword];
        return newKeyword;
    } else {
        NSLog(@"Something went wrong in MasterViewController changeTypeOfObject:");
        return nil;
    }
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
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    
    switch (section) {
        case 0:
            retVal = [rootKeyword.children count];
            break;
        case 1:
            retVal = [rootKeyword.relations count];
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
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case 0:
                [rootKeyword removeObjectFromChildrenAtIndex:indexPath.row];
                break;
            case 1:
                [rootKeyword removeObjectFromRelationsAtIndex:indexPath.row];
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
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    Keyword *movingKeyword;
    Relation *movingRelation;
    switch (fromIndexPath.section) {
        case 0:
            movingKeyword = [rootKeyword.children objectAtIndex:fromIndexPath.row];
            [rootKeyword removeObjectFromChildrenAtIndex:fromIndexPath.row];
            [rootKeyword insertObject:movingKeyword inChildrenAtIndex:toIndexPath.row];
            break;
        case 1:
            movingRelation = [rootKeyword.relations objectAtIndex:fromIndexPath.row];
            [rootKeyword removeObjectFromRelationsAtIndex:fromIndexPath.row];
            [rootKeyword insertObject:movingRelation inRelationsAtIndex:toIndexPath.row];
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
    //NSManagedObject *object = [self getManagedObjectAtIndexPath:indexPath];
    MasterViewController *newVC = [[MasterViewController alloc]init];
    [self.navigationController pushViewController:newVC animated:YES];
    
    return;
    //self.detailViewController.detailItem = object;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *editingObject = [self getManagedObjectAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            [self performSegueWithIdentifier:@"editKeyword" sender:editingObject];
            [self.itemInputController prepareForEditingKeyword:editingObject fromDelegate:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"editRelation" sender:editingObject];
            [self.itemInputController prepareForEditingRelation:editingObject fromDelegate:self];
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
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    AbstractWord *returnWord;
    switch (indexPath.section) {
        case 0:
            if ([rootKeyword.children count] < indexPath.row+1)
                returnWord = nil;
            else
                returnWord = [rootKeyword.children objectAtIndex:indexPath.row];
            //controller = self.fetchedKeywordResultsController;
            break;
        case 1:
            if ([rootKeyword.relations count] < indexPath.row+1)
                returnWord = nil;
            else
                returnWord = [rootKeyword.relations objectAtIndex:indexPath.row];
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


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedKeywordResultsController {
    if (_fetchedKeywordResultsController != nil) {
        return _fetchedKeywordResultsController;
    }
    
    return [self fetchResultsControllerForEntity:@"Keyword"];
}

- (NSFetchedResultsController *)fetchedRelationResultsController {
    if (_fetchedRelationResultsController != nil) {
        return _fetchedRelationResultsController;
    }
    
    return [self fetchResultsControllerForEntity:@"Relation"];
}

- (NSFetchedResultsController *)fetchResultsControllerForEntity:(NSString *)name
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Define which entities we want to fetch: Keywords at the top level
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // make the keywords to be sorted by label
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keyword" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return aFetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
