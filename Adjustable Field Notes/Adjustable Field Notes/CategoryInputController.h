//
//  CategoriesInputController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 27.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"

@protocol CategoryInputDelegate <NSObject>

- (void)createNewCategory:(NSString *)name withColor:(UIColor *)color;
- (void)reload;

@end

@interface CategoryInputController : UITableViewController <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,retain) IBOutlet UIPickerView *picker;
@property (nonatomic,retain) IBOutlet UITextField *name;
@property (nonatomic,retain) Keyword *currentCategory;
@property (strong, nonatomic) id<CategoryInputDelegate> inputDelegate;

- (void)prepareForNewEntryFromDelegate:(id)delegate;
- (void)prepareForEditingCategory:(Keyword *)category fromDelegate:(id)delegate;

+ (NSArray *)colors;
+ (NSArray *)colorStrings;

@end
