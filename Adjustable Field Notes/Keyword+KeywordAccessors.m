//
//  Root+RootSingleton.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 11.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"

@implementation Keyword (KeywordAccessors)

#pragma mark - Root Keyword Methods

+ (Keyword *)getRootForContext:(NSManagedObjectContext *)context {
    Keyword *rootKeyword;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Keyword"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"keyword like %@ AND parent == nil", @"rootKeyword"]];
    if ([context countForFetchRequest:request error:nil] == 0) {
        rootKeyword = [Keyword createRootKeywordInContext:context];
    }
    else if ([context countForFetchRequest:request error:nil] == 1) {
        rootKeyword = [[context executeFetchRequest:request error:nil] objectAtIndex:0];
    } else {
        NSLog(@"Something is not as it should be in the object model. Trying to continue anyway...");
        rootKeyword = [[context executeFetchRequest:request error:nil] objectAtIndex:0];
    }
    
    return rootKeyword;
}

+ (Keyword *)createRootKeywordInContext:(NSManagedObjectContext *)context {
    Keyword *rootKeyword = (Keyword *)[NSEntityDescription insertNewObjectForEntityForName:@"Keyword" inManagedObjectContext:context];
    rootKeyword.keyword = @"rootKeyword";
    [context insertObject:rootKeyword];
    return rootKeyword;
}

#pragma mark - Accessor Methods

- (void)insertObject:(Keyword *)value inChildrenAtIndex:(NSUInteger)idx {
    
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)idx {
    
}

- (void)insertChildren:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    
}

- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes {
    
}

- (void)replaceObjectInChildrenAtIndex:(NSUInteger)idx withObject:(Keyword *)value; {
    
}

- (void)replaceChildrenAtIndexes:(NSIndexSet *)indexes withChildren:(NSArray *)values; {
    
}

- (void)addChildrenObject:(Keyword *)value {
    
}

- (void)removeChildrenObject:(Keyword *)value {
    
}

- (void)addChildren:(NSOrderedSet *)values {
    
}

- (void)removeChildren:(NSOrderedSet *)values {
    
}

- (void)insertObject:(Relation *)value inConnectorsAtIndex:(NSUInteger)idx {
    
}

- (void)removeObjectFromConnectorsAtIndex:(NSUInteger)idx {
    
}

- (void)insertConnectors:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    
}

- (void)removeConnectorsAtIndexes:(NSIndexSet *)indexes {
    
}

- (void)replaceObjectInConnectorsAtIndex:(NSUInteger)idx withObject:(Relation *)value {
    
}

- (void)replaceConnectorsAtIndexes:(NSIndexSet *)indexes withConnectors:(NSArray *)values {
    
}

- (void)addConnectorsObject:(Relation *)value {
    
}

- (void)removeConnectorsObject:(Relation *)value {
    
}

- (void)addConnectors:(NSOrderedSet *)values {
    
}

- (void)removeConnectors:(NSOrderedSet *)values {
    
}

@end
