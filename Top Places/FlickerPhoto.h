//
//  FlickerPhoto.h
//  Top Places
//
//  Created by Henry Tsai on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPlacesPhotoProtocol.h"

@interface FlickerPhoto : NSObject<TopPlacesPhotoProtocol>

@property (strong,nonatomic) NSDictionary* photoData;

+ (FlickerPhoto*)getPhotoFromFlickerPhotoResposneData:(NSDictionary*)photoData;
+ (NSArray*) getPhotoListFromFlickerPhotoListResponseData:(NSDictionary*)photoDataList withLimit:(int) limit;
+ (NSString*) getCityStringFromFlickPlaceString:(NSString*)flickerPlaceString;
+ (NSString*) getRestOfPlaceStringOtherFromFlickPlaceString:(NSString*)flickerPlaceString;
+ (NSString*) getPlaceStringFromFlickerDataEntry:(NSDictionary*)dataEntry;
+ (NSArray*) getFavoritePhotoList;
+ (void) addFavoritPhoto:(NSDictionary*)photo;

@end
