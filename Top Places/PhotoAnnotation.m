//
//  PhotoAnnotation.m
//  Top Places
//
//  Created by Daniela on 8/1/12.
//
//

#import "PhotoAnnotation.h"

@implementation PhotoAnnotation

+ (PhotoAnnotation*) annotationForPhoto:(id<TopPlacesPhotoProtocol>)photo{
    PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

- (NSString *)title
{
    return self.photo.photoTitle;
}

- (NSString *)subtitle
{
    return self.photo.photoSubTitle;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.photo.coordinate;
}
@end
