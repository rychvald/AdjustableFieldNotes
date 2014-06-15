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

@property (strong,nonatomic) id detailItem;

@property (nonatomic,retain) UIPopoverController *popoverVC;
@property (strong,nonatomic) CommentInputController *commentIC;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong,nonatomic) IBOutlet UITableView *recordingTableview;
@property (strong,nonatomic) IBOutlet UICollectionView *keywordCollectionView;
@property (strong,nonatomic) IBOutlet EntryTextField *inputField;
@property (strong,nonatomic) IBOutlet UITextView *commentView;
@property (strong,nonatomic) IBOutlet UIButton *backspaceButton;
@property (strong,nonatomic) IBOutlet UIButton *clearButton;
@property (strong,nonatomic) IBOutlet UIButton *commitButton;
@property (strong,nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

- (void)reload;

@end
