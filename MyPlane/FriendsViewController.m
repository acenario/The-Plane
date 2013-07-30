//
//  FriendsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendsViewController.h"
#import "QuartzCore/CALayer.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController {
    NSArray *friendsArray;
    NSMutableArray *receievedFriendRequestsArray;
    NSMutableArray *fileArray;
    PFFile *pictureFile;
    PFQuery *userQuery;
    PFObject *personObject;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
    //[self queryForTable];
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
    
    else if ([[notification name] isEqualToString:@"reloadFriends"]) {
        NSLog (@"Successfully received the reload command!");
        [self queryForTable];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)queryForTable {
    
    userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [userQuery includeKey:@"friends"];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%d", currentUserObject.receivedFriendRequests.count];
        //SOMETHING NEEDED - ADD A BADGE
        personObject = object;
        friendsArray = [object objectForKey:@"friends"];
        [userQuery orderByAscending:@"friends"];
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



- (void)addFriendViewControllerDidFinishAddingFriends:(AddFriendViewController *)controller
{
    [self queryForTable];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:original];
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:imageView.bounds];
    
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageView.image;
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
    
    
    /*cell.textLabel.backgroundColor = [UIColor clearColor];
     if ([cell respondsToSelector:@selector(detailTextLabel)])
     cell.detailTextLabel.backgroundColor = [UIColor clearColor];
     
     //Guess some good text colors
     cell.textLabel.textColor = selectedColor;
     cell.textLabel.highlightedTextColor = color;
     if ([cell respondsToSelector:@selector(detailTextLabel)]) {
     cell.detailTextLabel.textColor = selectedColor;
     cell.detailTextLabel.highlightedTextColor = color;
     }*/
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        //cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    
    //SOMETHING NEEDED - CONVERT TO PFFILE
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reQueryForTableWithIndexPath:(NSIndexPath *)indexPath {
    
    userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [userQuery includeKey:@"friends"];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        personObject = object;
        friendsArray = [object objectForKey:@"friends"];
        [userQuery orderByAscending:@"friend"];
        
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        indexPaths = [NSArray arrayWithObject:indexPath];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadData];
        
        
    }];
    
    
    if (!pictureFile.isDataAvailable) {
        userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserInfo *friendRemoved = [friendsArray objectAtIndex:indexPath.row];
    
    NSString *friendRemovedName = friendRemoved.user;
    NSString *userName = [personObject objectForKey:@"user"];
    
    if (![friendRemovedName isEqualToString:userName]) {
    
    [personObject removeObject:friendRemoved forKey:@"friends"];
    [friendRemoved removeObject:personObject forKey:@"friends"];
        
    [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [friendRemoved saveInBackground];
        [self reQueryForTableWithIndexPath:indexPath];
        
    }];
    
    } else {
        NSLog(@"CANT DELETE SELF");
    }
    
}
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddFriend"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddFriendViewController *controller = (AddFriendViewController *)navController.topViewController;
        controller.delegate = self;
    }
}

- (void)receivedFriendRequests:(ReceivedFriendRequestsViewController *)controller
{
    [self.tableView reloadData];
}

@end
