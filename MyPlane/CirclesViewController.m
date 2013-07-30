//
//  CirclesViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/20/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CirclesViewController.h"

@interface CirclesViewController ()

@end

@implementation CirclesViewController {
    PFQuery *userQuery;
    UserInfo *userObject;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.segmentedControl.selectedSegmentIndex = 1;
//    self.navigationController.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%d", self.count];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
        self.requestButton.title = [NSString stringWithFormat:@"%d Requests", userObject.circleRequests.count];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    PFQuery *query = [Circles query];
    [query whereKey:@"members" matchesQuery:userQuery];
    [query includeKey:@"owner"];
    
    return query;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    Circles *circleObject = (Circles *)object;
    
    cell.textLabel.text = circleObject.searchName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d member(s)", [circleObject.members count]];
    
    return cell;
}

//- (IBAction)segmentedSwitch:(id)sender {
//    if ([sender selectedSegmentIndex] == 0) {
//        [self dismissViewControllerAnimated:NO completion:nil];
//    }
//}

- (void)joinCircleViewControllerDidFinishAddingFriends:(JoinCircleViewController *)controller
{
    [self loadObjects];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CircleRequests"]) {
        CircleRequestsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"CircleDetail"]) {
        CircleDetailViewController *controller = [segue destinationViewController];
        Circles *circle = (Circles *)sender;
        controller.delegate = self;
        controller.circle = circle;
    }
}

- (void)circleRequestsDidFinish:(CircleRequestsViewController *)controller
{
    [self loadObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Circles *circle = [self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"CircleDetail" sender:circle];
}

@end
