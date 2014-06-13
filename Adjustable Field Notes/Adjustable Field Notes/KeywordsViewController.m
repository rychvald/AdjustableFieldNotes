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
    self.tableView.dataSource = self;
    [self reload];
}

- (void)insertNewObject:(id)sender {
    if (self.tableView.dataSource == self) {
        [self performSegueWithIdentifier:@"addItem" sender:self];
        if (self.itemInputController == nil) {
            NSLog(@"ItemInputController is nil!");
        }
        [self.itemInputController prepareForNewEntryFromDelegate:self];
    } else {
        [super insertNewObject:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqual:@"addItem"]) {
        self.itemInputController = (ItemInputController *)[segue.destinationViewController topViewController];
        [self.itemInputController prepareForNewEntryFromDelegate:self];
    } else if ([segue.identifier isEqual:@"editItem"]) {
        self.itemInputController = (ItemInputController *)[segue.destinationViewController topViewController];
        [self.itemInputController prepareForEditingKeyword:(NSManagedObject *)sender fromDelegate:self];
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
    
    [self reload];
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
    
    [self reload];
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.detailTextLabel.textColor =[UIColor grayColor];
        cell.textLabel.textColor = [UIColor blackColor];
        if (keyword.label == nil || [keyword.label isEqualToString:@""]) {
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = keyword.keyword;
        } else {
            cell.detailTextLabel.text = keyword.keyword;
            cell.textLabel.text = keyword.label;
        }
        cell.backgroundColor = self.category.color;
        if (cell.backgroundColor == [UIColor blueColor] || cell.backgroundColor == [UIColor purpleColor] || cell.backgroundColor == [UIColor grayColor]) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        else {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        }
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoneCell"];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"None";
        cell.detailTextLabel.text = @"";
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Keyword *keyword = (Keyword *)[self getManagedObjectAtIndexPath:indexPath];
        [self.category removeObjectFromChildrenAtIndex:indexPath.row];;
        [keyword appendToGarbageCollector];
    }
    else
        return;
    [self.managedObjectContext save:nil];
    [self reload];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    //if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
    //   return sourceIndexPath;
    //} else {
    return proposedDestinationIndexPath;
    //}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.dataSource != self) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    } else if (tableView.isEditing) {
        Keyword *editingObject = (Keyword *)[self getManagedObjectAtIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                [self performSegueWithIdentifier:@"editItem" sender:editingObject];
                [self.itemInputController prepareForEditingKeyword:editingObject fromDelegate:self];
                break;
            default:
                break;
        }
        NSLog(@"Pressed Accessory Button");
    } else {
        return;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != destinationIndexPath.section) {
        NSLog(@"Moving to different section!!!");
        return;
    } else {
        [self.category moveObjectAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
        [self reload];
    }
}

#pragma mark - helper method for dividing indexPaths between the two object types
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
