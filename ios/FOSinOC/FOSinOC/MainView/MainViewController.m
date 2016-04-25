//
//  MainViewController.m
//  FOSinOC
//
//  Created by MoonSlides on 16/4/24.
//  Copyright © 2016年 李龑. All rights reserved.
//
#define tableCellTag 1260
#define mainViewcellHeight 100
#define floatViewHeight 40

#import "MainViewController.h"
#import "MainViewCell.h"
#import "DropDownView.h"
#import "Account.h"
#import "SearchViewHelpController.h"
#import "CatagoryView.h"
#import "SortView.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UISearchResultsUpdating,SearchViewHelpControllerDelegate,DropDownViewDelegate,CatagoryViewDelegate,SortViewDelegate>
@property(strong,nonatomic) Account *myAccount;

@property (weak, nonatomic) IBOutlet UITableView *mainViewTableView;

@property (weak, nonatomic) IBOutlet UIButton *chooseLocationBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;


//property for dropDownView
@property (strong,nonatomic)UITapGestureRecognizer *tapToCloseChooseLocation;
@property (strong,nonatomic)UIBlurEffect *blurEffet;
@property (strong,nonatomic)UIVisualEffectView *blurEffectView;
@property (strong,nonatomic) DropDownView *dropDownChooseLocation;

//property for search location view
@property (strong,nonatomic)UIVisualEffectView *blurEffectViewForSearch;
@property (strong,nonatomic)UISearchController *searchController;
@property (strong,nonatomic)UITableView *searchTableView;
@property (strong,nonatomic)UITapGestureRecognizer *tapToCloseSearchController;
@property (strong,nonatomic) SearchViewHelpController *searchViewHelpController;

//property for search other things
@property (strong,nonatomic)UISearchBar *searchForShop;

@property (strong,nonatomic)UIButton *catagoryBtn;
@property (strong,nonatomic)UIButton *sortBtn;
@property (strong,nonatomic)UIButton *filterBtn;

@property(strong,nonatomic)UIView *floatMenuView;

@property (strong,nonatomic)UIView *coverView;
@property (strong,nonatomic)UIVisualEffectView *coverViewBlankArea;

@property (strong,nonatomic)CatagoryView *catagoryView;
@property (strong,nonatomic)SortView *sortView;
@property (strong,nonatomic)UITapGestureRecognizer *tapToCloseMainViewMenu;
//@property(strong,nonatomic) SlideButtonView *slideButtonView;
//test
@property(copy,nonatomic)NSString *testString;
@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainViewTableView.delegate = self;
    self.mainViewTableView.dataSource = self;
    
    
    self.myAccount = [Account sharedManager];
    self.myAccount.delegate = nil;
    [self.myAccount checkLogin];
    self.searchViewHelpController = [[SearchViewHelpController alloc]init];
    self.searchViewHelpController.delegate = self;
    
    self.blurEffet = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:self.blurEffet];
    self.tapToCloseChooseLocation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDropDownView)];
    [self.blurEffectView addGestureRecognizer:self.tapToCloseChooseLocation];
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.blurEffectViewForSearch = [[UIVisualEffectView alloc] initWithEffect:self.blurEffet];
    self.tapToCloseSearchController = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarCancelButtonClicked)];
    
    
    self.tapToCloseMainViewMenu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMainViewMenu)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initTableViewMainHeaderView];
    [self drawfloatMenuView];
}
-(void)initTableViewMainHeaderView{
    
    UIView *mainHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    [mainHeaderView setBackgroundColor:[UIColor grayColor]];
    mainHeaderView.layer.shadowOpacity = 0.8;
    mainHeaderView.layer.shadowOffset = CGSizeMake(-2.0, 0.0);
    [self.mainViewTableView setTableHeaderView:mainHeaderView];
    
    self.searchForShop = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.mainViewTableView.tableHeaderView.frame.size.width, 44)];
    [self.mainViewTableView addSubview:self.searchForShop];
    
}


