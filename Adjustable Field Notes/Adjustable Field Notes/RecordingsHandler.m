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
#import "WordSetInputController.h"

@implementation RecordingsHandler

@synthesize managedObjectContext;
@synthesize inputController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.title = @"Records";
}

- (void)reloadRecordings {
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    switch (section) {
        case 0:
            header = @"Active";
            break;
        case 1:
            header = @"Inactive";
        default:
            break;
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.managedObjectContext == nil) {
        NSLog(@"ManagedObjectContext is nil!");
    }
    NSInteger retVal = 0;
    switch (section) {
        case 0:
            retVal = 1;
            break;
        case 1:
            retVal = [[Recording getInactiveRecordingsForContext:self.managedObjectContext]count];
            break;
        default:
            break;
    }
    
    if (retVal == 0) {
        retVal = 1;
    }
    
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Fetching cell for row: %zd in Section: %zd",indexPath.row,indexPath.section);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingCell"];
    Recording *recording;
    
    if (indexPath.section == 0) {
        recording = [Recording getActiveRecordingForContext:self.managedObjectContext];
        cell.textLabel.text = recording.name;
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:recording.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    } else if (indexPath.section == 1) {
        NSArray *recordings = [Recording getInactiveRecordingsForContext:self.managedObjectContext];
        if ([recordings count] == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoneCell"];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = @"None";
            cell.detailTextLabel.text = @"";
        } else {
            recording = [recordings objectAtIndex:indexPath.row];
            cell.textLabel.text = recording.name;
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:recording.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        }
    } else {
        NSLog(@"Wrong indexPath indication in WordsViewController!");
    }
    if (cell == nil) {
        NSLog(@"Cell in RecordingsHandler is nil!");
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return NO;
    else if ([self getRecordingAtIndexPath:indexPath] == nil)
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Recording *recording = [self getRecordingAtIndexPath:indexPath];
        NSLog(@"Deleting Recording %@",recording.name);
        [self.managedObjectContext deleteObject:recording];
    } else
        return;
    [self.managedObjectContext save:nil];
    [tableView reloadData];
}

#pragma mark - helper method for dividing indexPaths between the two object types
- (Recording *)getRecordingAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Querying for section: %zd row: %zd",indexPath.section,indexPath.row);
    Recording *recording;
    if (indexPath.section == 0) {
        recording = [Recording getActiveRecordingForContext:self.managedObjectContext];
    } else if (indexPath.section == 1) {
        NSArray *recordings = [Recording getInactiveRecordingsForContext:self.managedObjectContext];
        if ([recordings count] == 0)
            recording = nil;
        else
            recording = [recordings objectAtIndex:indexPath.row];
    } else
        recording = nil;
    
    return recording;
}

@end
