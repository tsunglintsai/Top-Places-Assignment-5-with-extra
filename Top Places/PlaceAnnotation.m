//
//  PlaceAnnotation.m
//  Top Places
//
//  Created by Daniela on 8/1/12.
//
//

#import "PlaceAnnotation.h"
#import "FlickrFetcher.h"
#import "FlickerPhoto.h"

@implementation PlaceAnnotation
@synthesize place = _place;


+ (PlaceAnnotation*) annotationForPlace:(NSDictionary*)place{
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

- (NSString *)title
{
    NSString *locationString = [[FlickerPhoto class]getPlaceStringFromFlickerDataEntry:self.place];
    NSString *cityString = [[FlickerPhoto class]getCityStringFromFlickPlaceString:locationString];
    return cityString;
;
}

- (NSString *)subtitle
{
    NSString *locationString = [[FlickerPhoto class]getPlaceStringFromFlickerDataEntry:self.place];
    NSString *restStringOtherThanCity = [[FlickerPhoto class]getRestOfPlaceStringOtherFromFlickPlaceString:locationString];
    return restStringOtherThanCity;
;
}

- (CLLocationCoordinate2D)coordinate
{
   
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake([[self.place valueForKey:FLICKR_LATITUDE] floatValue], [[self.place valueForKey:FLICKR_LONGITUDE] floatValue]);
    return result;
}
@end
