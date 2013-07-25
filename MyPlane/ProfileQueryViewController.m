//
//  ProfileQueryViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ProfileQueryViewController.h"
#import "UserInfo.h"


@interface ProfileQueryViewController ()

@end

@implementation ProfileQueryViewController {
    NSString *firstName;
    NSString *lastName;
    NSString *Username;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = NO;
        self.parseClassName = @"UserInfo";
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    [self configureFlatUI];
    
    self.editButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
}

-(void)configureFlatUI {
    UIFont *myFont = [UIFont flatFontOfSize:16];
    UIColor *myColor = [UIColor colorFromHexCode:@"FF9773"];
    UIColor *unColor = [UIColor colorFromHexCode:@"A62A00"];
    
    
    self.firstNameField.font = myFont;
    self.firstNameField.textColor = myColor;
    
    self.lastNameField.font = myFont;
    self.lastNameField.textColor = myColor;
    
    self.emailField.font = myFont;
    self.emailField.textColor = myColor;
    
    self.usernameField.font = myFont;
    self.usernameField.textColor = unColor;
    
    
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"reloadProfile"]) {
        NSLog (@"Successfully received the reload command!");
        [self loadObjects];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(PFQuery *)queryForTable {
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    
    if (self.objects.count == 0) {
        userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return userQuery;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    if (indexPath.section == 0) {
        static NSString *identifier = @"Cell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        NSLog(@"%@", [object objectForKey:@"user"]);
        
        PFImageView *userImage = (PFImageView *)[cell viewWithTag:5000];
        UILabel *name = (UILabel *)[cell viewWithTag:5001];
        UILabel *username = (UILabel *)[cell viewWithTag:5003];
        
        name.text = [NSString stringWithFormat:@"%@ %@", [object objectForKey:@"firstName"], [object objectForKey:@"lastName"]];
        username.text = [object objectForKey:@"user"];
        userImage.file = [object objectForKey:@"profilePicture"];
        [userImage loadInBackground];
        
        //    PFUser *user = [PFUser currentUser];
        //    self.firstNameField.text = [object objectForKey:@"firstName"];
        //    self.lastNameField.text = [object objectForKey:@"lastName"];
        //    self.usernameField.text = [object objectForKey:@"user"];
        //    self.emailField.text = [user email];
        //    self.profilePicture.file = (PFFile *)[object objectForKey:@"profilePicture"];
        //
        //
        //    [self.profilePicture loadInBackground];
        
        return cell;
        
    } else {
        static NSString *identifier = @"Email";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        return cell;
        
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:5.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    
    
    
    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editInfo"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        EditSettingsViewController *controller = (EditSettingsViewController *)navController.topViewController;
        controller.delegate = self;
        
        controller.firstname = self.firstNameField.text;
        controller.lastname = self.lastNameField.text;
        controller.email = self.emailField.text;
        controller.profilePicture = self.profilePicture.image;
    }
}

- (void)updateUserInfo:(EditSettingsViewController *)controller {
    [self loadObjects];
}

@end