-(void)drawfloatMenuView{
    self.floatMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.mainViewTableView.tableHeaderView.frame.size.height - floatViewHeight+64, self.view.frame.size.width, floatViewHeight)];
    //self.floatMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 40)];
    //self.floatMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 40)];
    [self.floatMenuView setBackgroundColor:[UIColor blueColor]];
    
    self.catagoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width/3, 30)];
    [self.catagoryBtn setTitle:@"Catagory" forState:UIControlStateNormal];
    [self.catagoryBtn addTarget:self action:@selector(catagoryBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.sortBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, 5, self.view.frame.size.width/3, 30)];
    [self.sortBtn setTitle:@"Sort" forState:UIControlStateNormal];
    [self.sortBtn addTarget:self action:@selector(sortBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.filterBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width/3)*2, 5, self.view.frame.size.width/3, 30)];
    [self.filterBtn setTitle:@"Filter" forState:UIControlStateNormal];
    [self.filterBtn addTarget:self action:@selector(filterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.floatMenuView addSubview:self.catagoryBtn];
    [self.floatMenuView addSubview:self.sortBtn];
    [self.floatMenuView addSubview:self.filterBtn];
    [self.view addSubview:self.floatMenuView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < self.mainViewTableView.tableHeaderView.frame.size.height - floatViewHeight ) {
         self.floatMenuView.frame = CGRectMake(0, self.mainViewTableView.tableHeaderView.frame.size.height - floatViewHeight+64-scrollView.contentOffset.y, self.view.frame.size.width, floatViewHeight);
    }
    else{
         self.floatMenuView.frame = CGRectMake(0, 64, self.view.frame.size.width, floatViewHeight);
    }
   
    
}

- (IBAction)chooseLocation:(id)sender {
    [self.myAccount checkLogin];
    NSMutableArray *locations = [self.myAccount.location mutableCopy];
    [locations insertObject:@"New location" atIndex:0];
    
    NSLog(@"y %f,height %f",self.navigationController.navigationBar.frame.origin.y,self.navigationController.navigationBar.frame.size.height);
    
    if (self.dropDownChooseLocation == nil) {
        CGFloat dropDownFrameHeight = 40 * (CGFloat)locations.count;
        
        self.dropDownChooseLocation = [[DropDownView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y, self.view.frame.size.width, dropDownFrameHeight)];
        [self.dropDownChooseLocation initDropDownView:self.chooseLocationBtn :40 :dropDownFrameHeight :locations];
        self.dropDownChooseLocation.delegate = self;
        self.blurEffectView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.blurEffectView];
        [self.view addSubview:self.dropDownChooseLocation];
        [self.blurEffectView addGestureRecognizer:self.tapToCloseChooseLocation];
    } else{
        [self.dropDownChooseLocation hideDropDownView];
        self.dropDownChooseLocation = nil;
        [self.blurEffectView removeFromSuperview];
        [self.blurEffectView removeGestureRecognizer:self.tapToCloseChooseLocation];
    }
}

-(void)hideDropDownView{
    [self.dropDownChooseLocation hideDropDownView];
    self.dropDownChooseLocation = nil;
    [self.blurEffectView removeFromSuperview];
    [self.blurEffectView removeGestureRecognizer:self.tapToCloseChooseLocation];
    
}

-(void)dropDownMenuClicked:(DropDownView *)sender{
    [self.blurEffectView removeFromSuperview];
    if ([sender.choosedString isEqualToString:@"New location"]) {
        [self doSearch];
    }else{
        //NSLog(@"%@",sender.choosedString);
    }
    NSLog(@"you choose %@",sender.choosedString);
    self.dropDownChooseLocation = nil;
}

-(void)dropDownMenuDelete:(DropDownView *)sender withString:(NSString *)string{
    //delete method
    [self.myAccount location:DELETE withLocation:string];
    self.dropDownChooseLocation.dropDownTableView.frame = CGRectMake(0, 0, self.chooseLocationBtn.superview.frame.size.width, 60 * (CGFloat)self.myAccount.location.count);
    [self.chooseLocationBtn setTitle:@"Choose location ▾" forState:UIControlStateNormal];
}

-(void)doSearch{
    [self initSearchTableView];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchTableView removeFromSuperview];
    [self.blurEffectViewForSearch removeFromSuperview];
    [self.searchController.searchBar removeFromSuperview];
    
    
}

