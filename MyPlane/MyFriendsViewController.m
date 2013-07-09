//
//  MyFriendsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/9/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "MyFriendsViewController.h"

@interface MyFriendsViewController ()

@end

@implementation MyFriendsViewController {
    NSArray *friendsArray;
    NSMutableArray *fileArray;
    PFFile *pictureFile;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.parseClassName = @"UserInfo";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self userQueryForTable];
	// Do any additional setup after loading the view.
}

- (void)userQueryForTable {
    
    
    PFQuery *userQuery = [PFQuery queryWithClassName:self.parseClassName];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    
    /*PFQuery *friendQuery = [PFQuery queryWithClassName:@"UserInfo"];
     [friendQuery whereKeyExists:@"friends"];
     
     PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery, friendQuery, nil]];*/
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            friendsArray = [object objectForKey:@"friends"];
            
            
        }
        
        [self queryForTable];
    }];
    
    
    
    
    
}

-(PFQuery *)queryForTable {
    PFQuery *personQuery = [PFQuery queryWithClassName:self.parseClassName];
    [personQuery whereKey:@"user" containedIn:friendsArray];
    
    [personQuery orderByAscending:@"date"];
    
    
    if (self.objects.count == 0) {
        personQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [self loadObjects];
    
    return personQuery;
}

-(void)gettingImages {
    
    
    PFQuery *personQuery = [PFQuery queryWithClassName:self.parseClassName];
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
        [self loadObjects];
    }];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (friendsArray.count < 1) {
        return 0;
    } else {
        return friendsArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object  {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    UIImageView *picImage = (UIImageView *)[cell viewWithTag:2000];
    UILabel *contactText = (UILabel *)[cell viewWithTag:2001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:2002];
    
    NSString *values = [friendsArray objectAtIndex:indexPath.row];
    PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
    NSMutableArray *results = [[NSMutableArray alloc]initWithObjects:theImage, nil];

    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            for (PFFile *file in results) {
                UIImage *fromUserImage = [[UIImage alloc] initWithData:file.getData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    picImage.image = fromUserImage;
                    contactText.text = values;
                    detailText.text = values;
                    
                    
                    
                });
            }
            
                
        });
        
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
