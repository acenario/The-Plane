//
//  TutorialViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    pageControlBeingUsed = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 30)];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.scrollView];
    
    NSArray *picturesArray = [[NSArray alloc] initWithObjects:@"1.png", @"1.png", @"1.png", @"1.png", @"1.png", @"1.png", @"1.png", @"1.png", @"1.png", @"1.png", nil];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * picturesArray.count, self.scrollView.frame.size.height);
    
    for (int i = 1; i <= picturesArray.count; i++) {
        UIImage *image = [UIImage imageNamed:[picturesArray objectAtIndex:i - 1]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        CGRect frame;
        
        frame.origin.x = self.scrollView.frame.size.width * (i - 1);
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        imgView.frame = CGRectMake((self.scrollView.frame.size.width * (i - 1)), 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
//        [subview addSubview:imgView];
        
        if (i == picturesArray.count) {
            CGRect buttonFrame;
            
            buttonFrame.origin.x = (frame.size.width / 2) - 50;
            buttonFrame.origin.y = (frame.size.height / 2) - 25;
            buttonFrame.size.width = 100;
            buttonFrame.size.height = 50;
            UIButton *subviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            subviewButton.frame = buttonFrame;
            [subviewButton setTitle:@"Button" forState:UIControlStateNormal];
            [subviewButton setTag:i+1];
            [subviewButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [subview addSubview:subviewButton];
        }
        
        [self.scrollView addSubview:imgView];
        [self.scrollView addSubview:subview];
    }
    
    self.pageViewController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30)];
    self.pageViewController.numberOfPages = picturesArray.count;
    self.pageViewController.currentPage = 0;
    self.pageViewController.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.pageViewController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageViewController];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    float roundedValue = round(scrollView.contentOffset.x / 320);
    if (!pageControlBeingUsed) {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageViewController.currentPage = page;
    }
}

- (void)changePage:(id)sender
{
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageViewController.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlBeingUsed = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)buttonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
