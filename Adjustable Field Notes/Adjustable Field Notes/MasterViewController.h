//
//  MasterViewController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 17.03.14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>
#import "ItemInputController.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate,ItemInputDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedKeywordResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedRelationResultsController;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet ItemInputController *itemInputController;
@property (strong, nonatomic) UINavigationController *itemInputNC;

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color;

@end
