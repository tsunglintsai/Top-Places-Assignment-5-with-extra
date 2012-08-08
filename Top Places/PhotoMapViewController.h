//
//  PhotoMapViewController.h
//  Top Places
//
//  Created by Daniela on 8/2/12.
//
//

#import "MapViewController.h"

@protocol PhotoMapViewControllerDelegate <MapViewControllerDelegate>

- (id<TopPlacesPhotoProtocol>)mapViewController:(MapViewController *)sender
                             photoForAnnotation:(id <MKAnnotation>)annotation;

@end

@interface PhotoMapViewController : MapViewController
@property (nonatomic, weak) id <PhotoMapViewControllerDelegate> delegate;

@end
