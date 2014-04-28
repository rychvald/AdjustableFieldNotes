//
//  RecordingsHandler.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingsHandler : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,retain) IBOutlet UITableView *tableView;

@end
