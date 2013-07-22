//
//  RemindersViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "RemindersViewController.h"
#import "MyLoginViewController.h"
#import "MySignUpViewController.h"
#import "FriendsViewController.h"
#import "SettingsViewController.h"
#import "QuartzCore/CALayer.h"
#import "PlaneTabViewController.h"


@interface RemindersViewController ()

@end


@implementation RemindersViewController {
    PFObject *selectedReminderObject;
    NSString *displayName;
    NSString *theUsername;
    UIImage *defaultPic;
    NSString *tempUsername;
    PFObject *meObject;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"mpCenterTabbarItemTapped"
                                               object:nil];
    
    /*BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    if (firstTime) {
        [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
    }*/
    
    self.tableView.rowHeight = 70;
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    [self getUserInfo];
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //self.tableView.backgroundColor = [UIColor alizarinColor];

    //self.tableView.separatorColor = [UIColor blackColor];
    
	// Do any additional setup after loading the view.
}

-(void)getUserInfo {
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"friends"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        meObject = object;
        NSString *username = [object objectForKey:@"user"];
        tempUsername = username;
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[MyLoginViewController alloc] init];
        logInViewController.delegate = self; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        signUpViewController.delegate = self; // Set ourselves as the delegate
        signUpViewController.fields = PFSignUpFieldsUsernameAndPassword
        | PFSignUpFieldsSignUpButton
        | PFSignUpFieldsEmail
        | PFSignUpFieldsDismissButton;
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:nil];
    }
    [self loadObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"mpCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for Reminders!");
        [self performSegueWithIdentifier:@"AddReminder" sender:nil];
    }
}


- (PFQuery *)queryForTable {
    
    
    //PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"UserInfo"];
    //[photosFromCurrentUserQuery whereKeyExists:@"user"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"fromFriend"];
    
                      
    
    [query orderByAscending:@"date"];
    
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    
    
    return query;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];

    }
    

    
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:1000];
    UILabel *reminderText = (UILabel *)[cell viewWithTag:1001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:1002];
    

    
    reminderText.text = [object objectForKey:@"title"];
    detailText.text = [object objectForKey:@"fromUser"];
    
    
    //cell.imageView.image = [UIImage imageNamed:@"buttonAdd"];
    
    PFObject *fromFriend = [object objectForKey:@"fromFriend"];
    
    
    //picImage.image = [UIImage imageNamed:@"buttonAdd"]; // placeholder image
    
    
    picImage.file = (PFFile *)[fromFriend objectForKey:@"profilePicture"]; // remote image
    
    
    
    [picImage loadInBackground];


    
   /*
    NSMutableArray *results = [[NSMutableArray alloc]initWithObjects:fromFriend, nil];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
       dispatch_async(queue, ^{
    for (PFObject *object in results) {
        PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
        UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        picImage.image = fromUserImage;
            
            });
    }
           
    });
    */
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedReminderObject = [self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ReminderDisclosure" sender:selectedReminderObject];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddReminder"]) {
        AddReminderViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    }
    
    else if ([segue.identifier isEqualToString:@"firstTimeSettings"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        firstTimeSettingsViewController *controller = (firstTimeSettingsViewController *)navController.topViewController;
        controller.delegate = self;
        
        
    }
    
    else if ([segue.identifier isEqualToString:@"ReminderDisclosure"]) {
        UINavigationController *nvc = (UINavigationController *)[segue destinationViewController];
        ReminderDisclosureViewController *controller = (ReminderDisclosureViewController *)nvc.topViewController;
        controller.delegate = self;
        controller.reminderObject = sender;
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath]];
//    
//    NSString *myObjectID = [dict objectForKey:@"objectID"];
        
    PFObject *deleteReminder = [self.objects objectAtIndex:indexPath.row];
    NSString *deleteName = [deleteReminder objectForKey:@"fromUser"];
        
        [deleteReminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {

                [self loadObjects];
                NSString *message = [NSString stringWithFormat:@"%@ has deleted your reminder", tempUsername];
                
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:deleteName];
               
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; 
                [push setMessage:message];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                }];
                
            }
        }];
    
    
    
    
}

-(void)registerUserID:(NSString *)objectID {
    NSDictionary *userDict = [[NSDictionary alloc]init];
    [userDict setValue:objectID forKey:@"objectID"];
    [userDict writeToFile:[self dataFilePath] atomically:YES];

}



#pragma mark - LoginViewController Delegates

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in...");
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSString *username = user.username;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser].username forKey:@"user"];
    [currentInstallation saveInBackground];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFriends" object:nil];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfile" object:nil];
    
    
    PFQuery *objectIdQuery = [UserInfo query];
    [objectIdQuery whereKey:@"user" equalTo:username];
    [objectIdQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self registerUserID:[object objectId]];
        [self loadObjects];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    
    
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}



#pragma mark - SignUpViewController Delegates

-(void)addSelfToFriends {
    PFQuery *personQuery = [UserInfo query];
    [personQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [personQuery includeKey:@"friends"];
    
    
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        //Add Self Friend
        
        NSString *objectID = [object objectId];
        PFObject *userFriendObject = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:objectID];
        
        [object addObject:userFriendObject forKey:@"friends"];
        [object saveInBackground];
        [self registerUserID:objectID];
        
    }];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    defaultPic = [UIImage imageNamed:@"first"];
    UserInfo *userObject = [UserInfo object];
    NSData *data = UIImagePNGRepresentation(defaultPic);
    PFFile *imageupload = [PFFile fileWithName:@"myProfilePicture.png" data:data];
    [userObject setObject:displayName forKey:@"user"];
    [userObject setObject:displayName forKey:@"displayName"];
    [userObject setObject:imageupload forKey:@"profilePicture"];
    [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self addSelfToFriends];
    }];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser].username forKey:@"user"];
    
    [currentInstallation saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFriends" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfile" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    NSString *password = [info objectForKey:@"password"];
    NSString *username = [info objectForKey:@"username"];
    displayName = username;
    
    //    NSString *lowercaseUsername = [username lowercaseString];
    //    theUsername = lowercaseUsername;
    
    return (BOOL)(password.length >= 8);
    
}





@end
