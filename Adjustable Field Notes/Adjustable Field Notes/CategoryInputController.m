//
//  CategoriesInputController.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 27.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "CategoryInputController.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"

@implementation CategoryInputController

@synthesize picker;
@synthesize name;
@synthesize currentCategory;
@synthesize inputDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveItem)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)prepareForNewEntryFromDelegate:(id)delegate {
    self.inputDelegate = delegate;
    self.name.placeholder = NSLocalizedString(@"New Category", nil);
    self.title = NSLocalizedString(@"New Category", nil);
    [self.tableView reloadData];
}

- (void)prepareForEditingCategory:(Keyword *)category fromDelegate:(id)delegate {
    self.currentCategory = category;
    self.title = category.keyword;
    self.inputDelegate = delegate;
    self.name.text = category.keyword;
    [self.picker selectRow:[self getRowForColor:category.color] inComponent:0 animated:NO];
    [self.tableView reloadData];
}

- (void)saveItem {
    if (self.inputDelegate == nil) {
        NSLog(@"inputDelegate is nil!");
    }
    if (self.currentCategory == nil) {
        NSArray *colors = [CategoryInputController colors];
        [self.inputDelegate createNewCategory:self.name.text withColor:[colors objectAtIndex:[self.picker selectedRowInComponent:0]]];
    } else {
        self.currentCategory.keyword = self.name.text;
        NSArray *colors = [CategoryInputController colors];
        self.currentCategory.color = [colors objectAtIndex:[self.picker selectedRowInComponent:0]];
    }
    [self.currentCategory.managedObjectContext save:nil];
    [self cancel];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.currentCategory = nil;
    [self.inputDelegate reload];
}

#pragma mark - UIPickerViewDataSource Methods


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

#pragma mark - UIPickerViewDelegate Methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    return;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[CategoryInputController colorStrings]objectAtIndex:row];
}

#pragma mark - UITableView DataSource method

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header;
    switch (section) {
        case 0:
            header = NSLocalizedString(@"Name", nil);
            break;
        case 1:
            header = NSLocalizedString(@"Colour", nil);
            break;
        default:
            header = @"";
            break;
    }
    return header;
}

#pragma mark - UITextField Delegate method

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Class Helper Methods for Color

- (NSInteger)getRowForColor:(UIColor *)color {
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
             NSLocalizedString(@"White", nil),
             NSLocalizedString(@"Yellow", nil),
             NSLocalizedString(@"Red", nil),
             NSLocalizedString(@"Purple", nil),
             NSLocalizedString(@"Orange", nil),
             NSLocalizedString(@"Magenta", nil),
             NSLocalizedString(@"Green", nil),
             NSLocalizedString(@"Cyan", nil),
             NSLocalizedString(@"Blue", nil),
             NSLocalizedString(@"Gray", nil),
             ];
}

@end
