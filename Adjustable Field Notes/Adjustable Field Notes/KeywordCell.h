//
//  KeywordCell.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 24.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Keyword;

@interface KeywordCell : UICollectionViewCell

@property (nonatomic,retain) IBOutlet UITextField *label;
@property (nonatomic,retain) Keyword *keyword;

@end
