//
//  WordsViewController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 26.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "WordsViewController.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "WordSetInputController.h"
#import "CategoriesViewController.h"
#import "DetailViewController.h"

@implementation WordsViewController

@synthesize inputController;

#pragma mark - Overridden superclass Methods

- (void)insertNewObject:(id)sender
{
    [self performSegueWithIdentifier:@"addWordSet" sender:self];
    if (self.inputController == nil) {
        NSLog(@"ItemInputController is nil!");
    }
    [self.inputController prepareForNewEntryFromDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"addWordSet"]) {
        NSLog(@"preparing for segue addWordSet");
        self.inputController = (WordSetInputController *)[segue.destinationViewController topViewController];
        [self.inputController prepareForNewEntryFromDelegate:self];
    } else if ([segue.identifier isEqual:@"editWordSet"]) {
        self.inputController = (WordSetInputController *)[segue.destinationViewController topViewController];
        [self.inputController prepareForEditingWordSet:sender fromDelegate:self];
    } else if ([segue.identifier isEqualToString:@"showCategories"]) {
        CategoriesViewController *newViewController = (CategoriesViewController *) segue.destinationViewController;
        newViewController.wordSet = sender;
    }
    else
        NSLog(@"No handler defined for segue %@ in WordsViewController", segue.identifier);
}

#pragma mark - WordSetInputDelegate Methods

- (void)createNewWordSet:(NSString *)name withDate:(NSDate *)date active:(BOOL)active {
    Keyword *newKeyword = [Keyword createNewKeyword:name withLabel:@"" color:nil inContext:self.managedObjectContext];
    NSLog(@"Created entity for word set: %@",newKeyword.keyword);
    newKeyword.dateCreated = date;
    newKeyword.isActive = active;
    
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

- (void)reload {
    [self.managedObjectContext save:nil];
    [self.tableView reloadData];
    [self.detailViewController reload];
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
            header = @"Active";
            break;
        case 1:
            header = @"Inactive";
            break;
        default:
            header = @"";
            break;
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retVal = 0;
    
    switch (section) {
        case 0:
            retVal = 1;
            break;
        case 1:
            retVal = [[Keyword getInactiveWordSetsForContext:self.managedObjectContext]count];
            break;
        default:
            break;
    }
    
    if (retVal == 0) {
        retVal = 1;
    }
    
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.section == 0) {
        Keyword *keyword = [Keyword getActiveWordSetForContext:self.managedObjectContext];
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.text = keyword.keyword;
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:keyword.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    } else if (indexPath.section == 1) {
        NSArray *wordSets = [Keyword getInactiveWordSetsForContext:self.managedObjectContext];
        if ([wordSets count] == 0) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoneCell"];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = @"None";
            cell.detailTextLabel.text = @"";
        } else {
            Keyword *keyword = [wordSets objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            cell.textLabel.text = keyword.keyword;
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:keyword.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        }
    } else {
        NSLog(@"Wrong indexPath indication in WordsViewController!");
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [self.managedObjectContext deleteObject:[self getManagedObjectAtIndexPath:indexPath]];
    else
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *editingObject = [self getManagedObjectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"editWordSet" sender:editingObject];
    [self.inputController prepareForEditingWordSet:(Keyword *)[self getManagedObjectAtIndexPath:indexPath] fromDelegate:self];
    NSLog(@"Pressed Accessory Button");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showCategories" sender:[self getManagedObjectAtIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

//helper method for dividing indexPaths between the two object types
- (NSManagedObject *)getManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Querying for section: %zd row: %zd",indexPath.section,indexPath.row);
    Keyword *wordSet;
    NSArray *wordSets = [Keyword getInactiveWordSetsForContext:self.managedObjectContext];
    if (indexPath.section == 0) {
            wordSet = [Keyword getActiveWordSetForContext:self.managedObjectContext];
    }
    else if (indexPath.section == 1) {
            if ([wordSets count] == 0)
                wordSet = nil;
            else
                wordSet = [wordSets objectAtIndex:indexPath.row];
    } else
        wordSet = nil;
    
    return wordSet;
}

@end
