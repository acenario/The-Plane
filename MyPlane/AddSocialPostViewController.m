//
//  AddSocialPostViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddSocialPostViewController.h"

@interface AddSocialPostViewController ()

@end

@implementation AddSocialPostViewController {
    Circles *circleObject;
    UserInfo *userObject;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nil;
}

- (IBAction)done:(id)sender {
        
    SocialPosts *post = [SocialPosts object];
    [post setObject:self.postTextField.text forKey:@"text"];
    [post setObject:circleObject forKey:@"circle"];
    [post setObject:userObject forKey:@"user"];
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCircle"]) {
        PickCircleViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.userQuery = self.userQuery;
    }
}

- (void)pickCircleViewController:(PickCircleViewController *)controller didSelectCircle:(Circles *)circle
{
    self.circleLabel.text = circle.name;
    circleObject = circle;
}

@end