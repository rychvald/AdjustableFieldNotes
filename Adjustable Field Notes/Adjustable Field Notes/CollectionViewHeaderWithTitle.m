//
//  UICollectionViewHeader.m
//  Adjustable Field Notes
//
//  Created by mars on 15.06.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import "CollectionViewHeaderWithTitle.h"

@implementation CollectionViewHeaderWithTitle

@synthesize headerLabel;

- (void)setLabelString:(NSString *)labelString {
    self.headerLabel.text = labelString;
}

@end
