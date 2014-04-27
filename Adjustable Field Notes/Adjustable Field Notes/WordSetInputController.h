//
//  WordSetsInputController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 27.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Keyword;

@protocol WordSetInputDelegate <NSObject>

- (void)createNewWordSet:(NSString *)name withDate:(NSDate *)date active:(BOOL)active;
- (void)reload;

@end

@interface WordSetInputController : UITableViewController

@property (nonatomic, retain) IBOutlet UISwitch *activeSwitch;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UIDatePicker *picker;
@property (nonatomic, retain) Keyword *currentWordSet;
@property (strong, nonatomic) id<WordSetInputDelegate> inputDelegate;

- (void)prepareForNewEntryFromDelegate:(id)delegate;
- (void)prepareForEditingWordSet:(Keyword *)wordSet fromDelegate:(id)delegate;

@end
