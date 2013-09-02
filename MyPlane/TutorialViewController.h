//
//  TutorialViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController <UIScrollViewDelegate> {
    
    BOOL pageControlBeingUsed;
    
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageViewController;

@end
