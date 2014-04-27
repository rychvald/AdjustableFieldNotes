//
//  WordsViewController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 26.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "MasterVCTemplate.h"
#import "WordSetInputController.h"

@class WordSetInputController;

@interface WordsViewController : MasterVCTemplate <WordSetInputDelegate>

@property (nonatomic,retain) WordSetInputController *inputController;

- (void)createNewWordSet:(NSString *)name withDate:(NSDate *)date active:(BOOL)active;

@end
