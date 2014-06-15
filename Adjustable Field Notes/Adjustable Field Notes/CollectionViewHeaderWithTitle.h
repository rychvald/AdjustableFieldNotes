//
//  UICollectionViewHeader.h
//  Adjustable Field Notes
//
//  Created by mars on 15.06.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewHeaderWithTitle : UICollectionReusableView

@property (nonatomic,retain) IBOutlet UILabel *headerLabel;

- (void)setLabelString:(NSString *)labelString;

@end
