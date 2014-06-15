//
//  WordSetsInputController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 27.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Keyword;
@class Recording;

//protocol to use when invoking this class to add / edit a word set
@protocol WordSetInputDelegate <NSObject>

- (void)createNewWordSet:(NSString *)name withDate:(NSDate *)date active:(BOOL)active;
- (void)reload;

@end

//protocol to use when invoking this class to add / edit a recording
@protocol RecordingDelegate <NSObject>

- (void)createNewRecording:(NSString *)recording withDate:(NSDate *)date active:(BOOL)active;
- (void)reload;

@end

@interface WordSetInputController : UITableViewController

@property (nonatomic,retain) IBOutlet UISwitch *activeSwitch;
@property (nonatomic,retain) IBOutlet UITextField *name;
@property (nonatomic,retain) IBOutlet UIDatePicker *picker;
@property (nonatomic,retain) IBOutlet UITextField *activeTextField;
@property (nonatomic,retain) Keyword *currentWordSet;
@property (nonatomic,retain) Recording *currentRecording;
@property (strong, nonatomic) id<WordSetInputDelegate> inputDelegate;
@property (strong, nonatomic) id<RecordingDelegate> recordingDelegate;

- (void)prepareForNewEntryFromDelegate:(id)delegate;
- (void)prepareForEditingWordSet:(Keyword *)wordSet fromDelegate:(id)delegate;
- (void)prepareForNewRecordingFromDelegate:(id)delegate;
- (void)prepareForEditingRecording:(Recording *)recording fromDelegate:(id)delegate;

@end
