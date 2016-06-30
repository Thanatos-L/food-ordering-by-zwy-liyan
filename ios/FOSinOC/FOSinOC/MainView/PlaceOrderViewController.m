//
//  PlaceOrderViewController.m
//  FOSinOC
//
//  Created by MoonSlides on 16/6/28.
//  Copyright © 2016年 李龑. All rights reserved.
//
#define myGreenColor [UIColor colorWithRed:91/255.0 green:207/255.0 blue:122/255.0 alpha:1]
#define myGreenColorHighlight [UIColor colorWithRed:76/255.0 green:134/255.0 blue:91/255.0 alpha:1]
#define myBlackColor [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1]
#define myBlackIron [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1]
#define myBlackSteel [UIColor colorWithRed:121/255.0 green:121/255.0 blue:121/255.0 alpha:1]

#define bottomViewHeight 50
#define tableCellTag 1760

#import "PlaceOrderViewController.h"
#import "Account.h"
#import "Shop.h"

#import "ShopDetailedViewController.h"
#import "ChooseAddressViewController.h"

@interface PlaceOrderViewController ()<UITableViewDelegate,UITableViewDataSource,ChooseAddressViewDelegate>
@property (strong,nonatomic) UIView *bottomView;
@property (strong,nonatomic) UIButton *payButton;
@property (assign,nonatomic) NSUInteger *totalPrice;
@property (strong,nonatomic) UILabel *priceLabel;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) Account *myAccount;
@property (strong,nonatomic) Shop *myShop;

@property (strong,nonatomic) NSMutableArray *shopList;


@end

@implementation PlaceOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self initBottomView];
    self.myAccount = [Account sharedManager];
    self.myShop = [Shop sharedManager];
//    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
//    self.navigationController.navigationBar.layer.shadowRadius = 4.0f;
//    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self cleanShopData];
    NSLog(@"cart detailed %@",self.myAccount.cartDetail);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initBottomView{
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    self.bottomView.backgroundColor = myBlackColor;
    
    self.priceLabel = [[UILabel alloc]init];
    //self.priceLabel.numberOfLines = 0;
    self.priceLabel.text = @"Total Price: $0";
    self.priceLabel.textColor = [UIColor whiteColor];
    self.priceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.priceLabel.frame = CGRectMake(80, 10, 100, 30);
    
    self.payButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 120, 0, 120, bottomViewHeight)];
    [self.payButton setBackgroundColor:myGreenColor];
    [self.payButton setTitle:@"Pay" forState:UIControlStateNormal];
    [self.payButton addTarget:self action:@selector(payButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.payButton addTarget:self action:@selector(payButtonHighlight) forControlEvents:UIControlEventTouchDown];
    self.payButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];

    [self.bottomView addSubview:self.payButton];
    [self.bottomView addSubview:self.priceLabel];
    [self.view addSubview:self.bottomView];
    
}

-(void)initTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - bottomViewHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell self] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.tableView];
}

-(void)cleanShopData{
    self.shopList = [[NSMutableArray alloc]init];
    [self.shopList addObject:[self.myAccount.cartDetail[0] valueForKey:@"shopId"]];
    NSLog(@"shop list %@",self.shopList);
    for (int i =0; i<self.myAccount.cartDetail.count; i++) {
        BOOL isFindShop = false;
        for (int j = 0; j<self.shopList.count; j++) {
            
            if ([self.shopList[j] isEqualToString:[self.myAccount.cartDetail[i] valueForKey:@"shopId"]]) {
                isFindShop = true;
                break;
            }
            
            if (!isFindShop && j==self.shopList.count - 1) {
                [self.shopList addObject:[self.myAccount.cartDetail[i] valueForKey:@"shopId"]];
            }
        }
        
    }
    
    NSLog(@"shop list %@",self.shopList);
}

