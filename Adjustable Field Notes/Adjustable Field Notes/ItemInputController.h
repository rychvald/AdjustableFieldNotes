//
//  ItemInputController.h
//  Adjustable Field Notes
//
//  Created by mars on 07.04.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Keyword;

//protocol to use when invoking this class to add / edit a keyword
@protocol ItemInputDelegate <NSObject>

@property BOOL isRoot;

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color;
- (NSManagedObject *)changeTypeOfObject:(NSManagedObject *)managedObject;
- (void)reload;

@end

@interface ItemInputController : UITableViewController

@property (nonatomic, retain) IBOutlet UITextField *labelField;
@property (nonatomic, retain) IBOutlet UITextField *keywordField;
@property (nonatomic, retain) Keyword *currentKeyword;
@property (strong, nonatomic) id<ItemInputDelegate> inputDelegate;

- (void)prepareForNewEntryFromDelegate:(id)delegate;
- (void)prepareForEditingKeyword:(NSManagedObject *)keyword fromDelegate:(id)delegate;

@end
