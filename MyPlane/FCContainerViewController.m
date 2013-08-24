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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"fCenterTabbarItemTapped"
                                               object:nil];
    self.circContainer.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    //UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"friendQuery"];
    
	// Do any additional setup after loading the view.
}


- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"fCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for friends or circles!");
        if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"containerAddFriend" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"containerCreateCircle" sender:nil];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changePage:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFriends" object:nil];
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        NSLog(@"showFriends");
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCircles" object:nil];
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        NSLog(@"show circles");
    }
}

- (void)friendsSegmentChanged:(UISegmentedControl *)segmentedController
{
    if (segmentedController.selectedSegmentIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFriends" object:nil];
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        self.segmentedControl.selectedSegmentIndex = 0;
        NSLog(@"showFriends");
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCircles" object:nil];
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        self.segmentedControl.selectedSegmentIndex = 1;
        NSLog(@"show circles");
    }
}

- (void)circlesSegmentDidChange:(UISegmentedControl *)segmentedController
{
    if (segmentedController.selectedSegmentIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFriends" object:nil];
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        self.segmentedControl.selectedSegmentIndex = 0;
        NSLog(@"showFriends");
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCircles" object:nil];
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        self.segmentedControl.selectedSegmentIndex = 1;
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