-(void)searchBarCancelButtonClicked{
    [self.searchTableView removeFromSuperview];
    [self.blurEffectViewForSearch removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initSearchTableView{
    
    self.searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 2*40*1.5)];// 2 is results number
    self.blurEffectViewForSearch.frame = CGRectMake(self.view.bounds.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    //self.blurEffectViewForSearch.userInteractionEnabled = NO;
    [self.blurEffectViewForSearch addGestureRecognizer:self.tapToCloseSearchController];
    [self.searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"searchTableCell"];
    self.searchTableView.delegate = self.searchViewHelpController;
    self.searchTableView.dataSource = self.searchViewHelpController;
    
    //self.searchTableView.allowsSelection = YES;
    
    
    [self presentViewController:self.searchController animated:YES completion:^{
        [self.searchController.view addSubview:self.blurEffectViewForSearch];
        [self.searchController.view addSubview:self.searchTableView];
    }];
    
}

-(void)finishSearchWithResult:(NSString *)result{
    NSLog(@"search result %@",result);
    self.testString = result;
    [self.mainViewTableView reloadData];
    [self searchBarCancelButtonClicked];
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mainViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([cell.contentView subviews].count == 0) {
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(130, (mainViewcellHeight - 30)/2, 80, 30)];
        UILabel *catagory = [[UILabel alloc]initWithFrame:CGRectMake(130, 5, 100, 30)];
        UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(200, 65, 60, 30)];
        UILabel *distance = [[UILabel alloc]initWithFrame:CGRectMake(130, 65, 60, 30)];
        UILabel *heat = [[UILabel alloc]initWithFrame:CGRectMake(100, 5, 8, 90)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 90, 90)];
        
        name.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        name.textColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1];
        name.tag = tableCellTag+1;
        
        catagory.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        catagory.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
        catagory.tag = tableCellTag+2;
        
        price.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        price.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
        price.tag = tableCellTag+3;
        
        distance.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        distance.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
        distance.tag = tableCellTag+4;
        
        heat.tag = tableCellTag+5;
        heat.backgroundColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:94/255.0 alpha:1];
        
        imageView.image = [UIImage imageNamed:@"favoriteGreen.png"];
        imageView.tag = tableCellTag+6;
        
        if (self.testString !=nil) {
            name.text = self.testString;
        }
        else{
            name.text = @"shop";
        }
        
        catagory.text = @"catagory";
        price.text = @"price";
        distance.text = @"distance";
        
        [cell.contentView addSubview:name];
        [cell.contentView addSubview:catagory];
        [cell.contentView addSubview:price];
        [cell.contentView addSubview:distance];
        [cell.contentView addSubview:heat];
        [cell.contentView addSubview:imageView];
        return cell;
    }
    else{
        UILabel *name = (UILabel *)[cell.contentView viewWithTag: tableCellTag+1];
        UILabel *catagroy = (UILabel *)[cell.contentView viewWithTag: tableCellTag+2];
        UILabel *price = (UILabel *)[cell.contentView viewWithTag: tableCellTag+3];
        UILabel *distance = (UILabel *)[cell.contentView viewWithTag: tableCellTag+4];
        UILabel *heat = (UILabel *)[cell.contentView viewWithTag: tableCellTag+5];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: tableCellTag+5];
        //name.text = self.subCatagoryName[indexPath.row];
        if (self.testString !=nil) {
            name.text = self.testString;
        }
        else{
            name.text = @"shop";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return mainViewcellHeight;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 100;
//    }
//    return 0;
//}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    //self.mainViewTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.1)];
//    if (section == 0) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
//        [view setBackgroundColor:[UIColor yellowColor]];
//        
//        
//        return view;
//    }
//    else{
//        return nil;
//    }
//    
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewRowActionStyleDefault) {
        //NSLog(@"UITableViewRowActionStyleDefault");
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        
                                        NSLog(@"Favorite");
                                    }];
    button.backgroundColor = [UIColor redColor]; //arbitrary color
    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Button 2" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         
                                         NSLog(@"Action to perform with Button2!");
                                     }];
    button2.backgroundColor = [UIColor grayColor]; //arbitrary color
    
    return @[button, button2]; //array with all the buttons you want. 1,2,3, etc...
}

-(void) updateSearchResultsForSearchController:(UISearchController *)searchController{
    
}

