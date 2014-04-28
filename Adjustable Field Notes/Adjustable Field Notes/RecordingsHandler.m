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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    switch (section) {
        case 0:
            header = @"Select Active Record";
            break;
        default:
            break;
    }
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.managedObjectContext == nil) {
        NSLog(@"ManagedObjectContext is nil!");
    }
    
    NSInteger retVal = [[Recording getRecordingsInContext:self.managedObjectContext]count];
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Fetching cell for row: %zd in Section: %zd",indexPath.row,indexPath.section);
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingCell" forIndexPath:indexPath];
    Recording *recording = [[Recording getRecordingsInContext:self.managedObjectContext]objectAtIndex:indexPath.row];
    cell.textLabel.text = recording.name;
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:recording.dateCreated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    if (recording.isActive)
        cell.accessoryView.hidden = NO;
    else
        cell.accessoryView.hidden = YES;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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
    [self.tableView reloadData];
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
