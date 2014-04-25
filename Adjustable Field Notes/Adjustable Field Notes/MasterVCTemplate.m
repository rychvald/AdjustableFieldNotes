//
//  MasterVCTemplate.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "MasterVCTemplate.h"

#import "DetailViewController.h"
#import "ItemInputController.h"
#import "AppDelegate.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "Relation.h"
#import "Relation+RelationAccessors.h"
#import "AppDelegate.h"
#import "RecordingsHandler.h"

@implementation MasterVCTemplate

@synthesize myKeyword;
@synthesize managedObjectContext;
@synthesize itemInputController;
@synthesize itemInputNC;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    //init top bar buttons
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    //init bottom bar buttons
    UIBarButtonItem *recordsButton = [[UIBarButtonItem alloc] initWithTitle:@"Records" style:UIBarButtonItemStylePlain target:self action:@selector(showRecords:)];
    UIBarButtonItem *wordsButton = [[UIBarButtonItem alloc] initWithTitle:@"Words" style:UIBarButtonItemStylePlain target:self action:@selector(showWords:)];
    UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(import:)];
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(export:)];
    [self setToolbarItems:@[recordsButton,wordsButton,importButton,exportButton]];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (NSManagedObject *)createRootKeywordInContext:(NSManagedObjectContext *)context {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Root" inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue:@"root" forKey:@"keyword"];
    [context insertObject:newManagedObject];
    return newManagedObject;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Methods for Toolbar buttons

- (void)showRecords:(id)sender {
    RecordingsHandler *handler = [(AppDelegate *)[[UIApplication sharedApplication] delegate] recordingsHandler];
    self.tableView.dataSource = handler;
    self.tableView.delegate = handler;
    [self.tableView reloadData];
}

- (void)showWords:(id)sender {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
}

- (void)import:(id)sender {
    
}

- (void)export:(id)sender {
    
}

- (void)reload {
    [self.tableView reloadData];
}

@end
