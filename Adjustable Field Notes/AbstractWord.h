//
//  AbstractWord.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 06.05.14.
//  Copyright (c) 2014 Marcel Stolz.  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WordWrapper;

@interface AbstractWord : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * keyword;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * linebreak;
@property (nonatomic, retain) NSNumber * orderNumber;
@property (nonatomic, retain) NSSet *wordwrappers;
@end

@interface AbstractWord (CoreDataGeneratedAccessors)

- (void)addWordwrappersObject:(WordWrapper *)value;
- (void)removeWordwrappersObject:(WordWrapper *)value;
- (void)addWordwrappers:(NSSet *)values;
- (void)removeWordwrappers:(NSSet *)values;

@end