#pragma mark - Tableview delegate and Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3+self.shopList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;// first section for delivery address and delivery time
    }else if(section == 1){
        return 1; //payment online or offline
    }else if(section > 1 && section<2+self.shopList.count){
        return 2;// shop and items
    }else{
        return 1;// message
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if ([cell.contentView subviews].count == 0) {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 24)];
                name.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                name.tag = tableCellTag+1;
                UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(20, 35, 100, 24)];
                address.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                address.tag = tableCellTag+2;
                UILabel *phone = [[UILabel alloc]initWithFrame:CGRectMake(125, 5, 100, 24)];
                phone.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                phone.tag = tableCellTag+3;
                UIImageView *separateLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
                separateLine.image = [UIImage imageNamed:@"markLineRed.png"];
                separateLine.clipsToBounds = true;
                separateLine.tag = tableCellTag + 11;
                if (self.myAccount.deliverAddress.count>0) {
                    name.text = [self.myAccount.deliverAddress[0] valueForKey:@"name"];
                    address.text = [self.myAccount.deliverAddress[0] valueForKey:@"addr"];
                    phone.text = [self.myAccount.deliverAddress[0] valueForKey:@"phone"];
                }
                
                
                [cell.contentView addSubview:name];
                [cell.contentView addSubview:phone];
                [cell.contentView addSubview:address];
                [cell.contentView addSubview:separateLine];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else if(indexPath.row == 1){
                //cell.textLabel.text = @"delivery time";
            }
            
        } if(indexPath.section == 1){
            if (indexPath.row == 0) {
                UILabel *payment = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 30)];
                payment.text = @"Payment";
                payment.tag = tableCellTag + 4;
                payment.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                
                UILabel *payment2 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 5, 100, 30)];
                payment2.text = @"Online";
                payment2.tag = tableCellTag + 5;
                payment2.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                [cell.contentView addSubview:payment];
                [cell.contentView addSubview:payment2];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
        } if(indexPath.section > 1 && indexPath.section<2+self.shopList.count){
            if (indexPath.row == 0) {
                int itemCount = 0;
                for (int i = 0; i<self.myAccount.cartDetail.count; i++) {
                    if ([[self.myAccount.cartDetail[i] valueForKey:@"shopId"] isEqualToString:self.shopList[indexPath.section - 2]]) {
                        UILabel *itemName = [[UILabel alloc]initWithFrame:CGRectMake(20, 5 + itemCount*(5+24), 150, 24)];
                        itemName.tag = tableCellTag+6;
                        itemName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                        itemName.text = [self.myAccount.cartDetail[i] valueForKey:@"dishName"];
                        [cell.contentView addSubview:itemName];
                        
                        UILabel *amount = [[UILabel alloc]initWithFrame:CGRectMake(190, 5 + itemCount*(5+24), 80, 24)];
                        amount.tag = tableCellTag+7;
                        amount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                        amount.text = [NSString stringWithFormat:@"x%@",[[self.myAccount.cartDetail[i] valueForKey:@"amount"] stringValue]];
                        [cell.contentView addSubview:amount];
                        
                        UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(250, 5 + itemCount*(5+24), 100, 24)];
                        price.tag = tableCellTag+8;
                        price.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                        price.text = [NSString stringWithFormat:@"$ %@",[[self.myAccount.cartDetail[i] valueForKey:@"price"] stringValue]];
                        [cell.contentView addSubview:price];
                        
                        itemCount = itemCount+1;
                    }
                }
                
            }  if(indexPath.row == 1){
                UILabel *total = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 5, 100, 24)];
                total.tag = tableCellTag+9;
                total.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                NSInteger totalPrice = 0;
                for (int i = 0; i<self.myAccount.cartDetail.count; i++) {
                    if ([[self.myAccount.cartDetail[i] valueForKey:@"shopId"] isEqualToString:self.shopList[indexPath.section - 2]]) {
                        totalPrice = totalPrice + [[self.myAccount.cartDetail[i] valueForKey:@"price"] integerValue];
                    }
                }
                NSString *priceText = [[NSNumber numberWithInteger:totalPrice] stringValue];
                total.text = [NSString stringWithFormat:@"Total $%@",priceText];
                [cell.contentView addSubview:total];
                
            }
        } if(indexPath.section == 2+self.shopList.count){
            UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 5, 100, 24)];
            messageLabel.tag = tableCellTag + 10;
            messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
            messageLabel.text = @"message";
            [cell.contentView addSubview:messageLabel];
            NSLog(@"message section %ld, row %ld",indexPath.section,indexPath.row);
        }
    }else{
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                UILabel *name = (UILabel *)[cell.contentView viewWithTag:tableCellTag+1];
                UILabel *address = (UILabel *)[cell.contentView viewWithTag:tableCellTag+2];
                UILabel *phone = (UILabel *)[cell.contentView viewWithTag:tableCellTag+3];
                if (self.myAccount.deliverAddress.count>0) {
                    name.text = [self.myAccount.deliverAddress[0] valueForKey:@"name"];
                    address.text = [self.myAccount.deliverAddress[0] valueForKey:@"addr"];
                    phone.text = [self.myAccount.deliverAddress[0] valueForKey:@"phone"];
                }
                name.frame = CGRectMake(20, 5, 100, 24);
                address.frame = CGRectMake(20, 35, 100, 24);
                phone.frame = CGRectMake(125, 5, 100, 24);
                [cell.contentView addSubview:name];
                [cell.contentView addSubview:phone];
                [cell.contentView addSubview:address];
//                UILabel *messageLebel = (UILabel *)[cell.contentView viewWithTag:tableCellTag+10];
//                [messageLebel removeFromSuperview];
                for (int i = 4; i<11; i++) {
                    UILabel *label = (UILabel *)[cell.contentView viewWithTag:tableCellTag+i];
                    [label removeFromSuperview];
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else if(indexPath.row == 1){
                //cell.textLabel.text = @"delivery time";
                for (int i = 1; i<4; i++) {
                    UILabel *label = (UILabel *)[cell.contentView viewWithTag:tableCellTag+i];
                    [label removeFromSuperview];
                }
                for (int i = 5; i<11; i++) {
                    UILabel *label = (UILabel *)[cell.contentView viewWithTag:tableCellTag+i];
                    [label removeFromSuperview];
                }
            }
            
        } if(indexPath.section == 1){
            if (indexPath.row == 0) {
                UILabel *payment = (UILabel *)[cell.contentView viewWithTag:tableCellTag+4];
                UILabel *payment2 = (UILabel *)[cell.contentView viewWithTag:tableCellTag+5];
                payment.text = @"Payment";
                payment2.text = @"Online";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                [cell.contentView addSubview:payment];
//                [cell.contentView addSubview:payment2];
            }
        } if(indexPath.section > 1 && indexPath.section<2+self.shopList.count){
            if (indexPath.row == 0) {
                int itemCount = 0;
                for (int i = 0; i<self.myAccount.cartDetail.count; i++) {
                    if ([[self.myAccount.cartDetail[i] valueForKey:@"shopId"] isEqualToString:self.shopList[indexPath.section - 2]]) {
                        UILabel *itemName = (UILabel *)[cell.contentView viewWithTag:tableCellTag+6];
                        itemName.text = [self.myAccount.cartDetail[i] valueForKey:@"dishName"];
                        
                        UILabel *amount = (UILabel *)[cell.contentView viewWithTag:tableCellTag+7];
                        amount.text = [NSString stringWithFormat:@"x%@",[[self.myAccount.cartDetail[i] valueForKey:@"amount"] stringValue]];
                        
                        UILabel *price = (UILabel *)[cell.contentView viewWithTag:tableCellTag+8];
                        price.text = [NSString stringWithFormat:@"$ %@",[[self.myAccount.cartDetail[i] valueForKey:@"price"] stringValue]];
                        itemCount = itemCount+1;
//                        [cell.contentView addSubview:itemName];
//                        [cell.contentView addSubview:amount];
//                        [cell.contentView addSubview:price];
                    }
                }

            }  if(indexPath.row == 1){
                UILabel *total = (UILabel *)[cell.contentView viewWithTag:tableCellTag+9];
                NSInteger totalPrice = 0;
                for (int i = 0; i<self.myAccount.cartDetail.count; i++) {
                    if ([[self.myAccount.cartDetail[i] valueForKey:@"shopId"] isEqualToString:self.shopList[indexPath.section - 2]]) {
                        totalPrice = totalPrice + [[self.myAccount.cartDetail[i] valueForKey:@"price"] integerValue];
                    }
                }
                NSString *priceText = [[NSNumber numberWithInteger:totalPrice] stringValue];
                total.text = [NSString stringWithFormat:@"Total $%@",priceText];
                //[cell.contentView addSubview:total];
            }
        } if(indexPath.section == 2+self.shopList.count){
            
            UIImageView *line = (UIImageView *)[cell.contentView viewWithTag:tableCellTag+11];
            [line removeFromSuperview];
            for (int i = 1; i<10; i++) {
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:tableCellTag+i];
                [label removeFromSuperview];
            }
            UILabel *messageLebel = (UILabel *)[cell.contentView viewWithTag:tableCellTag+10];
            messageLebel.text = @"message reuse";
            [cell.contentView addSubview:messageLebel];
            NSLog(@"message section %ld, row %ld",indexPath.section,indexPath.row);
        }

    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section > 1 && section<2+self.shopList.count){
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        //headVieww.backgroundColor = [UIColor redColor];
        headView.userInteractionEnabled = true;
        headView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headViewTouchHandle:)];
        [headView addGestureRecognizer:tapGesture];
        
        
        UILabel *shopName = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 120, 20)];
        shopName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        shopName.textColor = myBlackSteel;
        for (int i = 0; i<self.myAccount.cartDetail.count; i++) {
            if ([[self.myAccount.cartDetail[i] valueForKey:@"shopId"] isEqualToString:self.shopList[section -2]]) {// minus 2 is for the non-shop section 0,1
                shopName.text = [self.myAccount.cartDetail[i] valueForKey:@"shopName"];
                break;
            }
        }
        
        UIImageView *shopIcon = [[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
        shopIcon.clipsToBounds = true;
        shopIcon.image = [UIImage imageNamed:@"shopIcon"];
        
        [headView addSubview:shopIcon];
        [headView addSubview:shopName];
        return headView;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section > 1 && section<2+self.shopList.count){
        return 30;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 62;
        }
    }else if(indexPath.section > 1 && indexPath.section<2+self.shopList.count){
        CGFloat height = 0;
        if (indexPath.row == 0) {
            for (int i = 0; i<self.myAccount.cartDetail.count; i++) {
                if ([[self.myAccount.cartDetail[i] valueForKey:@"shopId"] isEqualToString:self.shopList[indexPath.section - 2]]) {
                    height = height+30;
                }
            }
            return height;
        }
        
    }
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"address" sender:self];
    }
}

