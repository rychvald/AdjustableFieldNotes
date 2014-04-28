//
//  DetailViewController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 17.03.14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *recordingTableview;
@property (weak, nonatomic) IBOutlet UITableView *categoriesTableview;
@property (weak, nonatomic) IBOutlet UICollectionView *keywordCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *inputField;

- (void)reload;

@end
