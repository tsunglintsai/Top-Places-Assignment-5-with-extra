//
//  PhotoMapViewController.m
//  Top Places
//
//  Created by Daniela on 8/2/12.
//
//

#import "PhotoMapViewController.h"

@interface PhotoMapViewController ()

@end

@implementation PhotoMapViewController
@synthesize delegate = _delegate;

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id viewController = [self.splitViewController.viewControllers lastObject];
    if(viewController==nil){ // iphone code
        [self performSegueWithIdentifier:@"PushToPhotoDetailFromMapSegue" sender:view.annotation];
    }else{
        NSLog(@"test2");
        PhotoDetailViewController *photoDetailViewController = viewController;
        id<TopPlacesPhotoProtocol> selectedPhoto = [self.delegate mapViewController:self photoForAnnotation:view.annotation];
        photoDetailViewController.photo = selectedPhoto;
        photoDetailViewController.photoTitle = selectedPhoto.photoTitle;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id viewController = [self.splitViewController.viewControllers lastObject];
    if(viewController==nil){ // iphone code
        PhotoDetailViewController *photoDetailViewController = segue.destinationViewController;
        id<TopPlacesPhotoProtocol> selectedPhoto = [self.delegate mapViewController:self photoForAnnotation:sender];
        photoDetailViewController.photo = selectedPhoto;
        photoDetailViewController.photoTitle = selectedPhoto.photoTitle;
    }
}

@end
