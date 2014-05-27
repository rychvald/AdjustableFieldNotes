//
//  MasterVCTemplate.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class Keyword;

#import <CoreData/CoreData.h>
#import "ItemInputController.h"

@interface MasterVCTemplate : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) Keyword *myKeyword;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UINavigationController *itemInputNC;
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color;
- (void)reload;

@end
