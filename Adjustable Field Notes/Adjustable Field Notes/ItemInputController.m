//
//  ItemInputController.m
//  Adjustable Field Notes
//
//  Created by mars on 07.04.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import "ItemInputController.h"

@implementation ItemInputController

@synthesize typeSelector;
@synthesize label;
@synthesize keyword;
@synthesize color;
@synthesize currentObject;
@synthesize inputDelegate;
@synthesize typeChange;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveItem)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self.typeSelector setTitle:@"Keyword" forSegmentAtIndex:0];
    [self.typeSelector setTitle:@"Relation" forSegmentAtIndex:1];
    self.typeChange = NO;
}

- (void)prepareForNewEntryFromDelegate:(id)delegate {
    self.currentObject = nil;
    self.inputDelegate = delegate;
    self.typeSelector.selectedSegmentIndex = 0;
    self.keyword.placeholder = @"Keyword";
    self.label.placeholder = @"Label (optional)";
    self.color.placeholder = @"White";
    self.typeChange = NO;
    [self.tableView reloadData];
}

- (void)prepareForEditingKeyword:(NSManagedObject *)Keyword fromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.currentObject = Keyword;
    self.typeSelector.selectedSegmentIndex = 0;
    self.keyword.text = (NSString *)[Keyword valueForKey:@"keyword"];
    self.label.text = (NSString *)[Keyword valueForKey:@"label"];
    self.color.text = (NSString *)[Keyword valueForKey:@"color"];
    self.typeChange = NO;
    [self.tableView reloadData];
}

- (void)prepareForEditingRelation:(NSManagedObject *)Keyword fromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.currentObject = Keyword;
    self.typeSelector.selectedSegmentIndex = 1;
    self.keyword.text = (NSString *)[Keyword valueForKey:@"keyword"];
    self.label.text = (NSString *)[Keyword valueForKey:@"label"];
    self.color.text = (NSString *)[Keyword valueForKey:@"color"];
    [self.tableView reloadData];
}

- (IBAction)typeChanged:(id)sender {
    if ([self.currentObject.entity.name isEqualToString:@"Keyword"] && self.typeSelector.selectedSegmentIndex == 1)
        self.typeChange = YES;
    else if ([self.currentObject.entity.name isEqualToString:@"Relation"] && self.typeSelector.selectedSegmentIndex == 0)
        self.typeChange = YES;
    else
        self.typeChange = NO;
}

- (void)changeType {
    if (self.currentObject == nil) {
        return;
    } else {
        self.currentObject = [self.inputDelegate changeTypeOfObject:self.currentObject];
    }
    self.typeChange = NO;
}

- (void)saveItem {
    NSLog(@"Saving item...");
    if (self.inputDelegate == nil) {
        NSLog(@"inputDelegate is nil!");
    }
    NSLog(@"Keyword: %@ Label: %@", self.keyword.text, self.label.text);
    if (self.currentObject == nil)
        switch (self.typeSelector.selectedSegmentIndex) {
            case 0:
                [self.inputDelegate createNewKeyword:self.keyword.text withLabel:self.label.text andColor:nil];
                break;
            case 1:
                [self.inputDelegate createNewRelation:self.keyword.text withLabel:self.label.text andColor:nil];
                break;
            default:
                break;
        }
    else {
        if (self.typeChange)
            [self changeType];
        [self.currentObject setValue:self.keyword.text forKey:@"keyword"];
        [self.currentObject setValue:self.label.text forKey:@"label"];
    }
    [self cancel];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.currentObject = nil;
    [self.inputDelegate reload];
}

@end
