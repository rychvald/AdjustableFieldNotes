//
//  CategoriesViewController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 26.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "MasterVCTemplate.h"
#import "CategoryInputController.h"

@class Keyword;

@interface CategoriesViewController : MasterVCTemplate <CategoryInputDelegate>

@property (nonatomic,retain) Keyword *wordSet;
@property (nonatomic,retain) CategoryInputController *inputController;

- (void)createNewCategory:(NSString *)name withColor:(UIColor *)color;

@end
