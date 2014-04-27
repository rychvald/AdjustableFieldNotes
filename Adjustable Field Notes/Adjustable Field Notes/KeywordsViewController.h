//
//  KeywordsViewController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 26.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "MasterVCTemplate.h"

@class Keyword;

@interface KeywordsViewController : MasterVCTemplate

@property (nonatomic,retain) Keyword *category;
@property (strong, nonatomic) IBOutlet ItemInputController *itemInputController;

- (void)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color;
- (void)createNewRelation:(NSString *)keyword withLabel:(NSString *)label andColor:(UIColor *)color;
- (NSManagedObject *)changeTypeOfObject:(NSManagedObject *)managedObject;

@end
