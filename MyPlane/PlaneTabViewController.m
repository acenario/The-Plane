//
//  PlaneTabViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/6/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "PlaneTabViewController.h"
#import "RemindersViewController.h"

@interface PlaneTabViewController ()


@end

@implementation PlaneTabViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBar.clipsToBounds = NO;
    //buttonAdd-FlatUI@2x
    //[self addCenterButtonWithOptions:@{@"buttonImage": @"buttonAdd.png"}];
    [self addCenterButtonWithOptions:@{
     @"buttonImage": @"buttonAdd-Flat.png",
     @"highlightImage": @"buttonAdd-Flat-Selected.png"
     }];
    [self registerDefaults];
    
    
    
    //RemindersViewController *remindersController = [[self viewControllers] objectAtIndex:0];


    
    /*PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [userQuery includeKey:@"friends"];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.tabBarUserObject = (UserInfo *)object;
        remindersController.userObjectFromTabBar = self.tabBarUserObject;
        
        
        
    }];
  
    userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;*/
    
        
    /*BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
     if (firstTime) {
     NSLog(@"FIRST TIME BABY!");
     [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
     }*/
    
    
    //UIColor *selectedColor = [UIColor darkGrayColor];
    //self.tabBar.selectionIndicatorImage = [UIImage imageWithColor:selectedColor cornerRadius:6.0];
    
    
    
	// Do any additional setup after loading the view.
}

- (void)registerDefaults
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], @"FirstTime",
                                nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addCenterButtonWithOptions:(NSDictionary *)options {
    UIImage *buttonImage = [UIImage imageNamed:options[@"buttonImage"]];
    UIImage *highlightImage = [UIImage imageNamed:options[@"highlightImage"]];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
    item.enabled = NO;
    
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button setContentMode:UIViewContentModeCenter];
    [button addTarget:self action:@selector(centerItemTapped) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize tabbarSize = self.tabBar.bounds.size;
    CGPoint center = CGPointMake(tabbarSize.width/2, tabbarSize.height/2);
    center.y = center.y - 9.5;
    button.center = center;
    
    [self.tabBar addSubview:button];
}

- (void)centerItemTapped {

    if (self.tabBar.selectedItem.tag == 100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mpCenterTabbarItemTapped" object:nil];
    }
    
    else if (self.tabBar.selectedItem.tag == 200) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"spCenterTabbarItemTapped" object:nil];
    }
    
    else if (self.tabBar.selectedItem.tag == 300) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fCenterTabbarItemTapped" object:nil];
    }
    
    else if (self.tabBar.selectedItem.tag == 400) {
        NSLog(@"This is settings page with 400");
    }
    
    
        
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}





@end
