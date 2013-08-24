//
//  CirclesViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/20/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CirclesViewController.h"

@interface CirclesViewController ()

@property (nonatomic,strong) UzysSlideMenu *uzysSMenu;

@end

@implementation CirclesViewController {
    PFQuery *userQuery;
    UserInfo *userObject;
    BOOL menuCheck;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Find a Circle" image:[UIImage imageNamed:@"a0.png"] action:^(UzysSMMenuItem *item) {
        [self performSegueWithIdentifier:@"JoinCircle" sender:nil];
    }];
    item0.tag = 0;
    
    UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Create a Circle" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
        [self performSegueWithIdentifier:@"CreateCircle" sender:nil];
    }];
    item0.tag = 1;
    
    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item1]];
    [self.view addSubview:self.uzysSMenu];
    
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
        self.requestButton.title = [NSString stringWithFormat:@"%d Requests", userObject.circleRequestsCount];
    }];
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    self.segmentedController.selectedFont = [UIFont boldFlatFontOfSize:16];
    self.segmentedController.selectedFontColor = [UIColor cloudsColor];
    self.segmentedController.deselectedFont = [UIFont flatFontOfSize:16];
    self.segmentedController.deselectedFontColor = [UIColor cloudsColor];
    self.segmentedController.selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedController.deselectedColor = [UIColor colorFromHexCode:@"FF9773"];
    self.segmentedController.dividerColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedController.cornerRadius = 5.0f;

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidAppearInContainer:)
                                                 name:@"showCircles"
                                               object:nil];
    menuCheck = YES;
    self.segmentedController.selectedSegmentIndex = 1;
    self.uzysSMenu.hidden = YES;
    [self loadObjects];
    
}

-(void)viewDidAppearInContainer:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"showCircles"]) {
        self.segmentedController.selectedSegmentIndex = 1;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    PFQuery *query = [Circles query];
    [query whereKey:@"members" matchesQuery:userQuery];
    [query includeKey:@"owner"];
    [query includeKey:@"members"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    Circles *circleObject = (Circles *)object;
    
    cell.textLabel.text = circleObject.displayName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d member(s)", [circleObject.members count]];
    
    return cell;
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
    
    cell.textLabel.font = [UIFont flatFontOfSize:17];
    cell.detailTextLabel.font = [UIFont flatFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    return cell;
}

- (void)joinCircleViewControllerDidFinishAddingFriends:(JoinCircleViewController *)controller
{
    [self loadObjects];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CircleRequests"]) {
        CircleRequestsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.currentUser = userObject;
        controller.circles = self.objects;
    } else if ([segue.identifier isEqualToString:@"CircleDetail"]) {
        CircleDetailViewController *controller = [segue destinationViewController];
        Circles *circle = (Circles *)sender;
        controller.delegate = self;
        controller.circle = circle;
        controller.circles = self.objects;
        controller.currentUser = userObject;
    } else if ([segue.identifier isEqualToString:@"CreateCircle"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        CreateCircleViewController *controller = (CreateCircleViewController *)nav.topViewController;
        controller.delegate = self;
    }
}

- (void)circleRequestsDidFinish:(CircleRequestsViewController *)controller
{
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
        self.requestButton.title = [NSString stringWithFormat:@"%d Requests", userObject.circleRequestsCount];
    }];
    [self loadObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Circles *circle = [self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"CircleDetail" sender:circle];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)circleMenu:(id)sender {
    self.uzysSMenu.hidden = NO;
    if (menuCheck == YES) {
        [self.uzysSMenu toggleMenu];
//        NSLog(@"open");
        menuCheck = NO;
    } else {
        [self.uzysSMenu openIconMenu];
        menuCheck = YES;
//        NSLog(@"close");
        
    }
    
}

- (IBAction)segmentChanged:(id)sender {
    [self.delegate circlesSegmentDidChange:self.segmentedController];
}

- (void)createCircleViewControllerDidFinishCreatingCircle:(CreateCircleViewController *)controller
{
    [self loadObjects];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
