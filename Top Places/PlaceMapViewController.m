//
//  PlaceMapViewController.m
//  Top Places
//
//  Created by Daniela on 8/2/12.
//
//

#import "PlaceMapViewController.h"
#import "MapViewController.h"

@interface PlaceMapViewController ()

@end

@implementation PlaceMapViewController

@synthesize delegate = _delegate;

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"PushToPhotoListFromMapSegue" sender:view.annotation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:[UISplitViewController class]]){ // ipad code
        UISplitViewController *splitViewController = segue.destinationViewController;
        [self.delegate mapViewController:self configPhotoListViewController:[splitViewController.viewControllers lastObject] withAnnotation:sender];
    }else{ // iphone code
        PhotoListViewController *photoListViewController = segue.destinationViewController;
        [self.delegate mapViewController:self configPhotoListViewController:photoListViewController withAnnotation:sender];
    }
}
@end
