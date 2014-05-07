//
//  Entry.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 06.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recording, WordWrapper;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Recording *recording;
@property (nonatomic, retain) NSOrderedSet *wordwrappers;
@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)insertObject:(WordWrapper *)value inWordwrappersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWordwrappersAtIndex:(NSUInteger)idx;
- (void)insertWordwrappers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWordwrappersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWordwrappersAtIndex:(NSUInteger)idx withObject:(WordWrapper *)value;
- (void)replaceWordwrappersAtIndexes:(NSIndexSet *)indexes withWordwrappers:(NSArray *)values;
- (void)addWordwrappersObject:(WordWrapper *)value;
- (void)removeWordwrappersObject:(WordWrapper *)value;
- (void)addWordwrappers:(NSOrderedSet *)values;
- (void)removeWordwrappers:(NSOrderedSet *)values;
@end
