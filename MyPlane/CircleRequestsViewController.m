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
    //    [circleQuery includeKey:@"owner"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"circle IN %@ OR invitedUsername = '%@'", self.circles, self.currentUser.user];
    PFQuery *query = [PFQuery queryWithClassName:@"Requests" predicate:predicate];
//    [query whereKey:@"circle" containedIn:self.circles];
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
    
    self.invites = [[NSMutableArray alloc] init];
    self.requests = [[NSMutableArray alloc] init];
    
    for (Requests *request in self.objects) {
        if (request.invited != nil) {
//            if ([request.invitedUsername isEqualToString:[PFUser currentUser].username]) {
                [self.invites addObject:request];
//            }
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
    if ([self.segmentName isEqualToString:@"invites"]) {
        return self.invites.count;
    } else {
        return self.requests.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    if ([self.segmentName isEqualToString:@"invites"]) {
        
        static NSString *CellIdentifier = @"InviteCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Requests *request = (Requests *)object;
        
        Circles *circle = (Circles *)request.circle;
        UserInfo *owner = (UserInfo *)request.requester;
        
        UITextView *name = (UITextView *)[cell viewWithTag:6001];
        UITextView *creator = (UITextView *)[cell viewWithTag:6002];
        PFImageView *creatorImage = (PFImageView *)[cell viewWithTag:6011];
        UIButton *accept = (UIButton *)[cell viewWithTag:6041];
        
        name.text = circle.searchName;
        creator.text = [NSString stringWithFormat:@"Created by %@ %@", owner.firstName, owner.lastName];
        creatorImage.file = owner.profilePicture;
        [creatorImage loadInBackground];
        
        [accept addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"RequestCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Requests *request = (Requests *)object;
        
        Circles *circle = (Circles *)request.circle;
        UserInfo *owner = (UserInfo *)request.requester;
        
        UITextView *name = (UITextView *)[cell viewWithTag:6003];
        UITextView *creator = (UITextView *)[cell viewWithTag:6004];
        PFImageView *creatorImage = (PFImageView *)[cell viewWithTag:6012];
        UIButton *accept = (UIButton *)[cell viewWithTag:6042];
        
        name.text = circle.searchName;
        creator.text = [NSString stringWithFormat:@"Created by %@ %@", owner.firstName, owner.lastName];
        creatorImage.file = owner.profilePicture;
        [creatorImage loadInBackground];
        
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
