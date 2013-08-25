//
//  CurrentUser.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface CurrentUser : NSObject {
    UserInfo *currentUser;
}

@property (nonatomic, retain) UserInfo *currentUser;

+ (id)sharedManager;

@end
