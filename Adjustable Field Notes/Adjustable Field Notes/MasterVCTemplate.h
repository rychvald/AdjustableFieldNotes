//
//  MasterVCTemplate.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ItemInputController.h"

@class DetailViewController;
@class Keyword;
@class RecordingsHandler;
@class WordSetInputController;

@interface MasterVCTemplate : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) Keyword *myKeyword;
@property (nonatomic,retain) RecordingsHandler *recordingsHandler;
@property (nonatomic,retain) WordSetInputController *recordingInputController;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UINavigationController *itemInputNC;
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;

- (void)insertNewObject:(id)sender;
- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color;
- (void)reload;
- (void)showWords:(id)sender;

@end
