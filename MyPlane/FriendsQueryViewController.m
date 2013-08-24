//
//  FriendsQueryViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/17/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendsQueryViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface FriendsQueryViewController ()

@end

@implementation FriendsQueryViewController {
    UserInfo *meObject;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:
            @"UserProfile.plist"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    
    [self getUserInfo];

	// Do any additional setup after loading the view.
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    self.tableView.rowHeight = 70;
    
    self.segmentedController.selectedFont = [UIFont boldFlatFontOfSize:16];
    self.segmentedController.selectedFontColor = [UIColor cloudsColor];
    self.segmentedController.deselectedFont = [UIFont flatFontOfSize:16];
    self.segmentedController.deselectedFontColor = [UIColor cloudsColor];
    self.segmentedController.selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedController.deselectedColor = [UIColor colorFromHexCode:@"FF9773"];
    self.segmentedController.dividerColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedController.cornerRadius = 5.0f;
}

-(void)getUserInfo {
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"friends"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        meObject = (UserInfo *)object;
    }];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"increaseFriend"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidAppearInContainer:)
                                                 name:@"showFriends"
                                               object:nil];
    self.segmentedController.selectedSegmentIndex = 0;
    [self loadObjects];
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"reloadFriends"]) {
        [self loadObjects];
    }
    
    else if ([[notification name] isEqualToString:@"increaseFriend"]) {
        [self checkFriendRequests];
    }
}

-(void)viewDidAppearInContainer:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"showFriends"]) {
        self.segmentedController.selectedSegmentIndex = 0;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    

    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"friends"];
    
    
    PFQuery *friendQuery = [UserInfo query];
    [friendQuery whereKey:@"friends" matchesQuery:query];
        
    /*NSSortDescriptor * firstNameDescriptor = [[NSSortDescriptor alloc]
                                              initWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[firstNameDescriptor];
    [friendQuery orderBySortDescriptors:sortDescriptors];*/
    [friendQuery orderByAscending:@"firstName"];

    
    if (self.objects.count == 0) {
        friendQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    return friendQuery;    
    
}

-(void)checkFriendRequests {
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSArray *array = [object objectForKey:@"receivedFriendRequests"];
        int count = array.count;
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%d Pending", count];
    }];
}

- (void)addFriendViewControllerDidFinishAddingFriends:(AddFriendViewController *)controller
{
    [self loadObjects];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView *av = [[UIImageView alloc] init];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:2002];

    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    nameLabel.font = [UIFont flatFontOfSize:17];
    usernameLabel.font = [UIFont flatFontOfSize:15];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
    }
    
    
    
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:2000];
    UILabel *contactText = (UILabel *)[cell viewWithTag:2001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:2002];
    
    PFFile *pictureFile = [object objectForKey:@"profilePicture"];
    NSString *username = [object objectForKey:@"user"];
    NSString *firstName = [object objectForKey:@"firstName"];
    NSString *lastName = [object objectForKey:@"lastName"];
    
    picImage.file = pictureFile;
    contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    detailText.text = username;
    
    [picImage loadInBackground];
    
    /*dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
        UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            picImage.file = pictureFile;
            contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            detailText.text = username;
        });
        
        
    });*/
    

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"AddReminder" sender:[self.objects objectAtIndex:indexPath.row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    PFObject *friendRemoved = [self.objects objectAtIndex:indexPath.row];
    PFObject *friendRemovedData = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:[friendRemoved objectId]];
    PFUser *user = [PFUser currentUser];
    NSString *username = user.username;
    NSString *friendRemoveName = [friendRemoved objectForKey:@"user"];
    
    if (![friendRemoveName isEqualToString:username]) {
        NSLog(@"friendRemove: %@", [friendRemoved objectForKey:@"user"]);
    
        [friendRemoved removeObject:meObject forKey:@"friends"];
        [friendRemoved saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            
            [meObject removeObject:friendRemovedData forKey:@"friends"];
            [meObject saveInBackground];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            indexPaths = [NSArray arrayWithObject:indexPath];
            [self loadObjects];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];

            
            /*[CATransaction begin];
            
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self loadObjects];
            [self.tableView endUpdates];
            
            //[self loadObjects];
            
            [CATransaction setCompletionBlock:^{
                
                //[self loadObjects];
                
            }];
            
            [CATransaction commit];*/
            
            
            //[self loadObjects];
            
            
        }];
        
    } else {
        NSLog(@"CANT DELETE SELF!");
    }
    
    
    
    
    
    
    
    
    /*NSString *friendRemovedName = friendRemoved.user;
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
    }*/
    
}
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddFriend"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddFriendViewController *controller = (AddFriendViewController *)navController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ReceivedFriendRequests"]){
        ReceivedFriendRequestsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"AddReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddReminderViewController *controller = (AddReminderViewController *)nav.topViewController;
        controller.recipient = sender;
        controller.currentUser = meObject;
    }
}


- (void)receivedFriendRequests:(ReceivedFriendRequestsViewController *)controller
{
    NSLog(@"is this even being called?");
    //[self loadObjects];
    //[self checkFriendRequests];
    
}

- (IBAction)addFriend:(id)sender {
    [self performSegueWithIdentifier:@"AddFriend" sender:nil];
}

- (IBAction)segmentChanged:(id)sender {
    [self.delegate friendsSegmentChanged:self.segmentedController];
}


@end
