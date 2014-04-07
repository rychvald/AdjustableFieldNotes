//
//  ItemInputController.h
//  Adjustable Field Notes
//
//  Created by mars on 07.04.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemInputController : UITableViewController

@property (nonatomic,retain) IBOutlet UITableViewCell *labelCell;
@property (nonatomic,retain) IBOutlet UITableViewCell *keywordCell;

- (void)prepareForNewEntry;

@end
