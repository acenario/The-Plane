//
//  FriendsForRemindersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/9/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendsForRemindersViewController.h"

@interface FriendsForRemindersViewController ()

@end

@implementation FriendsForRemindersViewController {
    NSMutableArray *friendsArray;
    NSMutableArray *selectedFriends;
    NSMutableArray *selectedFriendsUsernames;
    PFFile *pictureFile;
    UserInfo *currentUser;
    BOOL batchMode;
    BOOL toolbarNames;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden:YES];
//    [self.navigationController toolbar].backgroundColor = ;
    
    [self configureViewController];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(receiveAddNotification:)
//                                                 name:@"fCenterTabbarItemTapped"
//                                               object:nil];
    toolbarNames = YES;
    batchMode = NO;
    selectedFriends = [[NSMutableArray alloc] init];
    selectedFriendsUsernames = [[NSMutableArray alloc] init];
    
    [self queryForTable];
	// Do any additional setup after loading the view.
}

- (void)hold:(UIGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint pressPoint = [longPress locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pressPoint];
        if (!batchMode) {
            batchMode = YES;
            
            
            UserInfo *userObject = [friendsArray objectAtIndex:indexPath.row];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UIImageView *check = (UIImageView *)[cell viewWithTag:888];
            
            [selectedFriends addObject:userObject];
            [selectedFriendsUsernames addObject:userObject.user];
            
            [self.navigationController setToolbarHidden:NO];
            [[self.navigationController toolbar] setBarTintColor:[UIColor colorFromHexCode:@"FF4100"]];
            
//            [self configureToolbar];
            
            [self.tableView reloadData];
            check.hidden = NO;
        }
        
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)configureToolbar
{
    if (!toolbarNames) {
        NSMutableString *friends = [NSMutableString stringWithString:@""];
        
        for (NSString *name in selectedFriendsUsernames) {
            [friends appendString:[NSString stringWithFormat:@", %@", name]];
        }
        
        if (friends.length > 0) {
            [friends replaceCharactersInRange:NSMakeRange(0,1) withString:@""];
        }
        
        if (friends.length > 30) {
            [friends replaceCharactersInRange:NSMakeRange(30, friends.length - 30) withString:@"..."];
        }
        
        [self.toolbarLabel setTitle:[NSString stringWithFormat:@"%@", friends]];
        
    } else {
        if (selectedFriends.count == 1) {
            [self.toolbarLabel setTitle:[NSString stringWithFormat:@"%d friend", selectedFriends.count]];
        } else {
            [self.toolbarLabel setTitle:[NSString stringWithFormat:@"%d friends", selectedFriends.count]];
        }
    }
    self.doneButton.enabled = ((selectedFriends.count) > 0);
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    self.tableView.rowHeight = 70;
    self.doneButton.tintColor = [UIColor whiteColor];
    
    self.toolbarLabel.enabled = YES;

    self.toolbarLabel.tintColor = [UIColor blackColor];
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
    userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUser = (UserInfo *)object;
        friendsArray = [[NSMutableArray alloc] initWithArray:currentUser.friends];
        [userQuery orderByAscending:@"friend"];
        [self.tableView reloadData];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hold:)];
    
    if (!batchMode) {
        [cell.contentView addGestureRecognizer:gestureRecognizer];
    } else {
        while (cell.contentView.gestureRecognizers.count) {
            [cell.contentView removeGestureRecognizer:[cell.contentView.gestureRecognizers objectAtIndex:0]];
        }
    }
    
    
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:1111];
    UILabel *contactText = (UILabel *)[cell viewWithTag:1101];
    UILabel *detailText = (UILabel *)[cell viewWithTag:1102];
    UIImageView *check = (UIImageView *)[cell viewWithTag:888];
    
    
    UIImageView *checkbox = (UIImageView *)[cell viewWithTag:999];
    checkbox.hidden = !batchMode;
    
    UserInfo *userObject = [friendsArray objectAtIndex:indexPath.row];
    NSString *username = userObject.user;
    NSString *firstName = userObject.firstName;
    NSString *lastName = userObject.lastName;
    picImage.file = userObject.profilePicture;
    contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    detailText.text = username;
    
    check.hidden = ![selectedFriendsUsernames containsObject:userObject.user];
    
    [picImage loadInBackground];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1101];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:1102];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UserInfo *userObject = [friendsArray objectAtIndex:indexPath.row];
    
    UserInfo *recipient = [friendsArray objectAtIndex:indexPath.row];
    
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *checkbox = (UIImageView *)[cell viewWithTag:888];
    
    if (!batchMode) {
        [self.delegate friendsForReminders:self friend:recipient currentUser:currentUser
         ];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        
        if ([checkbox isHidden]) {
            [selectedFriends addObject:recipient];
            [selectedFriendsUsernames addObject:recipient.user];
        } else {
            [selectedFriends removeObject:recipient];
            [selectedFriendsUsernames removeObjectIdenticalTo:recipient.user];
        }
        [self configureToolbar];
        checkbox.hidden = !checkbox.hidden;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    if (selectedFriends.count == 1) {
        [self.delegate friendsForReminders:self friend:[selectedFriends objectAtIndex:0] currentUser:currentUser];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate friendsForReminders:self didFinishSelectingFriends:selectedFriends currentUser:currentUser];
        }];
    }

}


- (IBAction)toolbarLabelSwitch:(id)sender {
    toolbarNames = !toolbarNames;
    [self configureToolbar];
}

@end
