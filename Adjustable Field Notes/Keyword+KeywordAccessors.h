//
//  Root+RootSingleton.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 11.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "AbstractWord.h"
#import "Keyword.h"

@interface Keyword (KeywordAccessors)

+ (Keyword *)getRootForContext:(NSManagedObjectContext *)context;
- (BOOL)hasEntries;
- (BOOL)hasKeywords;
- (BOOL)hasRelations;
+ (Keyword *)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label color:(UIColor *)color inContext:(NSManagedObjectContext *)context;

- (void)insertObject:(Keyword *)value inChildrenAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)idx;
- (void)replaceObjectInChildrenAtIndex:(NSUInteger)idx withObject:(Keyword *)value;
- (void)addChildrenObject:(Keyword *)value;
- (void)removeChildrenObject:(Keyword *)value;
- (void)insertObject:(Relation *)value inRelationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelationsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInRelationsAtIndex:(NSUInteger)idx withObject:(Relation *)value;
- (void)addRelationsObject:(Relation *)value;
- (void)removeRelationsObject:(Relation *)value;

@end