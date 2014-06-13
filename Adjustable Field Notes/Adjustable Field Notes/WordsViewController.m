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

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = @"Word Sets";
    [self showWords:self];
}

- (void)insertNewObject:(id)sender {
    if (self.tableView.dataSource == self) {
        [self performSegueWithIdentifier:@"addWordSet" sender:self];
        if (self.inputController == nil) {
            NSLog(@"ItemInputController is nil!");
        }
        [self.inputController prepareForNewEntryFromDelegate:self];
    } else {
        [super insertNewObject:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
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
    } else
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
    
    [self reload];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    Keyword *keyword;
    
    if (indexPath.section == 0) {
        keyword = [Keyword getActiveWordSetForContext:self.managedObjectContext];
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
            keyword = [wordSets objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            cell.textLabel.text = keyword.keyword;
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:keyword.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        }
    } else {
        NSLog(@"Wrong indexPath indication in WordsViewController!");
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return NO;
    else
        return [super tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Keyword *keyword = (Keyword *)[self getManagedObjectAtIndexPath:indexPath];
        [keyword appendToGarbageCollector];
    }
    else
        return;
    [self.managedObjectContext save:nil];
    [self reload];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.dataSource != self) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    } else if (self.isEditing) {
        NSManagedObject *editingObject = [self getManagedObjectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"editWordSet" sender:editingObject];
        [self.inputController prepareForEditingWordSet:(Keyword *)[self getManagedObjectAtIndexPath:indexPath] fromDelegate:self];
        NSLog(@"Pressed Accessory Button");
    } else {
        [self performSegueWithIdentifier:@"showCategories" sender:[self getManagedObjectAtIndexPath:indexPath]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - helper method for dividing indexPaths between the two object types
- (NSManagedObject *)getManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Querying for section: %zd row: %zd",indexPath.section,indexPath.row);
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
