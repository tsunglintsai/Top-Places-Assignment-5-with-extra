//
//  PlaceAnnotation.h
//  Top Places
//
//  Created by Daniela on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject<MKAnnotation>
+ (PlaceAnnotation*) annotationForPlace:(NSDictionary*)place; // Flickr photo dictionary
@property (strong,nonatomic) NSDictionary *place;
@end