-(void)catagoryBtnClicked{
    
    NSLog(@"catagory clicked");
    NSDictionary *fastFood = @{@"All":@246,@"Famous Brand":@128,@"Over Rice":@115,@"Noodes":@27,@"Pot Food":@24,@"Dumplings":@12};
    NSDictionary *feature = @{@"All":@138,@"Sea Food":@58,@"Sichuan":@37,@"Toast Fish":@27,@"Guangdong":@14,@"Muslim":@12};
    NSDictionary *foreigner = @{@"All":@43,@"Korea":@25,@"Japan":@13,@"West":@8,@"Spaghetti":@1};
    NSDictionary *dessert = @{@"All":@172,@"Local":@53,@"Barbecue":@44,@"Sids":@43};
    NSDictionary *drink = @{@"All":@84,@"Juice":@53,@"Cafee":@31};
    NSDictionary *catagory2 = @{@"All Shop":@500,@"fastFood":fastFood,@"feature":feature,@"foreigner":foreigner,@"dessert":dessert,@"drink":drink};
    
    NSLog(@"%@",catagory2);
    
    if (self.sortView != nil) {
        [self hideMainViewMenu];
    }
    [self.catagoryBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (self.coverView == nil && self.catagoryView == nil) {
        
        [UIView animateWithDuration:0.5 animations:^{
            if (self.mainViewTableView.contentOffset.y < 300 - floatViewHeight ) {
                [self.mainViewTableView setContentOffset:CGPointMake(0, 300) animated:NO];
                
            }
        } completion:^(BOOL finished){
            self.coverView = [[UIView alloc]initWithFrame:CGRectMake(0, self.floatMenuView.frame.size.height + self.floatMenuView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height*0.45)];
            
            self.coverViewBlankArea = [[UIVisualEffectView alloc]initWithEffect:self.blurEffet];
            self.coverViewBlankArea.frame = CGRectMake(0, self.coverView.frame.origin.y+ self.coverView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height -self.coverView.frame.origin.y- self.coverView.frame.size.height );

            self.catagoryView = [[CatagoryView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.45)];
            
            [self.catagoryView initCatagoryView:catagory2];
            
            [self.view addSubview:self.coverView];
            [self.view addSubview:self.coverViewBlankArea];
            [self.coverView addSubview:self.catagoryView];
            [self.coverViewBlankArea addGestureRecognizer:self.tapToCloseMainViewMenu];
        }];
        
    }
    else{
        [self hideMainViewMenu];
    }

}

-(void)sortBtnClicked{
    
    if (self.catagoryView != nil) {
        [self hideMainViewMenu];
    }
    [self.sortBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
   
    
    if (self.coverView == nil && self.sortView == nil) {
        [UIView animateWithDuration:0.5 animations:^{
            if (self.mainViewTableView.contentOffset.y < 300 - floatViewHeight ) {
                [self.mainViewTableView setContentOffset:CGPointMake(0, 300) animated:NO];
                
            }
        } completion:^(BOOL finished){
            self.coverView = [[UIView alloc]initWithFrame:CGRectMake(0, self.floatMenuView.frame.size.height + self.floatMenuView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height*0.45)];
            
            
            self.coverViewBlankArea = [[UIVisualEffectView alloc]initWithEffect:self.blurEffet];
            self.coverViewBlankArea.frame = CGRectMake(0, self.coverView.frame.origin.y+ self.coverView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height -self.coverView.frame.origin.y- self.coverView.frame.size.height );
            
            self.sortView = [[SortView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.45)];
            
            [self.sortView initSortView];
            
            [self.view addSubview:self.coverView];
            [self.view addSubview:self.coverViewBlankArea];
            [self.coverView addSubview:self.sortView];
            [self.coverViewBlankArea addGestureRecognizer:self.tapToCloseMainViewMenu];
        }];

        
    }else{
        [self hideMainViewMenu];
    }
}

-(void)filterBtnClicked{
    
}

-(void)hideMainViewMenu{
    [self.coverView removeFromSuperview];
    [self.coverViewBlankArea removeFromSuperview];
    self.coverView = nil;
    self.catagoryView = nil;
    self.coverViewBlankArea = nil;
    self.sortView = nil;
    [self.coverViewBlankArea removeGestureRecognizer:self.tapToCloseMainViewMenu];
    [self.catagoryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sortBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.filterBtn setTitleColor:[UIColor whiteColor   ] forState:UIControlStateNormal];
}

-(void)adjustMainViewMenu{
    if (self.mainViewTableView.contentOffset.y < 300 - floatViewHeight ) {
        [self.mainViewTableView setContentOffset:CGPointMake(0, 300) animated:YES];
        
    }
    
}
@end