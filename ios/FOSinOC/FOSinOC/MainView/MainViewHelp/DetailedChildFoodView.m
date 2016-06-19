//
//  DetailedChildFoodView.m
//  FOSinOC
//
//  Created by MoonSlides on 16/4/26.
//  Copyright © 2016年 李龑. All rights reserved.
//

#define catagoryTalbeWidth 80
#define slideTitleHeight 40
#define navigationBarHeight 64
#define segmentHeight 70
#define cartViewHeight 70

#import "DetailedChildFoodView.h"

@interface DetailedChildFoodView ()<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate >
@property(strong,nonatomic)UITableView *catagoryTable;
@property(strong,nonatomic)UITableView *foodTable;
//@property(strong,nonatomic)UIView *cartView;

@property(assign,nonatomic)NSInteger lastSelectSection;
@property(assign,nonatomic)BOOL isSelectCatagory;
@property(assign, nonatomic)BOOL isLastCatagorySelected;
@property(assign,nonatomic)BOOL isSendContinueScrolling;
@property(assign,nonatomic)CGFloat maxOffset;
@property(assign,nonatomic)CGFloat minOffset;
@property(assign,nonatomic)CGFloat didSelectCatogoryFoodTableYRecord;

//@property(strong,nonatomic)UIPanGestureRecognizer *foodTablePanGesture;
//test
@property(strong,nonatomic)NSDictionary *foodlist;
@property(strong,nonatomic)NSArray *catagory;

@property(strong,nonatomic) UIPanGestureRecognizer *assistantGesture;
@property(assign,nonatomic) BOOL assistantGestureBegin;
@property(assign,nonatomic) CGPoint tempTranslatedPoint;
@property(assign,nonatomic) BOOL gestureStateBegin;
@property(assign,nonatomic) BOOL isSuperViewGustureStart;

@property(assign,nonatomic) CGFloat foodTableViewScrollOffset;
@property(assign,nonatomic)CGFloat slideViewFrameY;
@end

@implementation DetailedChildFoodView

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"food view did load %f",self.view.frame.size.height);


    NSArray *food1 = @[@"c1 food one",@"c1 food two",@"c1 food three",@"food four",@"food five"];
    NSArray *food2 = @[@"c2 food one",@"c2 food two",@"food three",@"food four",@"food five"];
    NSArray *food3 = @[@"c3 food one",@"c3 food two",@"food three",@"food four",@"food five"];
    NSArray *food4 = @[@"c4 food one",@"c4 food two",@"food three",@"food four",@"food five"];
    NSArray *food5 = @[@"c5 food one",@"c5 food two",@"food three",@"food four",@"food five"];
    NSDictionary *catagory = @{@"one":food1,@"two":food2,@"three":food3,@"four":food4,@"five":food5};
    self.foodlist = catagory;
    self.catagory = [self.foodlist allKeys];

    [self initTableViews];
    [self initCartView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerNotificationAction:) name:@"enableInteractionFood" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerNotificationDisable:) name:@"disableInteractionFood" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(superViewGustureState:) name:@"superViewGustureState" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideViewFrameY:) name:@"slideViewFrameY" object:nil];

    [self.foodTable setScrollEnabled:false];
    
    self.assistantGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(assistantScrollGesture:)];
    self.assistantGesture.delegate = self;
    [self.view addGestureRecognizer:self.assistantGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidAppear:(BOOL)animated{
    
    self.foodTable.frame = CGRectMake(catagoryTalbeWidth, 0, self.view.frame.size.width - catagoryTalbeWidth, self.view.frame.size.height  - navigationBarHeight - segmentHeight);
    self.catagoryTable.frame = CGRectMake(0, 0,catagoryTalbeWidth, self.view.frame.size.height- navigationBarHeight - segmentHeight);
    self.isSuperViewGustureStart = false;
    [self.assistantGesture setEnabled:false];
    self.assistantGestureBegin = false;
    self.minOffset = 0;
}

-(void)disableInteraction{
//    NSLog(@"Disable Interaction");
    [self.foodTable setScrollEnabled:false];
    //[self.assistantGesture setEnabled:false];
    //self.catagoryTable.userInteractionEnabled =false;
    self.didSelectCatogoryFoodTableYRecord = 0;
    self.maxOffset = 0;
}

-(void)enableInteraction{
  //  NSLog(@"Enable Interaction");
    //[self.assistantGesture setEnabled:true];
    self.maxOffset = 0;
    [self.foodTable setScrollEnabled:true];
    self.isSendContinueScrolling = false;
    //self.didSelectCatogoryFoodTableYRecord = 0;

}

-(void)initTableViews{
    self.lastSelectSection = -1;
    
    self.catagoryTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, catagoryTalbeWidth, self.view.frame.size.height - segmentHeight + slideTitleHeight) style:UITableViewStylePlain];
    self.catagoryTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, catagoryTalbeWidth, self.view.frame.size.height - slideTitleHeight) style:UITableViewStylePlain];
    [self.catagoryTable registerClass:[UITableViewCell self] forCellReuseIdentifier:@"catagoryCell"];
    self.catagoryTable.delegate = self;
    self.catagoryTable.dataSource = self;
    self.catagoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.catagoryTable.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.catagoryTable];
    
    self.foodTable = [[UITableView alloc]initWithFrame:CGRectMake(catagoryTalbeWidth, 0, self.view.frame.size.width - catagoryTalbeWidth, self.view.frame.size.height- segmentHeight + slideTitleHeight ) style:UITableViewStylePlain];
    //self.foodTable = [[UITableView alloc]initWithFrame:CGRectMake(catagoryTalbeWidth, 0, self.view.frame.size.width - catagoryTalbeWidth, self.view.frame.size.height - slideTitleHeight) style:UITableViewStylePlain];
    [self.foodTable registerClass:[UITableViewCell self] forCellReuseIdentifier:@"foodCell"];
    self.foodTable.delegate = self;
    self.foodTable.dataSource = self;
    
    //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:self.foodTable];
}

