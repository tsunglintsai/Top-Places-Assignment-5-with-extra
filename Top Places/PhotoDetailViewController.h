//
//  PhotoDetailViewController.h
//  Top Places
//
//  Created by Henry Tsai on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPlacesPhotoProtocol.h"

@interface PhotoDetailViewController : UIViewController
@property(nonatomic,strong) id<TopPlacesPhotoProtocol> photo;
@property(nonatomic,strong) NSString *photoTitle;
@end
