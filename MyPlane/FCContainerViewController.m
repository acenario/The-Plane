//
//  FCContainerViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FCContainerViewController.h"

@interface FCContainerViewController ()

@end

@implementation FCContainerViewController

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
    self.circContainer.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    //UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"friendQuery"];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changePage:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        NSLog(@"showFriends");
    } else {
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        NSLog(@"show circles");
    }
}

- (void)friendsSegmentChanged:(UISegmentedControl *)segmentedController
{
    if (segmentedController.selectedSegmentIndex == 0) {
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        NSLog(@"showFriends");
    } else {
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        NSLog(@"show circles");
    }
}

- (void)circlesSegmentDidChange:(UISegmentedControl *)segmentedController
{
    if (segmentedController.selectedSegmentIndex == 0) {
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        NSLog(@"showFriends");
    } else {
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        NSLog(@"show circles");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Circles"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        CirclesViewController *controller = (CirclesViewController *)nav.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Friends"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        FriendsQueryViewController *controller = (FriendsQueryViewController *)nav.topViewController;
        controller.delegate = self;
    }
}

@end