-(void)initCartView{
    //self.view.frame.size.height - cartViewHeight
    self.cartView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - navigationBarHeight-segmentHeight-slideTitleHeight-cartViewHeight, self.view.frame.size.width, cartViewHeight)];
    self.cartView.backgroundColor = [UIColor redColor];
    UIButton *buy = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, 40, 40)];
    [buy setBackgroundColor:[UIColor whiteColor]];
    [buy setTitle:@"buy" forState:UIControlStateNormal];
    [buy addTarget:self action:@selector(buyButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.cartView addSubview:buy];
    
    [self.view addSubview:self.cartView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.catagoryTable) {
        return 1;
    } else{
        return self.foodlist.count;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.catagoryTable) {
        return [self.foodlist allKeys].count;
    } else{
        NSArray *foods = [self.foodlist valueForKey: self.catagory[section]];
        return foods.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.catagoryTable) {
        return 40;
    } else{
        return 70;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.catagoryTable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"catagoryCell" forIndexPath:indexPath];
        cell.textLabel.text = self.catagory[indexPath.row];
        cell.contentView.backgroundColor = [UIColor grayColor];
        cell.textLabel.backgroundColor = [UIColor grayColor];
        return cell;

    } else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"foodCell" forIndexPath:indexPath];
        NSArray *food = [self.foodlist valueForKey:self.catagory[indexPath.section]];
        cell.textLabel.text = food[indexPath.row];
        return cell;
    }
}

-(void)markClickedCatagory:(NSIndexPath *) indexPath{
    if (self.lastSelectSection+1) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.lastSelectSection inSection:0];
        UITableViewCell *cell = [self.catagoryTable cellForRowAtIndexPath:lastIndexPath];
        cell.contentView.backgroundColor = [UIColor grayColor];
        cell.textLabel.backgroundColor = [UIColor grayColor];
    }
    UITableViewCell *cell = [self.catagoryTable cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    self.lastSelectSection = indexPath.row;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.catagoryTable) {
        self.isSelectCatagory = true;
        //the first row is make self.lastSelectSeciton = indexPath.row = 0, so plus one could let conditon be true
        if (self.lastSelectSection+1) {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.lastSelectSection inSection:0];
            UITableViewCell *cell = [self.catagoryTable cellForRowAtIndexPath:lastIndexPath];
            cell.contentView.backgroundColor = [UIColor grayColor];
            cell.textLabel.backgroundColor = [UIColor grayColor];
        }

        UITableViewCell *cell = [self.catagoryTable cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        self.lastSelectSection = indexPath.row;
        NSInteger section = [self.catagory indexOfObject:cell.textLabel.text];
        

        
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:section];
        [self.foodTable scrollToRowAtIndexPath:indexPath2 atScrollPosition:UITableViewScrollPositionTop animated:YES];
        if (section +1 == self.catagory.count) {
            [self scrollViewDidEndScrollingAnimation:self.foodTable];
        }
        if (self.view.superview.frame.origin.y >64) {
            [self disableInteraction];
        }
        
        
    } else if(tableView == self.foodTable){
        //select food
        NSArray *food = [self.foodlist valueForKey:self.catagory[indexPath.section]];
        NSLog(@"%@",food[indexPath.row]);
        
        [self.delegate DetailedChildFoodDidSelectFood:@"foodId"];
        
    }
}

