//
//  PlaceMapViewController.h
//  Top Places
//
//  Created by Daniela on 8/2/12.
//
//

#import "MapViewController.h"
#import "PhotoListViewController.h"

@protocol PlaceMapViewControllerDelegate <MapViewControllerDelegate>

- (void)mapViewController:(MapViewController *)sender
configPhotoListViewController:(PhotoListViewController*) photoListViewController
               withAnnotation:(id <MKAnnotation>)annotation;

@end


@interface PlaceMapViewController : MapViewController
@property (nonatomic, weak) id <PlaceMapViewControllerDelegate> delegate;

@end
