//
//  Relation+RelationAccessors.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 12.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Relation.h"

@interface Relation (RelationAccessors)

+ (Relation *)createNewRelation:(NSString *)relation withLabel:(NSString *)label color:(UIColor *)color inContext:(NSManagedObjectContext *)context;

@end
