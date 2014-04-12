//
//  AbstractWord.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 12.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry;

@interface AbstractWord : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * keyword;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * orderNumber;
@property (nonatomic, retain) NSSet *usedByEntries;
@end

@interface AbstractWord (CoreDataGeneratedAccessors)

- (void)addUsedByEntriesObject:(Entry *)value;
- (void)removeUsedByEntriesObject:(Entry *)value;
- (void)addUsedByEntries:(NSSet *)values;
- (void)removeUsedByEntries:(NSSet *)values;

@end
