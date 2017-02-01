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

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton		*_btnGuestLogin;
@property (strong, nonatomic) IBOutlet UIButton		*_btnFbLogin;
@property (strong, nonatomic) IBOutlet UIButton		*_btnLogout;
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
    [GBSession loginWithAuthType:GUEST withHandler:^(GBSession *newSession, GBError *error) {
        NSLog(@"%@", newSession);
        NSLog(@"%@", newSession.userKey);
    }];
}

- (IBAction)actionFBLogin:(id)sender
{
    [GBSession loginWithAuthType:FACEBOOK withHandler:^(GBSession *newSession, GBError *error) {
        
    }];
}

- (IBAction)actionLogout:(id)sender
{

}
@end
