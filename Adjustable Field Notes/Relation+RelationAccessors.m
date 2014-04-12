//
//  Relation+RelationAccessors.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 12.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Relation+RelationAccessors.h"

@implementation Relation (RelationAccessors)

#pragma mark - Initialisation Methods

+ (Relation *)createNewRelation:(NSString *)keyword withLabel:(NSString *)label color:(UIColor *)color inContext:(NSManagedObjectContext *)context {
    Relation *newRelation = (Relation *)[NSEntityDescription insertNewObjectForEntityForName:@"Relation" inManagedObjectContext:context];
    newRelation.keyword = keyword;
    [context insertObject:newRelation];
    return newRelation;
}

@end
