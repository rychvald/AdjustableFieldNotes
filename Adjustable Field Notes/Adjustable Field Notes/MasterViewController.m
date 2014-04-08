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

@implementation MasterViewController

@synthesize managedObjectContext;
@synthesize rootKeyword = _rootKeyword;

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

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (NSManagedObject *)rootKeyword {
    NSManagedObjectContext *context = self.managedObjectContext;
    if (_rootKeyword != nil) {
        return _rootKeyword;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Root"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"keyword like %@", @"root"]];
    if ([context countForFetchRequest:request error:nil] == 0) {
        _rootKeyword = [self createRootKeywordInContext:context];
    }
    else if ([context countForFetchRequest:request error:nil] == 1) {
        _rootKeyword = [[context executeFetchRequest:request error:nil] objectAtIndex:0];
    } else {
        NSLog(@"Something is not as it should be in the object model. Trying to continue anyway...");
        _rootKeyword = [[context executeFetchRequest:request error:nil] objectAtIndex:0];
    }

    return _rootKeyword;
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
    [self.itemInputController prepareForNewEntryFromDelegate:self];
    if (self.itemInputController == nil) {
        NSLog(@"ItemInputController is nil!");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"addItem"]) {
        self.itemInputController = (ItemInputController *)[[segue destinationViewController]topViewController];
        [self.itemInputController prepareForNewEntryFromDelegate:self];
    } else {
        NSLog(@"No handler defined for segue %@", segue.identifier);
    }
}

#pragma mark - ItemInputDelegate Methods

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Keyword" inManagedObjectContext:context];
    
    [newManagedObject setValue:keyword forKey:@"keyword"];
    [newManagedObject setValue:label forKey:@"label"];
    [newManagedObject setValue:self.rootKeyword forKey:@"parent"];
    
    NSLog(@"Created entity with keyword: %@",keyword);
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.tableView reloadData];
}

- (ItemInputController *)itemInputController {
    if (_itemInputController != nil) {
        return _itemInputController;
    } else {
        _itemInputController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemInputController"];
        return _itemInputController;
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
    NSFetchedResultsController *controller;
    switch (section) {
        case 0:
            controller = self.fetchedKeywordResultsController;
            break;
        case 1:
            controller = self.fetchedRelationResultsController;
            break;
        default:
            break;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [controller sections][0];
    NSInteger retVal = [sectionInfo numberOfObjects];
    
    if (retVal == 0) {
        retVal = 1;
    }
    
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSManagedObject *object = [self getManagedObjectAtIndexPath:indexPath];
    if (object != nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.detailTextLabel.textColor =[UIColor grayColor];
        cell.textLabel.textColor = [UIColor blackColor];
        if ([object valueForKey:@"label"] == nil) {
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = [[object valueForKey:@"keyword"] description];
        } else {
            cell.detailTextLabel.text = [[object valueForKey:@"label"] description];
            cell.textLabel.text = [[object valueForKey:@"keyword"] description];
        }
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoneCell" forIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = self.managedObjectContext;
        [context deleteObject:[self getManagedObjectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSManagedObject *object = [self getManagedObjectAtIndexPath:fromIndexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return sourceIndexPath;
    } else {
        return proposedDestinationIndexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSManagedObject *object = [self getManagedObjectAtIndexPath:indexPath];
    return;
    //self.detailViewController.detailItem = object;
}

//helper method for dividing indexPaths between the two object types
- (NSManagedObject *)getManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Fetching object for section: %ld with row: %ld", indexPath.section, (long)indexPath.row);
    NSFetchedResultsController *controller;
    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    switch (indexPath.section) {
        case 0:
            controller = self.fetchedKeywordResultsController;
            break;
        case 1:
            controller = self.fetchedRelationResultsController;
            break;
        default:
            return nil;;
            break;
    }
    if ([[controller fetchedObjects] count] == 0) {
        return nil;
    }
    return [controller objectAtIndexPath:myIndexPath];
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
