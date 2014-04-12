//
//  Keyword.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 12.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractWord.h"

@class Keyword, Relation;

@interface Keyword : AbstractWord

@property (nonatomic, retain) NSOrderedSet *children;
@property (nonatomic, retain) NSOrderedSet *relations;
@property (nonatomic, retain) Keyword *parent;
@end

@interface Keyword (CoreDataGeneratedAccessors)

- (void)insertObject:(Keyword *)value inChildrenAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)idx;
- (void)insertChildren:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChildrenAtIndex:(NSUInteger)idx withObject:(Keyword *)value;
- (void)replaceChildrenAtIndexes:(NSIndexSet *)indexes withChildren:(NSArray *)values;
- (void)addChildrenObject:(Keyword *)value;
- (void)removeChildrenObject:(Keyword *)value;
- (void)addChildren:(NSOrderedSet *)values;
- (void)removeChildren:(NSOrderedSet *)values;
- (void)insertObject:(Relation *)value inRelationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelationsAtIndex:(NSUInteger)idx;
- (void)insertRelations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRelationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRelationsAtIndex:(NSUInteger)idx withObject:(Relation *)value;
- (void)replaceRelationsAtIndexes:(NSIndexSet *)indexes withRelations:(NSArray *)values;
- (void)addRelationsObject:(Relation *)value;
- (void)removeRelationsObject:(Relation *)value;
- (void)addRelations:(NSOrderedSet *)values;
- (void)removeRelations:(NSOrderedSet *)values;

@end
