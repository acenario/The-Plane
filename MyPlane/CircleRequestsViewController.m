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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"invitedUsername = %@ OR circle IN %@ AND requester IN SELF", [PFUser currentUser].username, self.circles, nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Requests" predicate:predicate];
    [query whereKeyExists:@"circle"];
    [query includeKey:@"circle"];
    [query includeKey:@"requester"];
    [query includeKey:@"invited"];
    [query includeKey:@"invitedBy"];
    
    
    return query;
    
}


-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    [self.invites removeAllObjects];
    [self.requests removeAllObjects];
    
    for (Requests *request in self.objects) {
        if (request.invited) {
            [self.invites addObject:request];
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
    self.segmentName = @"invites";
    
    self.invites = [[NSMutableArray alloc] initWithCapacity:5];
    self.requests = [[NSMutableArray alloc] initWithCapacity:5];
    
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
        return self.invites.count;
    } else {
        return self.requests.count;
    }
}

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
    NSLog(@"YES");
    if ([self.segmentName isEqualToString:@"invites"]) {
        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        Requests *request = [self.invites objectAtIndex:clickedButtonPath.row];
        Circles *circle = (Circles *)request.circle;
        UserInfo *user = [UserInfo objectWithoutDataWithObjectId:self.currentUser.objectId];
        
        NSLog(@"1");
        [circle addObject:user forKey:@"members"];
        [request delete];
        
        [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"2");
            [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"3");
                [self loadObjects];
            }];
        }];
        
    } else {
        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        Requests *request = [self.requests objectAtIndex:clickedButtonPath.row];
        Circles *circle = (Circles *)request.circle;
        UserInfo *user = [UserInfo objectWithoutDataWithObjectId:request.requester.objectId];
        NSLog(@"1");

        if ([circle.members containsObject:user]) {
            [self loadObjects];
            NSLog(@"2");

        } else {
            [circle addObject:user forKey:@"members"];
            [request delete];
            NSLog(@"3");
            
            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"4");

                [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"5");

                    [self loadObjects];
                }];
            }];
        }
    }
}

- (IBAction)segmentedChange:(id)sender {
    self.segmentName = [[self.segmentedControl titleForSegmentAtIndex:self.segmentedControl.selectedSegmentIndex] lowercaseString];
    [self.tableView reloadData];
}

@end
