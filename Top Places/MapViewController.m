//
//  MapViewController.m
//  Top Places
//
//  Created by Daniela on 7/31/12.
//
//

#import "MapViewController.h"
#import "PhotoAnnotation.h"
#import "PlaceAnnotation.h"
#include <stdlib.h>

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL isRegionSet;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize isRegionSet = _isRegionSet;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self updateMapView];
    self.navigationItem.hidesBackButton = YES;
    
}
- (IBAction)segementChange:(id)sender {
    UISegmentedControl *segement = sender;
    switch (segement.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
 
}
- (IBAction)listButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];//for iphone
    [self.navigationController popViewControllerAnimated:NO];// for ipad
}

- (void)updateMapView
{
    NSLog(@"updateMapView");
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void)updateMapRegion{
    if([self.annotations count]>0){
        // set region
        float maxLatitude = INT16_MIN;
        float minLatitude = INT16_MAX;
        float maxLongitude = INT16_MIN;
        float minLongitude = INT16_MAX;
        float padding = 0.01;
        for(id<MKAnnotation> annotation in self.annotations){
            maxLatitude = fmax(maxLatitude, annotation.coordinate.latitude);
            minLatitude = fmin(minLatitude, annotation.coordinate.latitude);
            maxLongitude = fmax(maxLongitude, annotation.coordinate.longitude);
            minLongitude = fmin(minLongitude, annotation.coordinate.longitude);
        }
        [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake((maxLatitude+minLatitude)/2, (maxLongitude+minLongitude)/2),
                                                       MKCoordinateSpanMake(maxLatitude-minLatitude+padding, maxLongitude-minLongitude+padding)) animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.isRegionSet){
        [self updateMapRegion];
        self.isRegionSet = YES;
    }
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        // could put a rightCalloutAccessoryView here
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.annotation = annotation;
        [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    }
    return aView;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    id<MKAnnotation> originalAnnotation = aView.annotation;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:arc4random() % 4]];
        dispatch_async(dispatch_get_main_queue(), ^{
            id<MKAnnotation> currentAnnotation = aView.annotation;
            if(image != nil && [self.delegate mapViewController:self samePhotoAnnotation:originalAnnotation asPhotoAnnotation:currentAnnotation ]){
                aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
            }
        });
    });
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end
