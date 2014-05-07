//
//  KeywordsViewController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 26.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "KeywordsViewController.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "Relation.h"
#import "Relation+RelationAccessors.h"

@implementation KeywordsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"My Word Set: %@",self.category.keyword);
    self.title = self.category.keyword;
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
    Keyword *newKeyword = [Keyword createNewKeyword:keyword withLabel:label color:color inContext:self.managedObjectContext];
    newKeyword.keyword = keyword;
    newKeyword.label = label;
    newKeyword.color = color;
    [self.category addChildrenObject:newKeyword];
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
    Relation *newRelation = [Relation createNewRelation:keyword withLabel:label color:color inContext:self.managedObjectContext];
    newRelation.keyword = keyword;
    newRelation.label = label;
    newRelation.color = color;
    [self.category addRelationsObject:newRelation];
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
    if (managedObject.entity == [NSEntityDescription entityForName:@"Keyword" inManagedObjectContext:self.managedObjectContext]) {
        Keyword *keyword = (Keyword *)managedObject;
        Relation *newRelation = [Relation createNewRelation:keyword.keyword withLabel:keyword.label color:keyword.color inContext:self.managedObjectContext];
        [self.category removeChildrenObject:keyword];
        [self.category addRelationsObject:newRelation];
        return newRelation;
    } else if (managedObject.entity == [NSEntityDescription entityForName:@"Relation" inManagedObjectContext:self.managedObjectContext]) {
        Relation *relation = (Relation *)managedObject;
        Keyword *newKeyword = [Keyword createNewKeyword:relation.keyword withLabel:relation.label color:relation.color inContext:self.managedObjectContext];
        [self.category removeRelationsObject:relation];
        [self.category addChildrenObject:newKeyword];
        return newKeyword;
    } else {
        NSLog(@"Something went wrong in MasterViewController changeTypeOfObject:");
        return nil;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger retVal = 0;
    
    switch (section) {
        case 0:
            retVal = [self.category.children count];
            break;
        case 1:
            retVal = [self.category.relations count];
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
        if (keyword.label == nil || [keyword.label isEqualToString:@""]) {
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = keyword.keyword;
        } else {
            cell.detailTextLabel.text = keyword.keyword;
            cell.textLabel.text = keyword.label;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case 0:
                [self.category removeObjectFromChildrenAtIndex:indexPath.row];
                break;
            case 1:
                [self.category removeObjectFromRelationsAtIndex:indexPath.row];
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
            movingKeyword = [self.category.children objectAtIndex:fromIndexPath.row];
            [self.category removeObjectFromChildrenAtIndex:fromIndexPath.row];
            [self.category insertObject:movingKeyword inChildrenAtIndex:toIndexPath.row];
            break;
        case 1:
            movingRelation = [self.category.relations objectAtIndex:fromIndexPath.row];
            [self.category removeObjectFromRelationsAtIndex:fromIndexPath.row];
            [self.category insertObject:movingRelation inRelationsAtIndex:toIndexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return;
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
    AbstractWord *returnWord;
    switch (indexPath.section) {
        case 0:
            if ([self.category.children count] < indexPath.row+1)
                returnWord = nil;
            else
                returnWord = [self.category.children objectAtIndex:indexPath.row];
            break;
        case 1:
            if ([self.category.relations count] < indexPath.row+1)
                returnWord = nil;
            else
                returnWord = [self.category.relations objectAtIndex:indexPath.row];
            break;
        default:
            return nil;;
            break;
    }
    return returnWord;
}

@end
