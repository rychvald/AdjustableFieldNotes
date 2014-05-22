//
//  DetailViewController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 17.03.14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EntryTextField;
@class CommentInputController;

@interface DetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISplitViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) id detailItem;

@property (nonatomic,retain) CommentInputController *commentIC;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *recordingTableview;
@property (weak, nonatomic) IBOutlet UICollectionView *keywordCollectionView;
@property (weak, nonatomic) IBOutlet EntryTextField *inputField;
@property (weak, nonatomic) IBOutlet UITextView *commentView;

- (void)reload;

@end
