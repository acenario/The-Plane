//
//  FriendsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReceivedFriendRequestsViewController.h"
#import "FriendsQueryViewController.h"

@interface ReceivedFriendRequestsViewController ()

@end

@implementation ReceivedFriendRequestsViewController {
    NSArray *friendsArray;
    NSMutableArray *receievedFriendRequestsArray;
    NSMutableArray *fileArray;
    PFFile *pictureFile;
    UserInfo *currentUserObject;
    NSMutableArray *friendsObjectId;
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
    
    //CUSTOMIZE
    self.tableView.rowHeight = 70;
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
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

-(void)getIDs {
    
    friendsObjectId = [[NSMutableArray alloc]init];
    
    for (UserInfo *object in currentUserObject.receivedFriendRequests) {
        [friendsObjectId addObject:[object objectId]];
    }
}

- (void)queryForTable {
    
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [userQuery includeKey:@"receivedFriendRequests"];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
        //receievedFriendRequestsArray = [object objectForKey:@"receivedFriendRequests"];
        friendsArray = currentUserObject.receivedFriendRequests;
        [userQuery orderByAscending:@"receivedFriendRequests"];
        [self.tableView reloadData];
        [self getIDs];
    }];
    
    if (!pictureFile.isDataAvailable) {
        userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [friendsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:2211];
    UILabel *contactText = (UILabel *)[cell viewWithTag:2201];
    UILabel *detailText = (UILabel *)[cell viewWithTag:2202];
    UIButton *addButton = (UIButton *)[cell viewWithTag:2221];
    
    UserInfo *userObject = [friendsArray objectAtIndex:indexPath.row];
    NSString *username = userObject.user;
    NSString *firstName = userObject.firstName;
    NSString *lastName = userObject.lastName;
    
    if ([friendsObjectId containsObject:[friendsArray objectAtIndex:indexPath.row]]) {
        addButton.enabled = NO;
    }
    
    [addButton addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (IBAction)adjustButtonState:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    UserInfo *friendAdded = [friendsArray objectAtIndex:clickedButtonPath.row];
    
    NSString *friendObjectID = friendAdded.objectId;
    NSString *userID = currentUserObject.objectId;
    
    UserInfo *friendToAdd = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:friendObjectID];
    UserInfo *userObjectID = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:userID];
    
    [friendsObjectId addObject:friendAdded.objectId];
    //[currentUserObject addObject:friendAdded forKey:@"friends"];
    [currentUserObject addObject:friendToAdd forKey:@"friends"];
    //[currentUserObject removeObject:friendAdded forKey:@"receivedFriendRequests"];
    [currentUserObject removeObject:friendToAdd forKey:@"receivedFriendRequests"];
    [currentUserObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [friendAdded addObject:userObjectID forKey:@"friends"];
        [friendAdded removeObject:userObjectID forKey:@"sentFriendRequests"];
        //[friendAdded addObject:currentUserObject forKey:@"friends"];
        //[friendAdded removeObject:currentUserObject forKey:@"sentFriendRequests"];
        [friendAdded saveInBackground];
        [self.tableView reloadData];
        [self.delegate receivedFriendRequests:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"increaseFriend" object:nil];
        

    }];
    
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.enabled = NO;
    
    
}




@end
