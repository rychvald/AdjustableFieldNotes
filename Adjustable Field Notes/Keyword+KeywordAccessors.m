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
#import "NSManagedObject+Serialization.h"

@implementation Keyword (KeywordAccessors)

#pragma mark - Root Keyword Methods

+ (Keyword *)getRootForContext:(NSManagedObjectContext *)context {
    Keyword *rootKeyword;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Keyword"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"keyword like %@ AND parent == nil", @"rootKeyword"]];
    if ([context countForFetchRequest:request error:nil] == 0) {
        rootKeyword = nil;
    }
    else if ([context countForFetchRequest:request error:nil] == 1) {
        rootKeyword = [[context executeFetchRequest:request error:nil] objectAtIndex:0];
    } else {
        NSLog(@"Something is not as it should be in the object model. Trying to continue anyway...");
        rootKeyword = [[context executeFetchRequest:request error:nil] objectAtIndex:0];
    }
    
    return rootKeyword;
}

+ (NSArray *)getWordSetsForContext:(NSManagedObjectContext *)context {
    Keyword *rootKeyword;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Keyword"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parent == nil"]];
    NSArray *array = nil;
    
    if ([context countForFetchRequest:request error:nil] == 0) {
        rootKeyword = [Keyword createInitialWordSetInContext:context];
        array = @[rootKeyword];
    } else {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keyword" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        array = [context executeFetchRequest:request error:nil];
    }
    
    return array;
}

+ (NSArray *)getInactiveWordSetsForContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Keyword"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parent == nil AND active == %@",[NSNumber numberWithBool: NO]]];
    NSArray *array = nil;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keyword" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    array = [context executeFetchRequest:request error:nil];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    [mutableArray removeObject:[self getGarbageCollectorForContext:context]];
    array = [NSArray arrayWithArray:mutableArray];
    
    return array;
}

+ (Keyword *)getActiveWordSetForContext:(NSManagedObjectContext *)context {
    Keyword *activeKeyword = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Keyword"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parent == nil AND active == %@",[NSNumber numberWithBool: YES]]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    if ([[context executeFetchRequest:request error:nil]count] == 0) {
        NSLog(@"Creating new initial word set as none seems to exist");
        activeKeyword = [Keyword createInitialWordSetInContext:context];
    } else {
        //NSLog(@"Retrieving active word set");
        activeKeyword = [[context executeFetchRequest:request error:nil]objectAtIndex:0];
    }
    return activeKeyword;
}

+ (Keyword *)getGarbageCollectorForContext:(NSManagedObjectContext *)context {
    Keyword *garbageCollector = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Keyword"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parent == nil AND active == %@ AND keyword LIKE %@",[NSNumber numberWithBool: NO],@"GarbageCollectionWord"]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    if ([[context executeFetchRequest:request error:nil]count] == 0) {
        NSLog(@"Creating new garbage collector word as none seems to exist");
        garbageCollector = [Keyword createGarbageCollectorInContext:context];
    } else {
        //NSLog(@"Retrieving garbage collector word");
        garbageCollector = [[context executeFetchRequest:request error:nil]objectAtIndex:0];
    }
    return garbageCollector;
}

+ (Keyword *)createInitialWordSetInContext:(NSManagedObjectContext *)context {
    Keyword *rootKeyword = (Keyword *)[NSEntityDescription insertNewObjectForEntityForName:@"Keyword" inManagedObjectContext:context];
    rootKeyword.keyword = NSLocalizedString(@"Initial Word Set",nil);
    rootKeyword.dateCreated = [NSDate date];
    [rootKeyword setIsActive:YES];
    [context insertObject:rootKeyword];
    [context save:nil];
    return rootKeyword;
}

+ (Keyword *)createGarbageCollectorInContext:(NSManagedObjectContext *)context {
    Keyword *garbageCollection = (Keyword *)[NSEntityDescription insertNewObjectForEntityForName:@"Keyword" inManagedObjectContext:context];
    garbageCollection.keyword = @"GarbageCollectionWord";
    garbageCollection.dateCreated = [NSDate date];
    [garbageCollection setIsActive:NO];
    [context insertObject:garbageCollection];
    [context save:nil];
    return garbageCollection;
}

+ (Keyword *)addWordSetFromFile:(NSURL *)fileURL inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSData *wordsetData = [NSData dataWithContentsOfURL:fileURL];
    NSDictionary *wordsetDictionary = [NSManagedObject dictionaryFromData:wordsetData];
    Keyword *keyword = (Keyword *)[NSManagedObject createManagedObjectFromDictionary:wordsetDictionary inContext:managedObjectContext];
    keyword.isActive = NO;
    [managedObjectContext save:nil];
    NSLog(@"Added word set: %@",keyword.keyword);
    return keyword;
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
    newKeyword.label = label;
    newKeyword.color = color;
    newKeyword.isActive = NO;
    [context insertObject:newKeyword];
    [context save:nil];
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

- (void)moveObjectAtIndex:(NSUInteger)sourceIndex toIndex: (NSUInteger)destinationIndex {
    Keyword *keyword = [self.children objectAtIndex:sourceIndex];
    [self removeObjectFromChildrenAtIndex:sourceIndex];
    [self insertObject:keyword inChildrenAtIndex:destinationIndex];
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

- (BOOL)isActive {
    [self willAccessValueForKey:@"active"];
    BOOL myuseGPS = [[self active] boolValue];
    [self didAccessValueForKey:@"active"];
    return myuseGPS;
}

- (void)setIsActive:(BOOL)newValue {
    [self willChangeValueForKey:@"active"];
    if (newValue == YES) {
        for (Keyword *wordSet in [Keyword getWordSetsForContext:self.managedObjectContext]) {
            wordSet.isActive = NO;
        }
    }
    [self setActive:[NSNumber numberWithBool:newValue]];
    [self didChangeValueForKey:@"active"];
}

//remove a word set object (i.e. parent = nil) to garbage collection.
//cannot be deleted from context, as dependant recordings may exist.
- (void)appendToGarbageCollector {
    self.parent = [Keyword getGarbageCollectorForContext:self.managedObjectContext];
    [self.managedObjectContext save:nil];
}

- (NSString *)generateXML {
    return nil;
}

@end
