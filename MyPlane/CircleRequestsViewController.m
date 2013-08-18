//
//  CircleRequestsViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CircleRequestsViewController.h"

@interface CircleRequestsViewController ()

@property (nonatomic, strong) NSString *segmentName;
@property (nonatomic, strong) NSMutableArray *invites;
@property (nonatomic, strong) NSMutableArray *requests;

@end

@implementation CircleRequestsViewController {
    PFQuery *userQuery;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (PFQuery *)queryForTable
{
    //    userQuery = [UserInfo query];
    //    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    //
    //    PFQuery *circleQuery = [Circles query];
    //    [circleQuery whereKey:@"members" matchesQuery:userQuery];
    //    [circleQuery includeKey:@"owner"];circle IN %@ OR
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user = %@ AND date >= %@",username,currentDate];
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"invitedUsername = %@", [PFUser currentUser].username];
    PFQuery *query = [Requests query];
    [query whereKeyExists:@"circle"];
    //    [query whereKey:@"circle" containedIn:self.circles];
    //    [query whereKey:@"invitedUsername" equalTo:[PFUser currentUser].username];
    //    NSLog(@"%@", [PFUser currentUser].username);
    [query includeKey:@"circle"];
    [query includeKey:@"requester"];
    [query includeKey:@"invited"];
    [query includeKey:@"invitedBy"];
    
    
    return query;
    
}


-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    NSLog(@"begin");
    
    for (Requests *request in self.objects) {
        if (request.invited) {
            //                if ([request.invitedUsername isEqualToString:[PFUser currentUser].username]) {
            [self.invites addObject:request];
            NSLog(@"in load %d", self.invites.count);
            //                }
        } else {
            [self.requests addObject:request];
        }
    }
    
    if (error) {
        NSLog(@"error: %@", error);
        
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    NSLog(@"objects: %d", self.objects.count);
    self.segmentName = @"invites";
    
    self.invites = [[NSMutableArray alloc] initWithCapacity:5];
    self.requests = [[NSMutableArray alloc] initWithCapacity:5];
    
    //    for (Requests *request in self.objects) {
    //        if (request.invited != nil) {
    ////            if ([request.invitedUsername isEqualToString:[PFUser currentUser].username]) {
    //                [self.invites addObject:request];
    ////            }
    //        } else {
    //            [self.requests addObject:request];
    //        }
    //    }
    
    self.tableView.rowHeight = 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.segmentName isEqualToString:@"invites"]) {
        NSLog(@"%d", self.invites.count);
        return self.invites.count;
    } else {
        NSLog(@"%d", self.requests.count);
        return self.requests.count;
    }
    //    return 0;
}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.segmentName isEqualToString:@"invites"]) {
        
        static NSString *cellIdentifier = @"InviteCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        Requests *request = (Requests *)[self.invites objectAtIndex:indexPath.row];
        
        Circles *circle = (Circles *)request.circle;
        UserInfo *inviter = (UserInfo *)request.invitedBy;
        
        UITextView *inviterName = (UITextView *)[cell viewWithTag:6001];
        UITextView *circleName = (UITextView *)[cell viewWithTag:6002];
        PFImageView *inviterImage = (PFImageView *)[cell viewWithTag:6011];
        UIButton *accept = (UIButton *)[cell viewWithTag:6041];
        
        inviterName.text = [NSString stringWithFormat:@"%@ %@ invites you to join", inviter.firstName, [inviter.lastName substringToIndex:1]];
        circleName.text = circle.searchName;
        inviterImage.file = inviter.profilePicture;
        [inviterImage loadInBackground];
        
        [accept addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"RequestCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Requests *request = (Requests *)[self.requests objectAtIndex:indexPath.row];
        
        Circles *circle = (Circles *)request.circle;
        UserInfo *requester = (UserInfo *)request.requester;
        
        UITextView *name = (UITextView *)[cell viewWithTag:6003];
        UITextView *requesterName = (UITextView *)[cell viewWithTag:6004];
        PFImageView *requesterImage = (PFImageView *)[cell viewWithTag:6012];
        UIButton *accept = (UIButton *)[cell viewWithTag:6042];
        
        name.text = circle.searchName;
        requesterName.text = [NSString stringWithFormat:@"%@ %@", requester.firstName, requester.lastName];
        requesterImage.file = requester.profilePicture;
        [requesterImage loadInBackground];
        
        [accept addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nil;
}

- (void)acceptRequest:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    Circles *circle = [self.objects objectAtIndex:clickedButtonPath.row];
    UserInfo *object = [UserInfo objectWithoutDataWithObjectId:self.currentUser.objectId];
    
    [circle addObject:self.currentUser forKey:@"members"];
    [circle removeObject:object forKey:@"pendingMembers"];
    [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.currentUser removeObject:[Circles objectWithoutDataWithObjectId:circle.objectId] forKey:@"circleRequests"];
        [self.currentUser saveInBackground];
        [self loadObjects];
    }];
}

- (IBAction)segmentedChange:(id)sender {
    self.segmentName = [[self.segmentedControl titleForSegmentAtIndex:self.segmentedControl.selectedSegmentIndex] lowercaseString];
    [self.tableView reloadData];
}

@end
