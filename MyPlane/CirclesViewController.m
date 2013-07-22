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
    NSMutableArray *friendsArray;
    NSMutableArray *sentFriendRequestsArray;
    NSMutableArray *searchResults;
    NSMutableArray *friendsObjectId;
    NSMutableArray *sentFriendRequestsObjectId;
    PFQuery *currentUserQuery;
    PFQuery *friendQuery;
    UserInfo *userObject;
}

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
	// Do any additional setup after loading the view.
//    self.segmentedControl.selectedSegmentIndex = 1;
//    self.navigationController.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%d", self.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    PFQuery *query = [Circles query];
    [query whereKey:@"members" matchesQuery:userQuery];
    
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
    
    cell.textLabel.text = circleObject.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d member(s)", [circleObject.members count]];
    
    return cell;
}

//- (IBAction)segmentedSwitch:(id)sender {
//    if ([sender selectedSegmentIndex] == 0) {
//        [self dismissViewControllerAnimated:NO completion:nil];
//    }
//}

- (void)filterResults:(NSString *)searchTerm
{
    NSString *newTerm = [searchTerm lowercaseString];
    
    //[self.searchResults removeAllObjects];
    
    friendQuery = [UserInfo query];
    [friendQuery whereKey:@"user" containsString:newTerm];
    
    if (self.objects.count == 0) {
        friendQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:[friendQuery findObjects]];
        /*NSArray *results = [query findObjects];
         [self.searchResults addObjectsFromArray:results];*/
        [self loadObjects];
    });
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterResults:searchBar.text];
    [searchBar resignFirstResponder];
}

@end
