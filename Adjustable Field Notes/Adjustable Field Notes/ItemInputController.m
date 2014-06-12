//
//  ItemInputController.m
//  Adjustable Field Notes
//
//  Created by mars on 07.04.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import "ItemInputController.h"

@implementation ItemInputController

@synthesize label;
@synthesize keyword;
//@synthesize picker;
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
    
    self.typeChange = NO;
}

- (void)prepareForNewEntryFromDelegate:(id)delegate {
    self.currentObject = nil;
    self.inputDelegate = delegate;
    self.keyword.placeholder = @"Keyword";
    self.label.placeholder = @"Label (optional)";
    self.typeChange = NO;
    [self.tableView reloadData];
}

- (void)prepareForEditingKeyword:(NSManagedObject *)Keyword fromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.currentObject = Keyword;
    self.keyword.text = (NSString *)[Keyword valueForKey:@"keyword"];
    self.label.text = (NSString *)[Keyword valueForKey:@"label"];
    self.typeChange = NO;
    [self.tableView reloadData];
}

- (void)saveItem {
    NSLog(@"Saving item...");
    if (self.inputDelegate == nil) {
        NSLog(@"inputDelegate is nil!");
    }
    NSLog(@"Keyword: %@ Label: %@", self.keyword.text, self.label.text);
    if (self.currentObject == nil)
        [self.inputDelegate createNewKeyword:self.keyword.text withLabel:self.label.text andColor:nil];
    else {
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
