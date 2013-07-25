//
//  JoinCircle.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "JoinCircleViewController.h"

@interface JoinCircleViewController ()

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation JoinCircleViewController {
    NSMutableArray *circlesArray;
    NSMutableArray *searchResults;
    PFQuery *currentUserQuery;
    PFQuery *circleQuery;
    UserInfo *userObject;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.parseClassName = @"Circles";
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
    
    [self currentUserQuery];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)currentUserQuery
{
    currentUserQuery = [UserInfo query];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];    
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            userObject = object;
        }
    }];
}

- (void)filterResults:(NSString *)searchTerm
{
    NSString *newTerm = [searchTerm lowercaseString];
//    NSLog(@"%@", newTerm);
    circleQuery = [Circles query];
    [circleQuery whereKey:@"name" containsString:newTerm];
    [circleQuery whereKey:@"public" equalTo:[NSNumber numberWithBool:YES]];
//    [circleQuery includeKey:@"members"];
    
    if (self.objects.count == 0) {
        circleQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:[circleQuery findObjects]];

        [self loadObjects];
    });
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterResults:searchBar.text];
    [searchBar resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"Rows upon NumberofRowsInSections %d", self.searchResults.count);
    return searchResults.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    
    if (searchResults.count > 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:6101];
        UILabel *memebersLabel = (UILabel *)[cell viewWithTag:6102];
        UIButton *addButton = (UIButton *)[cell viewWithTag:6131];
        addButton.hidden = YES;
        
        Circles *searchedCircle = [searchResults objectAtIndex:indexPath.row];
        name.text = searchedCircle.searchName;
        memebersLabel.text = [NSString stringWithFormat:@"%d members", searchedCircle.members.count];
        
        
//        NSLog(@"%@", [UserInfo objectWithoutDataWithObjectId:userObject.objectId]);
        
//        NSLog(@"%@", searchedCircle.members);
        
        if ([searchedCircle.members containsObject:[UserInfo objectWithoutDataWithObjectId:userObject.objectId]]) {
            NSLog(@"YES");
        }
        
        
        [addButton addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)adjustButtonState:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    Circles *circle = [searchResults objectAtIndex:clickedButtonPath.row];
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.hidden = NO;
    
    [circle addObject:userObject forKey:@"members"];
    
    if ([circle.pendingMembers containsObject:[UserInfo objectWithoutDataWithObjectId:userObject.objectId]]) {
        [circle removeObject:[UserInfo objectWithoutDataWithObjectId:userObject.objectId] forKey:@"pendingMembers"];
        [userObject removeObject:[Circles objectWithoutDataWithObjectId:circle.objectId] forKey:@"circleRequests"];
    }
    [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self loadObjects];
        }];
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate joinCircleViewControllerDidFinishAddingFriends:self];
}

@end
