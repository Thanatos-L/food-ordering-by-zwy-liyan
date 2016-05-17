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
#define titleViewHeight             40
#import "SlideMultiViewController.h"

@interface SlideMultiViewController ()<UIScrollViewDelegate>
@property(strong,nonatomic)NSMutableArray *viewControllerArray;
@property(strong,nonatomic)NSMutableArray *buttonTitle;

@property(assign,nonatomic)NSInteger lastSelected;
@property(strong,nonatomic)UIView *buttonMarkView;
@property(weak,nonatomic)UIView *buttonTitleView;
@property(strong,nonatomic)UIScrollView *contentScrollView;
@property(strong,nonatomic)UIScrollView *mainScrollView;

@property(assign,nonatomic)BOOL isAdvancedLoading;
@property(weak,nonatomic) UIView *buttonView;

@property(assign,nonatomic)CGRect tempBtnFrame;

@end

@implementation SlideMultiViewController
//+(id)initSlideButton:(NSArray *)buttonTitle{
//    return [[self alloc]initSlideButtonConvenience:buttonTitle];
//}
//
//-(id)initSlideButtonConvenience:(NSArray *)buttonTitle{
//    if (self = [super init]) {
//        self.buttonTitle = [buttonTitle mutableCopy];
//        [self drawScrollView];
//        
//    }
//    return self;
//}

//-(id)initWithFrame:(CGRect)frame{
//    if(self = [super initWithFrame:frame]){
//        
//    }
//    return self;
//}

-(void)initSlideButtonAddTitle:(NSArray *)buttonTitle{
    self.lastSelected = -1;
    self.buttonTitle = [buttonTitle mutableCopy];
    [self initTitleScrollView];
    [self markButtonSelected:0];
    
}



-(void)initSlideMultiView:(NSArray *)viewControllerArray withTitle:(NSArray *)title{
    self.lastSelected = -1;
    self.buttonTitle = [[NSMutableArray alloc]init];
    self.buttonTitle = [title mutableCopy];
    
    self.viewControllerArray = [[NSMutableArray alloc]init];
    self.viewControllerArray = [viewControllerArray mutableCopy];
    self.isAdvancedLoading = true;
    [self initContentScrollView];
    [self initTitleScrollView];
    //[self initMainScrollView];
    [self markButtonSelected:0];
    //NSLog(@"slidemenu.m  %f",self.view.frame.size.height);
}

//-(void)initMainScrollView{
//    self.mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+100);
//    self.mainScrollView.contentOffset = CGPointMake(0, -100);
//    UIView *segmentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
//    segmentView.backgroundColor = [UIColor orangeColor];
//    [self.mainScrollView addSubview:segmentView];
//    self.contentScrollView.scrollEnabled = false;
//    [self.view addSubview:self.mainScrollView];
//    [self initContentScrollView];
//    [self initTitleScrollView];
//}

-(void)initContentScrollView{
    self.contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, titleViewHeight, self.view.frame.size.width, self.view.frame.size.height - titleViewHeight)];
    self.contentScrollView.backgroundColor = [UIColor whiteColor];
    self.contentScrollView.delegate = self;
    self.contentScrollView.bounces = NO;
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.viewControllerArray.count, self.view.frame.size.height - titleViewHeight);
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    [self.view addSubview:self.contentScrollView];
    //[self.mainScrollView addSubview:self.contentScrollView];
    
}

-(void)initTitleScrollView{
    UIView *buttonTitleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, titleViewHeight)];
    buttonTitleView.backgroundColor = [UIColor whiteColor];
    
    CGFloat buttonWidth = self.view.frame.size.width/self.buttonTitle.count;
    for (int i=0; i<self.buttonTitle.count; i++) {
    
        CGFloat btnX = 0;
        btnX = (self.view.frame.size.width/3) *i;
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(btnX ,0,buttonWidth,titleViewHeight)];
        
        btn.titleLabel.adjustsFontSizeToFitWidth = NO;
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        
        //btn.titleLabel.textColor = [UIColor redColor];
        
        [btn setTitleColor:[UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
        
        [btn setTitle:self.buttonTitle[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        NSInteger tag = buttonDefaultTag;
        btn.tag = tag + i;
        [btn addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonTitleView addSubview:btn];
        
        [self addChildViewController:self.viewControllerArray[i]];
        [self addChildView:i];

    }
    self.buttonTitleView = buttonTitleView;
    [self.view addSubview:self.buttonTitleView];
    //[self.mainScrollView addSubview:self.buttonTitleView];
}
-(void)titleClicked:(UIButton *)sender{
    
    NSInteger tag = sender.tag - buttonDefaultTag;
    [self.contentScrollView setContentOffset:CGPointMake(self.view.frame.size.width*tag, 0) animated:YES];
    [self markButtonSelected:sender.tag - buttonDefaultTag];
    [self.delegate slideButtionClicked:sender.titleLabel.text];
}

-(void)markButtonSelected:(NSInteger)tag{
    
    if (self.lastSelected >=0) {
        UIButton *lastBtn = (UIButton *)[self.view viewWithTag:self.lastSelected +buttonDefaultTag];
        [lastBtn setTitleColor:[UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
    }
    UIButton *lastBtn = (UIButton *)[self.view viewWithTag:tag +buttonDefaultTag];

    [lastBtn setTitleColor:[UIColor colorWithRed:69/255.0 green:83/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        self.lastSelected = tag;
    if (self.buttonMarkView == nil) {
        self.buttonMarkView = [[UIView alloc]initWithFrame:CGRectMake(lastBtn.frame.origin.x , lastBtn.frame.size.height + lastBtn.frame.origin.y - 3, lastBtn.frame.size.width, 3)];
        self.buttonMarkView.backgroundColor = [UIColor colorWithRed:69/255.0 green:83/255.0 blue:153/255.0 alpha:1];
        [self.buttonTitleView addSubview:self.buttonMarkView];
        
    }
//    else{
//        [UIView animateWithDuration:0.15 animations:^{
//            self.buttonMarkView.frame = CGRectMake(lastBtn.frame.origin.x , lastBtn.frame.size.height + lastBtn.frame.origin.y - 3, lastBtn.frame.size.width, 3);
//        }];
//    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i  = self.contentScrollView.contentOffset.x / self.view.superview.frame.size.width;
    [self markButtonSelected:i];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger i  = self.contentScrollView.contentOffset.x / self.view.superview.frame.size.width;
    UIButton *lastBtn;
    if (self.lastSelected >=0) {
        lastBtn = (UIButton *)[self.view viewWithTag:self.lastSelected +buttonDefaultTag];
       
    }
    
    lastBtn = (UIButton *)[self.view viewWithTag:i +buttonDefaultTag];
    self.buttonMarkView.frame = CGRectMake(self.contentScrollView.contentOffset.x/3 , lastBtn.frame.size.height + lastBtn.frame.origin.y - 3, lastBtn.frame.size.width, 3);
}

- (void)addChildView:(NSInteger)index{
   
    UIViewController *vc = self.viewControllerArray[index];
    CGRect frame = self.contentScrollView.bounds;
    frame.origin.x = self.view.frame.size.width * index;
    vc.view.frame = frame;
    [self.contentScrollView addSubview:vc.view];
}



@end