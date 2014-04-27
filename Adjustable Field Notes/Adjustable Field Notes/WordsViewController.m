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

@implementation WordsViewController

@synthesize inputController;

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
    if ([segue.identifier isEqual:@"addWordSet."]) {
        self.inputController = (WordSetInputController *)[segue.destinationViewController topViewController];
        [self.inputController prepareForNewEntryFromDelegate:self];
    } else if ([segue.identifier isEqual:@"editWordSet"]) {
        self.inputController = (WordSetInputController *)[segue.destinationViewController topViewController];
        [self.inputController prepareForEditingWordSet:sender fromDelegate:self];
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

@end
