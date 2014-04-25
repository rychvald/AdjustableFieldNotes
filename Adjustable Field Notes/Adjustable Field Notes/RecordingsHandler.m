//
//  RecordingsHandler.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "RecordingsHandler.h"
#import "Recording.h"
#import "Recording+Additions.h"
#import "AppDelegate.h"

@implementation RecordingsHandler

@synthesize managedObjectContext;
@synthesize recordings;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [self reloadRecordings];
}

- (void)reloadRecordings {
    self.recordings = [Recording getAllRecordingsInContext:self.managedObjectContext];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    //return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    switch (section) {
        case 0:
            header = @"Active Recording";
            break;
        case 1:
            header = @"Inactve Recordings";
        default:
            break;
    }
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSFetchedResultsController *controller;
    NSInteger retVal = 1;
    if (section == 0) {
        retVal = [self.recordings count];
    }
    
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
    return;
    //self.detailViewController.detailItem = object;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Pressed Accessory Button");
}

@end