#pragma mark - Button Handle

-(void)payButtonHandle{
    [self.payButton setBackgroundColor:myGreenColor];
}

-(void)payButtonHighlight{
    [self.payButton setBackgroundColor:myGreenColorHighlight];
}

-(void)headViewTouchHandle:(UITapGestureRecognizer *)tapGesture{
    CGPoint pointInView = [tapGesture locationInView:self.view];
    CGPoint pointInTable = [tapGesture locationInView:self.tableView];
    NSLog(@"in view %f %f",pointInView.x, pointInView.y);
    NSLog(@"in view %f %f",pointInTable.x, pointInTable.y);
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointInTable];
    NSLog(@"clicked section %ld",indexPath.section);
    [self performSegueWithIdentifier:@"showshop" sender:self.shopList[indexPath.section - 2]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual: @"showshop"]) {
        ShopDetailedViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.shopID = sender;
    } else if ([segue.identifier isEqual: @"address"]) {
        ChooseAddressViewController *destinationVC = segue.destinationViewController;
        destinationVC.delegate = self;
    }
}

-(void)ChooseAddressViewDidSelectedAddressWithName:(NSString *)name phone:(NSString *)phone address:(NSString *)address{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:tableCellTag+1];
    UILabel *phoneLabel = (UILabel *)[cell.contentView viewWithTag:tableCellTag+3];
    UILabel *addressLabel = (UILabel *)[cell.contentView viewWithTag:tableCellTag+2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        nameLabel.text = name;
        phoneLabel.text = phone;
        addressLabel.text = address;
    });
}

@end
