//
//  ItemInputController.m
//  Adjustable Field Notes
//
//  Created by mars on 07.04.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import "ItemInputController.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"

@implementation ItemInputController

@synthesize labelField;
@synthesize keywordField;
//@synthesize picker;
@synthesize currentKeyword;
@synthesize inputDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveItem)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)prepareForNewEntryFromDelegate:(id)delegate {
    self.currentKeyword = nil;
    self.inputDelegate = delegate;
    self.keywordField.placeholder = @"Keyword";
    self.labelField.placeholder = @"Label (optional)";
    [self.tableView reloadData];
}

- (void)prepareForEditingKeyword:(Keyword *)keyword fromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.currentKeyword = keyword;
    self.keywordField.text = self.currentKeyword.keyword;
    self.labelField.text = self.currentKeyword.keyword;
    [self.tableView reloadData];
}

- (void)saveItem {
    NSLog(@"Saving item...");
    if (self.inputDelegate == nil) {
        NSLog(@"inputDelegate is nil!");
    }
    NSLog(@"Keyword: %@ Label: %@", self.keywordField.text, self.labelField.text);
    if (self.currentKeyword == nil)
        [self.inputDelegate createNewKeyword:self.keywordField.text withLabel:self.labelField.text andColor:nil];
    else {
        self.currentKeyword.keyword = self.keywordField.text;
        self.currentKeyword.label = self.labelField.text;
    }
    [self.currentKeyword.managedObjectContext save:nil];
    [self cancel];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.currentKeyword = nil;
    [self.inputDelegate reload];
}

#pragma mark - UITextField Delegate method

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self saveItem];
    return YES;
}

#pragma mark - Class Helper Methods for Color

/*- (NSInteger)getRowForColor:(UIColor *)color {
    NSArray *colors = [CategoryInputController colors];
    for (int i = 0; i < [colors count]; i++) {
        if (colors[i] == color) {
            return i;
        }
    }
    return 0;
}

+ (NSArray *)colors {
    return @[
             [UIColor whiteColor],
             [UIColor yellowColor],
             [UIColor redColor],
             [UIColor purpleColor],
             [UIColor orangeColor],
             [UIColor magentaColor],
             [UIColor greenColor],
             [UIColor cyanColor],
             [UIColor blueColor],
             [UIColor grayColor],
             ];
}

+ (NSArray *)colorStrings {
    
    return @[
             @"White",
             @"Yellow",
             @"Red",
             @"Purple",
             @"Orange",
             @"Magenta",
             @"Green",
             @"Cyan",
             @"Blue",
             @"Gray",
             ];
}
*/
@end
