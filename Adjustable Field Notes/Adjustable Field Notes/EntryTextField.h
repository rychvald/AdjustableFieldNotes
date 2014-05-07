//
//  EntryTextField.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 06.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"

@class Recording;

@interface EntryTextField : UITextField

@property (nonatomic,retain) NSMutableArray *keywords;
@property (nonatomic,retain) NSDate *timestamp;

- (void)addKeyword:(Keyword *)keyword;
- (IBAction)removeLastKeyword:(id)sender;
- (IBAction)removeAllKeywords:(id)sender;
- (void)commitToRecording:(Recording *)recording;

@end
