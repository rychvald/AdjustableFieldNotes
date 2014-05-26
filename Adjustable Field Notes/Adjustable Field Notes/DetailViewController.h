//
//  DetailViewController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 17.03.14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentInputController.h"

@class EntryTextField;
@class CommentInputController;

@interface DetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISplitViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CommentInputDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) CommentInputController *commentIC;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITableView *recordingTableview;
@property (strong, nonatomic) IBOutlet UICollectionView *keywordCollectionView;
@property (strong, nonatomic) IBOutlet EntryTextField *inputField;
@property (strong, nonatomic) IBOutlet UITextView *commentView;

- (void)reload;

@end
