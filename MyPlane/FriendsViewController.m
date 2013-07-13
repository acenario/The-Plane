//
//  FriendsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController {
    NSArray *friendsArray;
    NSMutableArray *receievedFriendRequestsArray;
    NSMutableArray *fileArray;
    PFFile *pictureFile;
    UserInfo *currentUserObject;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    [self queryForTable];
	// Do any additional setup after loading the view.
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"fCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for friends!");
        [self performSegueWithIdentifier:@"AddFriend" sender:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryForTable {
    
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [userQuery includeKey:@"friends"];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
        //receievedFriendRequestsArray = [object objectForKey:@"receivedFriendRequests"];
        friendsArray = [object objectForKey:@"friends"];
        [userQuery orderByAscending:@"friend"];
        [self receivedFriendRequestsQuery];
        [self.tableView reloadData];
    }];
    
    if (!pictureFile.isDataAvailable) {
        userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
}

- (void)receivedFriendRequestsQuery
{
    NSArray *array = [[NSArray alloc] initWithObjects:currentUserObject, nil];
    receievedFriendRequestsArray = [NSMutableArray array];
    PFQuery *query = [UserInfo query];
    [query whereKey:@"sentFriendRequests" containsAllObjectsInArray:array];
    [query includeKey:@"receivedFriendsArray"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //NSLog(@"%d", objects.count);
        for (UserInfo *object in objects) {
            [receievedFriendRequestsArray addObject:object];
            NSLog(@"%@", receievedFriendRequestsArray);
        }
        
        NSLog(@"%@", self.navigationItem.rightBarButtonItem.title);
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%d", receievedFriendRequestsArray.count];
        NSLog(@"%@", self.navigationItem.rightBarButtonItem.title);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [friendsArray count];
}

- (void)addFriendViewControllerDidFinishAddingFriends:(AddFriendViewController *)controller
{
    [self queryForTable];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:2000];
    UILabel *contactText = (UILabel *)[cell viewWithTag:2001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:2002];
    
    UserInfo *userObject = [friendsArray objectAtIndex:indexPath.row];
    NSString *username = userObject.user;
    NSString *firstName = userObject.firstName;
    NSString *lastName = userObject.lastName;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFFile *picture = userObject.profilePicture;
        UIImage *fromUserImage = [[UIImage alloc] initWithData:picture.getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            picImage.image = fromUserImage;
            contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            detailText.text = username;
        });
    });
    
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddFriend"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddFriendViewController *controller = (AddFriendViewController *)navController.topViewController;
        controller.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"ReceivedFriendRequests"]) {
        ReceivedFriendRequestsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.receivedFriendRequestsArray = [NSMutableArray arrayWithArray:receievedFriendRequestsArray];
    }
}

@end
