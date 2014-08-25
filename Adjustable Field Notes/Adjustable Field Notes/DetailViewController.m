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
#import "EntryTextField.h"
#import "CommentInputController.h"
#import "MasterVCTemplate.h"
#import "CollectionViewHeaderWithTitle.h"

#define MARGIN 10
#define TOP_MARGIN 5

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize managedObjectContext;
@synthesize commentIC;

#pragma mark - UIViewController lifecycle

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.recordingTableview.contentSize.height > self.recordingTableview.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.recordingTableview.contentSize.height - self.recordingTableview.frame.size.height);
        [self.recordingTableview setContentOffset:offset animated:NO];
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Remove Last Entry", nil) style:UIBarButtonItemStylePlain target:self action:@selector(removeLastEntry:)];
    self.navigationItem.rightBarButtonItems = @[removeButton];
    [self.backspaceButton setTitle:NSLocalizedString(@"Backspace", nil) forState:UIControlStateNormal];
    [self.clearButton setTitle:NSLocalizedString(@"Clear", nil) forState:UIControlStateNormal];
    [self.commitButton setTitle:NSLocalizedString(@"Commit", nil) forState:UIControlStateNormal];
    [self setCollectionViewMargins];
}

#pragma mark - Methods for Toolbar buttons

- (void)setCollectionViewMargins {
    self.flowLayout.sectionInset = UIEdgeInsetsMake(TOP_MARGIN, MARGIN, MARGIN, MARGIN);
    self.flowLayout.minimumInteritemSpacing = MARGIN;
}

#pragma mark - Methods for Toolbar buttons

- (void)removeLastEntry:(id)sender {
    Recording *recording = [Recording getActiveRecordingForContext:self.managedObjectContext];
    if ([recording.entries count] <= 0) {
        return;
    } else {
        Entry *lastentry = [recording.entries lastObject];
        [recording removeEntriesObject:lastentry];
        [self.managedObjectContext deleteObject:lastentry];
        [self.managedObjectContext save:nil];
        [self reload];
    }
}



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
    if (self.recordingTableview.contentSize.height > self.recordingTableview.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.recordingTableview.contentSize.height - self.recordingTableview.frame.size.height);
        [self.recordingTableview setContentOffset:offset animated:NO];
    }
    [self reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:
(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Word Sets", @"Word Sets");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Method for committing entries from EntryTextField

- (IBAction)commit:(id)sender {
    [self.inputField commitToRecording:[Recording getActiveRecordingForContext:self.managedObjectContext]];
    [self.inputField removeAllKeywords:nil];
    [self reload];
    [self selectLastEntry];
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger retVal;
    Keyword *category = [[Keyword getActiveWordSetForContext:self.managedObjectContext].children objectAtIndex:section];
    retVal = [category.children count];
    NSLog(@"Number of Item in section :%zd is: %zd",section,retVal);
    return retVal;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [[Keyword getActiveWordSetForContext:self.managedObjectContext].children count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KeywordCell *cell = (KeywordCell *)[cv dequeueReusableCellWithReuseIdentifier:@"WordCell" forIndexPath:indexPath];
    Keyword *word = [self getKeywordForIndexPath:indexPath];
    //NSLog(@"Word: %@",word.keyword);
    //cell.backgroundColor = [UIColor blueColor];//[self selectedCategory].color;
    cell.keyword = word;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        CollectionViewHeaderWithTitle *headerWithTitle = (CollectionViewHeaderWithTitle *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        Keyword *category = [[Keyword getActiveWordSetForContext:self.managedObjectContext].children objectAtIndex:indexPath.section];
        [headerWithTitle setLabelString:category.keyword];
        reusableView = headerWithTitle;
    } else if (kind == UICollectionElementKindSectionFooter) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
    }
    
    return reusableView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Keyword *keyword = [self getKeywordForIndexPath:indexPath];
    NSLog(@"selected %@",keyword.keyword);
    [self.inputField addKeyword:keyword];
    return;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = nil;
    header = @"";
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger retVal = 0;
    retVal = [[Recording getActiveRecordingForContext:self.managedObjectContext].entries count];
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntryCell" forIndexPath:indexPath];
    Entry *entry = [[Recording getActiveRecordingForContext:self.managedObjectContext].entries objectAtIndex:indexPath.row];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:entry.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    cell.textLabel.text = [dateString stringByAppendingFormat:@" %@",[entry asLabelString]];
    cell.detailTextLabel.text = entry.comment;
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showPopoverForCellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Pressed Accessory Button");
}

- (void)reload {
    [self.recordingTableview reloadData];
    [self.keywordCollectionView reloadData];
    self.title = [Recording getActiveRecordingForContext:self.managedObjectContext].name;
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

- (Keyword *)getKeywordForIndexPath:(NSIndexPath *)indexPath {
    Keyword *category = [[Keyword getActiveWordSetForContext:self.managedObjectContext].children objectAtIndex:indexPath.section];
    return [category.children objectAtIndex:indexPath.row];
}

- (void)selectLastEntry {
    NSInteger lastrow = [self.recordingTableview numberOfRowsInSection:0]-1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastrow inSection:0];
    [self.recordingTableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [self.recordingTableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    [self tableView:self.recordingTableview didSelectRowAtIndexPath:indexPath];
}

- (void)showPopoverForCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.recordingTableview cellForRowAtIndexPath:indexPath];
    Entry *entry = [[Recording getActiveRecordingForContext:self.managedObjectContext].entries objectAtIndex:indexPath.row];
    if (self.commentIC == nil) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.commentIC = (CommentInputController *)[sb instantiateViewControllerWithIdentifier:@"commentVC"];
    }
    [self reload];
    if (self.popoverVC == nil) {
        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:self.commentIC];
    }
    [self.commentIC prepareForEditingEntry:entry fromDelegate:self withPopover:self.popoverVC];
    [self.popoverVC presentPopoverFromRect:cell.bounds inView:cell permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - Comment Input Delegate

- (void) releaseSelection {
    if (self.recordingTableview == nil) {
        NSLog(@"RecordingTableView is nil!");
    }
    NSLog(@"Releasing row: %ld in section: %ld",(long)[self.recordingTableview indexPathForSelectedRow].row,(long)[self.recordingTableview indexPathForSelectedRow].section);
    [self.recordingTableview deselectRowAtIndexPath:[self.recordingTableview indexPathForSelectedRow] animated:YES];
}

@end
