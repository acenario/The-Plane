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
    NSMutableArray *fileArray;
    PFFile *pictureFile;
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

    
    PFQuery *userQuery = [PFQuery queryWithClassName:@"UserInfo"];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    
    /*PFQuery *friendQuery = [PFQuery queryWithClassName:@"UserInfo"];
    [friendQuery whereKeyExists:@"friends"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery, friendQuery, nil]];*/
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            friendsArray = [object objectForKey:@"friends"];
            
        }
        [userQuery orderByAscending:@"friend"];
        [self gettingImages];
    }];
    
    
      
    if (!pictureFile.isDataAvailable) {
        
        userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

}

-(void)gettingImages {
    
    
    PFQuery *personQuery = [PFQuery queryWithClassName:@"UserInfo"];
    [personQuery whereKey:@"user" containedIn:friendsArray];
    
        
            [personQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSMutableArray *arrayOfFiles = [[NSMutableArray alloc]init];
                for (PFObject *object in objects) {
                    PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
                    [arrayOfFiles addObject:theImage];
                    pictureFile = theImage;
                    //UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
                    
                }
                fileArray = arrayOfFiles;
                [self.tableView reloadData];
            }];
            
            
        
        

    
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
    
    UIImageView *picImage = (UIImageView *)[cell viewWithTag:2000];
    UILabel *contactText = (UILabel *)[cell viewWithTag:2001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:2002];
    
    NSString *values = [friendsArray objectAtIndex:indexPath.row];
    
    if (pictureFile.isDataAvailable) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            PFFile *picture = [fileArray objectAtIndex:indexPath.row];
            UIImage *fromUserImage = [[UIImage alloc] initWithData:picture.getData];
            dispatch_async(dispatch_get_main_queue(), ^{
            picImage.image = fromUserImage;
                contactText.text = values;
                detailText.text = values;
                 });
        });
        
    } else {
        NSLog(@"NO!");
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddFriend"]) {
        AddFriendViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    }
}

@end
