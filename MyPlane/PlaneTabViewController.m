//
//  PlaneTabViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/6/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "PlaneTabViewController.h"

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
    [self addCenterButtonWithOptions:@{@"buttonImage": @"buttonAdd.png"}];
    
    
    
    
	// Do any additional setup after loading the view.
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
        NSLog(@"This is friends page with 300");
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
