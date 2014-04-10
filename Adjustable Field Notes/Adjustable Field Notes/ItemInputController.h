//
//  ItemInputController.h
//  Adjustable Field Notes
//
//  Created by mars on 07.04.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemInputDelegate <NSObject>

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color;

@end

@interface ItemInputController : UITableViewController

@property (nonatomic, retain) IBOutlet UITextField *label;
@property (nonatomic, retain) IBOutlet UITextField *keyword;
@property (nonatomic, retain) IBOutlet UITextField *color;
@property (strong, nonatomic) id<ItemInputDelegate> inputDelegate;

- (void)prepareForNewEntryFromDelegate:(id)delegate;
- (void)prepareForEditingKeyword:(NSManagedObject *)keyword fromDelegate:(id)delegate;

@end
