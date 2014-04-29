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
#import "Recording.h"
#import "Recording+Additions.h"
#import "Entry.h"
#import "Entry+Additions.h"
#import "KeywordCell.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize managedObjectContext;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork.png"]];
    self.title = [Recording getActiveRecordingForContext:self.managedObjectContext].name;
    [self reload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger retVal;
    switch (section) {
        case 0:
            retVal = [[self selectedCategory].children count];
            break;
        case 1:
            retVal = [[self selectedCategory].relations count];
            break;
        default:
            retVal = 0;
            break;
    }
    NSLog(@"Number of Item in section :%zd is: %zd",section,retVal);
    return retVal;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KeywordCell *cell = (KeywordCell *)[cv dequeueReusableCellWithReuseIdentifier:@"WordCell" forIndexPath:indexPath];
    AbstractWord *word;
    switch (indexPath.section) {
        case 0:
            word = [[self selectedCategory].children objectAtIndex:indexPath.row];
            break;
        case 1:
            //word = [[self selectedCategory].relations objectAtIndex:indexPath.row];
            break;
        default:
            word = nil;
            NSLog(@"Wrong section in collection view in detailViewController!");
            break;
    }
    NSLog(@"Word: %@",word.keyword);
    //cell.backgroundColor = [UIColor blueColor];//[self selectedCategory].color;
    if (word.label == nil || [word.label isEqualToString:@""]) {
        cell.label.text = word.keyword;
    } else {
        cell.label.text = word.keyword;
    }
    
    return cell;
}
// 4
/*- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
return [[UICollectionReusableView alloc] init];
}*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Select Item
    return;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
    return;
}

#pragma mark – UICollectionViewDelegateFlowLayout

/*- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //UICollectionViewCell *cell = [self.keywordCollectionView dequeueReusableCellWithReuseIdentifier:@"WordCell" forIndexPath:indexPath];
    CGSize retval = CGSizeMake(57,25);
    //retval.height += 35; retval.width += 35;
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = nil;
    if (tableView == self.categoriesTableview) {
        header = @"Categories";
    } else if (tableView == self.recordingTableview) {
        header = @"";
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger retVal = 0;
    if (tableView == self.categoriesTableview) {
        retVal = [[Keyword getActiveWordSetForContext:self.managedObjectContext].children count];
    } else if (tableView == self.recordingTableview) {
        retVal = [[Recording getActiveRecordingForContext:self.managedObjectContext].entries count];
    }
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    if (tableView == self.categoriesTableview) {
        Keyword *keyword = [[Keyword getActiveWordSetForContext:self.managedObjectContext].children objectAtIndex:indexPath.row];
        NSLog(@"Creating category cell for keyword %@",keyword.keyword);
        cell.textLabel.text = keyword.keyword;
        cell.backgroundColor = keyword.color;
    } else if (tableView == self.recordingTableview) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EntryCell" forIndexPath:indexPath];
        Entry *entry = [[Recording getActiveRecordingForContext:self.managedObjectContext].entries objectAtIndex:indexPath.row];
        cell.textLabel.text = [entry asString];
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:entry.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Keyword *rootKeyword = [Keyword getActiveWordSetForContext:self.managedObjectContext];
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.categoriesTableview reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    Keyword *category = (Keyword *)[[Keyword getActiveWordSetForContext:self.managedObjectContext].children objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [self lighterColorForColor:category.color];
    [self.keywordCollectionView reloadData];
    return;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *editingObject = [self getManagedObjectAtIndexPath:indexPath];
    NSLog(@"Pressed Accessory Button");
}

- (void)reload {
    [self.categoriesTableview reloadData];
    [self.recordingTableview reloadData];
    [self.keywordCollectionView reloadData];
}

#pragma mark - Helper Methods

- (UIColor *)lighterColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.5, 1.0)
                               green:MIN(g + 0.5, 1.0)
                                blue:MIN(b + 0.5, 1.0)
                               alpha:a];
    return nil;
}

- (Keyword *)selectedCategory {
    NSLog(@"retrieving selected category");
    NSIndexPath *indexPath = [self.categoriesTableview indexPathForSelectedRow];
    Keyword *category;
    if (indexPath == nil) {
        NSLog(@"indexPath in categoriesView is Nil!");
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.categoriesTableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else if ([[Keyword getActiveWordSetForContext:self.managedObjectContext].children count] == 0)
        category =  nil;
    else {
        category = [[Keyword getActiveWordSetForContext:self.managedObjectContext].children objectAtIndex:indexPath.row];
    }
    NSLog(@"retrieving selected category: %@",category.keyword);
    return category;
}

@end
