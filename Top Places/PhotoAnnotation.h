//
//  PhotoAnnotation.h
//  Top Places
//
//  Created by Daniela on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TopPlacesPhotoProtocol.h"

@interface PhotoAnnotation : NSObject<MKAnnotation>
+ (PhotoAnnotation*) annotationForPhoto:(id<TopPlacesPhotoProtocol>)photo; // Flickr photo dictionary
@property (strong,nonatomic) id<TopPlacesPhotoProtocol> photo;
@end
