//
//  MainViewCell.h
//  FOSinOC
//
//  Created by MoonSlides on 16/4/12.
//  Copyright © 2016年 李龑. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *shopImage;
@property (weak, nonatomic) IBOutlet UILabel *heatLabel;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startPriceLabel;

@end