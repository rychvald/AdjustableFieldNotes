//
//  RecordingsHandler.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterVCTemplate.h"

@class WordSetInputController;
@class Recording;

@interface RecordingsHandler : UITableViewController

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) WordSetInputController *inputController;

- (Recording *)getRecordingAtIndexPath:(NSIndexPath *)indexPath;

@end
