//
//  SlideButtonView.m
//  FOSinOC
//
//  Created by MoonSlides on 16/4/20.
//  Copyright © 2016年 李龑. All rights reserved.
//

#define buttonDefaultSpace             10
#define buttonDefaultTag                960
#define buttonDefaulWidth           50

#import "SlideButtonView.h"

@interface SlideButtonView ()
@property(strong,nonatomic)NSArray *buttonTitle;
@property(assign,nonatomic)NSInteger lastSelected;
@property(strong,nonatomic)UIView *buttonMarkView;
@property(weak,nonatomic)UIScrollView *buttonScrollView;
@property(assign,nonatomic)CGRect tempBtnFrame;

@end

@implementation SlideButtonView
+(id)initSlideButton:(NSArray *)buttonTitle{
    return [[self alloc]initSlideButtonConvenience:buttonTitle];
}

-(id)initSlideButtonConvenience:(NSArray *)buttonTitle{
    if (self = [super init]) {
        self.buttonTitle = buttonTitle;
        [self drawScrollView];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
    }
    return self;
}

-(void)initSlideButtonAddTitle:(NSArray *)buttonTitle{
    self.lastSelected = -1;
    self.buttonTitle = buttonTitle;
    [self drawScrollView];
    [self markButtonSelected:0];
    
}

-(void)drawScrollView{
    UIScrollView *myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    myScrollView.backgroundColor = [UIColor whiteColor];
    myScrollView.showsVerticalScrollIndicator = NO;
    myScrollView.showsHorizontalScrollIndicator = NO;
    
    CGFloat contentWidth = 0;
    CGSize stringSizeSecond;
    
    for (int i=0; i<self.buttonTitle.count; i++) {
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]};
        CGSize stringSizeFirst = [self.buttonTitle[i] sizeWithAttributes:attribute];
        contentWidth = contentWidth + stringSizeFirst.width;
        if (i != 0) {
             stringSizeSecond = [self.buttonTitle[i-1] sizeWithAttributes:attribute];
        }
        else{
             stringSizeSecond = [self.buttonTitle[0] sizeWithAttributes:attribute];
        }
        
        CGFloat btnX = 0;
        for (int j = 0; j<i; j++) {
            btnX = btnX + [self.buttonTitle[j] sizeWithAttributes:attribute].width;
        }
        btnX = btnX + i*buttonDefaultSpace;
        //UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(buttonDefaultSpace+(buttonDefaultSpace + stringSizeSecond.width)*i,0,stringSizeFirst.width,self.frame.size.height-buttonDefaultSpace)];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(btnX ,7,stringSizeFirst.width,self.frame.size.height-buttonDefaultSpace)];
        
        btn.titleLabel.adjustsFontSizeToFitWidth = NO;
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        
        //btn.titleLabel.textColor = [UIColor redColor];
        
        [btn setTitleColor:[UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
        
        [btn setTitle:self.buttonTitle[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        NSInteger tag = buttonDefaultTag;
        btn.tag = tag + i;
        [btn addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [myScrollView addSubview:btn];
    }
    myScrollView.contentSize = CGSizeMake((buttonDefaultSpace)* self.buttonTitle.count + buttonDefaultSpace + contentWidth, self.frame.size.height);
    self.buttonScrollView = myScrollView;
    [self addSubview:self.buttonScrollView];
}
-(void)titleClicked:(UIButton *)sender{
    [self markButtonSelected:sender.tag - buttonDefaultTag];
    //[self autoScrollSlideButton:self.tempBtnFrame];
    [self.delegate slideButtionClicked:sender.titleLabel.text];
}

-(void)markButtonSelected:(NSInteger)tag{
    
    if (self.lastSelected >=0) {
        UIButton *lastBtn = (UIButton *)[self viewWithTag:self.lastSelected +buttonDefaultTag];
        [lastBtn setTitleColor:[UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
    }
    UIButton *lastBtn = (UIButton *)[self viewWithTag:tag +buttonDefaultTag];
    //[self autoScrollSlideButton:lastBtn.frame];
    CGFloat MaxX = CGRectGetMaxX(lastBtn.frame);
    CGFloat contentOffsetX = self.buttonScrollView.contentSize.width - self.buttonScrollView.frame.size.width;
    CGFloat MinX = CGRectGetMinX(lastBtn.frame);
    [lastBtn setTitleColor:[UIColor colorWithRed:69/255.0 green:83/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        self.lastSelected = tag;
    if (self.buttonMarkView == nil) {
        self.buttonMarkView = [[UIView alloc]initWithFrame:CGRectMake(lastBtn.frame.origin.x , lastBtn.frame.size.height + lastBtn.frame.origin.y, lastBtn.frame.size.width, 3)];
        self.buttonMarkView.backgroundColor = [UIColor colorWithRed:69/255.0 green:83/255.0 blue:153/255.0 alpha:1];
        [self.buttonScrollView addSubview:self.buttonMarkView];
        
    }  else{
        [UIView animateWithDuration:0.25 animations:^{
             self.buttonMarkView.frame = CGRectMake(lastBtn.frame.origin.x , lastBtn.frame.size.height + lastBtn.frame.origin.y, lastBtn.frame.size.width, 3);
            if (MaxX >= self.superview.frame.size.width - buttonDefaultSpace * 2) {
                [self.buttonScrollView setContentOffset:CGPointMake(contentOffsetX, 0) animated:NO];
            }
            if (MinX - buttonDefaultSpace *2 <= contentOffsetX) {
                [self.buttonScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
        }];
       
    }
    
}

//============== Write in markButtonSelected:
//-(void)autoScrollSlideButton:(CGRect )frame{
//    CGFloat MaxX = CGRectGetMaxX(frame);
//    CGFloat contentOffsetX = self.buttonScrollView.contentSize.width - self.buttonScrollView.frame.size.width;
//    CGFloat MinX = CGRectGetMinX(frame);
//    if (MaxX >= self.superview.frame.size.width - buttonDefaultSpace * 2) {
//        [self.buttonScrollView setContentOffset:CGPointMake(contentOffsetX, 0) animated:YES];
//    }
//    if (MinX - buttonDefaultSpace *2 <= contentOffsetX) {
//        [self.buttonScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    }
//}

@end
