//
//  DetailViewController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 17.03.14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "DetailViewController.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "AppDelegate.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize managedObjectContext;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = nil;
    if (tableView == self.keywordTableview) {
        header = @"Keywords";
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retVal = 0;
    Keyword *rootKeyword = [Keyword getRootForContext:self.managedObjectContext];
    if (tableView == self.keywordTableview) {
        retVal = [rootKeyword.children count];
    }
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (tableView == self.keywordTableview) {
        Keyword *keyword = (Keyword *)[self getManagedObjectAtIndexPath:indexPath];
        cell.textLabel.text = keyword.label;
    } else if (tableView == self.recordingTableview) {
        
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
    [self.keywordTableview reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSManagedObject *object = [self getManagedObjectAtIndexPath:indexPath];
    return;
    //self.detailViewController.detailItem = object;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *editingObject = [self getManagedObjectAtIndexPath:indexPath];
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


@end