//-(void)scrollFoodTalbe:(UIPanGestureRecognizer *)panGesture{
//    CGPoint velocity = [panGesture velocityInView:self.view];
//    CGPoint translatedPoint = [panGesture translationInView:self.view];
//    NSLog(@"translated y:%f",translatedPoint.y);
//    NSLog(@"food speed y:%f",velocity.y);
//    NSLog(@"food slide y: %f",self.foodTable.contentOffset.y);
//}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    self.isSelectCatagory = false;
    
}

-(void) triggerNotificationAction:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSNumber class]])
    {
        [self enableInteraction];
        NSNumber *y = [notification object];
//        NSLog(@"continu to scroll child %f",[y floatValue]);
//        NSLog(@"food table content offset,%f",self.foodTable.contentOffset.y);
        [self.foodTable setContentOffset:CGPointMake(0,  -[y floatValue] + self.didSelectCatogoryFoodTableYRecord)];
    }
    else
    {
        NSLog(@"Error, object not recognised.");
    }
}

-(void) triggerNotificationDisable:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSNumber class]])
    {
        //[self enableInteraction];
        NSNumber *y = [notification object];
        NSLog(@"continu to scroll child %f",[y floatValue]);
        NSLog(@"food table content offset,%f",self.foodTable.contentOffset.y);
        if (self.foodTable.contentOffset.y >=0) {
            [self.foodTable setContentOffset:CGPointMake(0,  -[y floatValue] + self.didSelectCatogoryFoodTableYRecord)];
        }
    }
    else
    {
        NSLog(@"Error, object not recognised.");
    }
}

-(void)superViewGustureState:(NSNotification *) notification{
    if ([notification.object isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = [notification object];
        self.isSuperViewGustureStart = [number boolValue];
        NSLog(self.isSuperViewGustureStart? @"isSuperViewGustureStart true":@"isSuperViewGustureStart no");
    }
}

-(void)slideViewFrameY:(NSNotification *) notification{
    if ([notification.object isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = [notification object];
        self.slideViewFrameY = [number floatValue];
        if (self.slideViewFrameY < segmentHeight+navigationBarHeight) {
            [self.assistantGesture setEnabled:true];
        }
        else{
            [self.assistantGesture setEnabled:false];

        }

//        if (self.slideViewFrameY>segmentHeight+navigationBarHeight + 60) {
//            [self.assistantGesture setEnabled:false];
//        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.catagoryTable) {
        if (scrollView.contentOffset.y<=0) {

            
        }
        else{
           
        }
        
    }else if(scrollView == self.foodTable){
        CGPoint translatedPoint = [[self.foodTable panGestureRecognizer] translationInView:self.view];
        CGPoint velocity = [[self.foodTable panGestureRecognizer ]velocityInView:self.view];
//        NSLog(@"child food talbe offset %f",scrollView.contentOffset.y);
//        NSLog(@"shop translatedPoint y:%f",translatedPoint.y);
//        NSLog(@"speed y:%f",velocity.y);
        
        self.foodTableViewScrollOffset = scrollView.contentOffset.y;
        if (self.isSelectCatagory) {
            self.didSelectCatogoryFoodTableYRecord = scrollView.contentOffset.y;
        }
        
        if (scrollView.contentOffset.y<=0 ) {
            [self disableInteraction];
            //NSLog(@"scrollview offset %f",scrollView.contentOffset.y);
            //scrollview will have bounce and the contentoffset will change to opposite direction, so use a maxoffest to keep the scroll direction
            NSNumber *y;
            NSLog(@"foodTableViewScrollOffset %f",self.foodTableViewScrollOffset);
            NSLog(@"max offset %f",self.maxOffset);
            NSLog(@"min offset %f",self.minOffset);
            if (self.maxOffset > scrollView.contentOffset.y) {
                
                self.maxOffset = scrollView.contentOffset.y;
                y = [NSNumber numberWithFloat:self.maxOffset];
                CGPoint velocity = [self.foodTable.panGestureRecognizer velocityInView:self.foodTable];
                NSValue *velocityInValue = [NSValue valueWithCGPoint:velocity];
                NSArray *scrollParam = [NSArray arrayWithObjects:y,velocityInValue, nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"mainContinueScrollingShop" object:scrollParam];

            }
//            if (fabs(self.minOffset) < fabs(scrollView.contentOffset.y)) {
//                
//                //self.minOffset = scrollView.contentOffset.y;
//                //y = [NSNumber numberWithFloat:self.minOffset];
//                //y = [NSNumber numberWithFloat:scrollView.contentOffset.y];
//                CGPoint velocity = [self.foodTable.panGestureRecognizer velocityInView:self.foodTable];
//                NSValue *velocityInValue = [NSValue valueWithCGPoint:velocity];
//                NSArray *scrollParam = [NSArray arrayWithObjects:y,velocityInValue, nil];
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"mainContinueScrollingShop" object:scrollParam];
//            }
        }
        else if(scrollView.contentOffset.y>0){
            if (!self.isSelectCatagory) {
            [self enableInteraction];
            }
            
            self.isSendContinueScrolling = false;
            self.foodTable.bounces = YES;
        }
        
        
        NSIndexPath *firstVisibleIndexPath = [[self.foodTable indexPathsForVisibleRows] objectAtIndex:0];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:firstVisibleIndexPath.section inSection:0];
        if (self.lastSelectSection+1) {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.lastSelectSection inSection:0];
            UITableViewCell *cell = [self.catagoryTable cellForRowAtIndexPath:lastIndexPath];
            if (!self.isSelectCatagory) {
                cell.contentView.backgroundColor = [UIColor grayColor];
                cell.textLabel.backgroundColor = [UIColor grayColor];
            }
        }
        
        UITableViewCell *cell = [self.catagoryTable cellForRowAtIndexPath:indexPath];
        if (!self.isSelectCatagory) {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
        }
        self.lastSelectSection = indexPath.row;
        
    }
}

