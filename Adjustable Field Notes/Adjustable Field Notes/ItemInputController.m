//
//  ItemInputController.m
//  Adjustable Field Notes
//
//  Created by mars on 07.04.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import "ItemInputController.h"

@implementation ItemInputController

@synthesize labelCell;
@synthesize keywordCell;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveItem)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)prepareForNewEntry {
    self.labelCell.textLabel.text = @"Label";
    self.keywordCell.textLabel.text = @"Keyword (leave empty if same as label)";
}

- (void)saveItem {
    [self cancel];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
