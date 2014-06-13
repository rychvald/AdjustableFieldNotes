//
//  CategoriesViewController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 26.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "CategoryInputController.h"
#import "KeywordsViewController.h"
#import "DetailViewController.h"

@implementation CategoriesViewController

@synthesize wordSet;
@synthesize inputController;

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"My Word Set: %@",self.wordSet.keyword);
    self.title = self.wordSet.keyword;
}

- (void)createNewCategory:(NSString *)name withColor:(UIColor *)color {
    Keyword *category = [Keyword createNewKeyword:name withLabel:nil color:color inContext:self.managedObjectContext];
    category.parent = self.wordSet;
    
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

#pragma mark - Overridden superclass Methods

- (void)insertNewObject:(id)sender
{
    [self performSegueWithIdentifier:@"addCategory" sender:self];
    if (self.inputController == nil) {
        NSLog(@"ItemInputController is nil!");
    }
    [self.inputController prepareForNewEntryFromDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"addCategory"]) {
        NSLog(@"preparing for segue addCategory");
        self.inputController = (CategoryInputController *)[segue.destinationViewController topViewController];
        [self.inputController prepareForNewEntryFromDelegate:self];
    } else if ([segue.identifier isEqual:@"editCategory"]) {
        self.inputController = (CategoryInputController *)[segue.destinationViewController topViewController];
        [self.inputController prepareForEditingCategory:sender fromDelegate:self];
    } else if ([segue.identifier isEqualToString:@"showKeywordsAndRelations"]) {
        KeywordsViewController *newViewController = (KeywordsViewController *) segue.destinationViewController;
        newViewController.category = sender;
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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header;
    switch (section) {
        case 0:
            header = @"Categories";
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
    
    retVal = [self.wordSet.children count];
    
    if (retVal == 0) {
        retVal = 1;
    }
    
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSOrderedSet *wordSets = self.wordSet.children;
    if ([wordSets count] == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoneCell"];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"None";
    } else {
        Keyword *keyword = [wordSets objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.text = keyword.keyword;
        cell.detailTextLabel.text = @"";
        cell.backgroundColor = keyword.color;
        if (cell.backgroundColor == [UIColor blueColor] || cell.backgroundColor == [UIColor purpleColor] || cell.backgroundColor == [UIColor grayColor])
            cell.textLabel.textColor = [UIColor whiteColor];
        else
            cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.wordSet removeObjectFromChildrenAtIndex:indexPath.row];
    }
    else
        return;
    
    [self.managedObjectContext save:nil];
    [self reload];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        NSManagedObject *editingObject = [self getManagedObjectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"editCategory" sender:editingObject];
        [self.inputController prepareForEditingCategory:(Keyword *)[self getManagedObjectAtIndexPath:indexPath] fromDelegate:self];
        NSLog(@"Pressed Accessory Button");
    } else {
        [self performSegueWithIdentifier:@"showKeywordsAndRelations" sender:[self getManagedObjectAtIndexPath:indexPath]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != destinationIndexPath.section) {
        NSLog(@"Moving to different section!!!");
        return;
    } else {
        [self.wordSet moveObjectAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
        [self reload];
    }
}

//helper method for dividing indexPaths between the two object types
- (NSManagedObject *)getManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Querying for section: %zd row: %zd",indexPath.section,indexPath.row);
    if ([self.wordSet.children count] > 0)
        return [self.wordSet.children objectAtIndex:indexPath.row];
    else
        return nil;
}

@end
