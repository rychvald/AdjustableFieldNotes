//
//  Keyword.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 11.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractWord.h"

@class Keyword, Relation;

@interface Keyword : AbstractWord

@property (nonatomic, retain) NSOrderedSet *children;
@property (nonatomic, retain) NSOrderedSet *connectors;
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
- (void)insertObject:(Relation *)value inConnectorsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromConnectorsAtIndex:(NSUInteger)idx;
- (void)insertConnectors:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeConnectorsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInConnectorsAtIndex:(NSUInteger)idx withObject:(Relation *)value;
- (void)replaceConnectorsAtIndexes:(NSIndexSet *)indexes withConnectors:(NSArray *)values;
- (void)addConnectorsObject:(Relation *)value;
- (void)removeConnectorsObject:(Relation *)value;
- (void)addConnectors:(NSOrderedSet *)values;
- (void)removeConnectors:(NSOrderedSet *)values;
@end
