//
//  Root+RootSingleton.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 11.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "AbstractWord.h"
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

- (BOOL)hasEntries {
    if([self.children count] == 0 && [self.relations count] == 0)
        return NO;
    else
        return YES;
}

- (BOOL)hasKeywords {
    if ([self.children count] == 0)
        return NO;
    else
        return YES;
}

- (BOOL)hasRelations {
    if ([self.relations count] == 0)
        return NO;
    else
        return YES;
}

#pragma mark - Initialisation Methods

+ (Keyword *)createNewKeyword:(NSString *)keyword withLabel:(NSString *)label color:(UIColor *)color inContext:(NSManagedObjectContext *)context {
    Keyword *newKeyword = (Keyword *)[NSEntityDescription insertNewObjectForEntityForName:@"Keyword" inManagedObjectContext:context];
    newKeyword.keyword = keyword;
    [context insertObject:newKeyword];
    return newKeyword;
}

#pragma mark - Accessor Methods

- (void)insertObject:(Keyword *)value inChildrenAtIndex:(NSUInteger)idx {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.children];
    [newSet insertObject:value atIndex:idx];
    self.children = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)idx {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.children];
    [newSet removeObjectAtIndex:idx];
    self.children = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)replaceObjectInChildrenAtIndex:(NSUInteger)idx withObject:(Keyword *)value; {
    
}

- (void)addChildrenObject:(Keyword *)value {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.children];
    [newSet addObject:value];
    self.children = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)removeChildrenObject:(Keyword *)value {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.children];
    [newSet removeObject:value];
    self.children = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)insertObject:(Relation *)value inRelationsAtIndex:(NSUInteger)idx {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.relations];
    [newSet insertObject:value atIndex:idx];
    self.relations = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)removeObjectFromRelationsAtIndex:(NSUInteger)idx {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.relations];
    [newSet removeObjectAtIndex:idx];
    self.relations = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)replaceObjectInRelationsAtIndex:(NSUInteger)idx withObject:(Relation *)value {
    
}

- (void)addRelationsObject:(Relation *)value {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.relations];
    [newSet addObject:value];
    self.relations = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)removeRelationsObject:(Relation *)value {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.relations];
    [newSet removeObject:value];
    self.relations = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

@end
