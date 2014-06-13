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
    NSLog(@"Fetching cell for row: %zd in Section: %zd",indexPath.row,indexPath.section);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingCell" forIndexPath:indexPath];
    Recording *recording;
    
    if (indexPath.section == 0) {
        recording = [Recording getActiveRecordingForContext:self.managedObjectContext];
        cell.textLabel.text = recording.name;
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:recording.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    } else if (indexPath.section == 1) {
        NSArray *recordings = [Recording getInactiveRecordingsForContext:self.managedObjectContext];
        if ([recordings count] != 0) {
            recording = [recordings objectAtIndex:indexPath.row];
            cell.textLabel.text = recording.name;
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:recording.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoneCell"];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = @"None";
            cell.detailTextLabel.text = @"";
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
    else
        return [super tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Recording *recording = [[Recording getRecordingsInContext:self.managedObjectContext]objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete && !recording.isActive) {
        [self.managedObjectContext deleteObject:recording];
    } else
        return;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self reloadRecordings];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    return;
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
    NSLog(@"Pressed Accessory Button");
}

@end
