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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"invitedUsername = %@ OR circle IN %@", [PFUser currentUser].username, self.circles];
    PFQuery *query = [PFQuery queryWithClassName:@"Requests" predicate:predicate];

    [query includeKey:@"circle"];
    [query includeKey:@"requester"];
    [query includeKey:@"invited"];
    [query includeKey:@"invitedBy"];
    
    return query;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.segmentName = @"invites";
    
    self.invites = [[NSMutableArray alloc] initWithCapacity:5];
    self.requests = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSLog(@"%@", self.objects);
    for (Requests *request in self.objects) {
        if (request.invited != nil) {
                [self.invites addObject:request];
        } else {
            [self.requests addObject:request];
        }
    }
    
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
    NSLog(@"%@", self.objects);
    if ([self.segmentName isEqualToString:@"invites"]) {
        NSLog(@"%lu", (unsigned long)self.invites.count);
        return self.invites.count;
    } else {
        NSLog(@"%lu", (unsigned long)self.requests.count);
        return self.requests.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.segmentName isEqualToString:@"invites"]) {
        
        static NSString *CellIdentifier = @"InviteCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
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
