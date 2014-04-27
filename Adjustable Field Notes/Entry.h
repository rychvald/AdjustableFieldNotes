//
//  Entry.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 27.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractWord, Recording;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Recording *recording;
@property (nonatomic, retain) NSOrderedSet *words;
@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)insertObject:(AbstractWord *)value inWordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWordsAtIndex:(NSUInteger)idx;
- (void)insertWords:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWordsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWordsAtIndex:(NSUInteger)idx withObject:(AbstractWord *)value;
- (void)replaceWordsAtIndexes:(NSIndexSet *)indexes withWords:(NSArray *)values;
- (void)addWordsObject:(AbstractWord *)value;
- (void)removeWordsObject:(AbstractWord *)value;
- (void)addWords:(NSOrderedSet *)values;
- (void)removeWords:(NSOrderedSet *)values;
@end
