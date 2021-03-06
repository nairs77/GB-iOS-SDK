//
//  ViewController.m
//  GBSample
//
//  Created by nairs77 on 2016. 12. 29..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import "ViewController.h"
//#import <GBSdk/GBSdk.h>
#import <GBSdk/GBSession.h>
//#import <GBSdk/GBGlobal.h>
#import <GBSdk/GBInApp.h>


@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton		*_btnGuestLogin;
@property (strong, nonatomic) IBOutlet UIButton		*_btnFbLogin;
@property (strong, nonatomic) IBOutlet UIButton		*_btnLogout;
@property (strong, nonatomic) IBOutlet UIButton     *_btnBuyItem;
@property (strong, nonatomic) IBOutlet UIButton     *_btnRestoreItem;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Public

- (IBAction)actionLogin:(id)sender
{
    SessionState state = [[GBSession activeSession] state];
    
    NSLog(@"state = %d", (int)state);
    
    [GBSession loginWithAuthType:GUEST withHandler:^(GBSession *newSession, GBError *error) {
        NSLog(@"%@", newSession);
        NSLog(@"%@", newSession.userKey);
    }];
}

- (IBAction)actionFBLogin:(id)sender
{
    [GBSession connectChannel:FACEBOOK withHandler:^(GBSession *newSession, GBError *error) {
        
    }];
}

- (IBAction)actionLogout:(id)sender
{

}

- (IBAction)actionBuyItem:(id)sender
{
    [GBInApp requestProducts:[NSSet setWithObject:@"sample_coin_100"] success:^(NSArray *products, NSArray *invalidProducsts) {
        if ([products count] > 0) {
            
            [GBInApp buyItem:[GBSession activeSession].userKey sku:@"sample_coin_100" price:1000 success:^(NSString *paymentKey) {
                NSLog(@"paymentKey = %@", paymentKey);
            } failure:^(GBError *error) {
                
            }];
        }
    } failure:^(GBError *error) {
        
    }];
}

- (IBAction)actionRestoreItem:(id)sender
{
    [GBInApp restoreItem:[GBSession activeSession].userKey resultBlock:^(NSArray *paymentKeys) {
        NSLog(@"Arrays = %@", paymentKeys);
    }];
}
@end