-(void)assistantScrollGesture:(UIPanGestureRecognizer *)panGesture{
    CGPoint velocity = [panGesture velocityInView:self.view];
    CGPoint translatedPoint = [panGesture translationInView:self.view];
//    NSLog(@"assistant speed y:%f",velocity.y);
//    NSLog(@"foodTableViewScrollOffset %f",self.foodTableViewScrollOffset);
//    NSLog(@"assistant translatedPoint y:%f",translatedPoint.y);
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.gestureStateBegin = true;
        self.assistantGestureBegin = true;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"childViewGustureStateBegin" object:[NSNumber numberWithBool:true]];
    }
    //NSLog(@"slide y: %f",_slideViewFrameY);
    if (self.foodTableViewScrollOffset == 0 && velocity.y>0  && self.foodTable.isScrollEnabled == false
        && _slideViewFrameY<segmentHeight+navigationBarHeight) {
        
        if ( self.gestureStateBegin == true) {
            self.gestureStateBegin = false;
            self.tempTranslatedPoint = translatedPoint;
        }
        
       // NSLog(@"assistant temp y:%f",self.tempTranslatedPoint.y);
    }
    else{
        self.tempTranslatedPoint = CGPointMake(0, 0);
    }
    
    if (self.isSuperViewGustureStart == false  &&self.foodTableViewScrollOffset <= 0 &&velocity.y>0 && self.foodTable.isScrollEnabled == false && self.slideViewFrameY<segmentHeight+navigationBarHeight) {
        
        //NSLog(@"assistant scroll");
        NSLog(@"assistant scroll %f",- translatedPoint.y + _tempTranslatedPoint.y);
        if (-translatedPoint.y + self.tempTranslatedPoint.y > -(segmentHeight+navigationBarHeight)) {
            NSNumber *y = [NSNumber numberWithFloat: - translatedPoint.y + _tempTranslatedPoint.y];
            CGPoint velocity = [self.foodTable.panGestureRecognizer velocityInView:self.foodTable];
            NSValue *velocityInValue = [NSValue valueWithCGPoint:velocity];
            NSArray *scrollParam = [NSArray arrayWithObjects:y,velocityInValue, nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"mainContinueScrollingShop" object:scrollParam];

            
            
        }
    }
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        self.assistantGestureBegin = false;
        self.tempTranslatedPoint = CGPointMake(0, 0);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"childViewGustureStateBegin" object:[NSNumber numberWithBool:false]];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.catagoryTable) {
        return nil;
    }else{
        return self.catagory[section];
    }
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return true;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual: @"foodDetailSegue"]) {
        
    }
    
}

-(void)buyButtonHandle{
    NSLog(@"buyButtonHandle");
}

@end
