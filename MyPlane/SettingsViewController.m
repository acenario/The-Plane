//
//  SettingsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserInfo.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    NSString *firstName;
    NSString *lastName;
    NSString *Username;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    [self getUserInfo];
    
    /*self.infoCell = [UITableViewCell configureFlatCellWithColor:[UIColor greenSeaColor]
                                         selectedColor:[UIColor cloudsColor]
                                                 style:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Cell"];
    
    self.infoCell.cornerRadius = 5.0f;

    self.infoCell.separatorHeight = 2.0f; // optional*/
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadProfile"
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
        [self getUserInfo];
    }
}


-(void)getUserInfo {
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        [self updateLabelsForObject:object];
        
        
    }];
    
    userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
}

-(void)updateLabelsForObject:(PFObject *)object {
    PFUser *user = [PFUser currentUser];
    self.firstNameField.text = [NSString stringWithFormat:@"%@ %@", [object objectForKey:@"firstName"], [object objectForKey:@"lastName"]];
    self.usernameField.text = [object objectForKey:@"user"];
    self.emailField.text = [user email];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFFile *pictureFile = [object objectForKey:@"profilePicture"];
        UIImage *fromUserImage = [[UIImage alloc] initWithData:pictureFile.getData];
        //UIImage *roundedImage = [self imageWithRoundedCornersSize:5.0f usingImage:fromUserImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePicture.image = fromUserImage;
            self.editButton.enabled = YES;

        });
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUserInfo:(EditSettingsViewController *)controller {
    [self getUserInfo];
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






@end
