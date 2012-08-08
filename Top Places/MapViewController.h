//
//  MapViewController.h
//  Top Places
//
//  Created by Daniela on 7/31/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PhotoDetailViewController.h"

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)mapViewController:(MapViewController *)sender
            imageForAnnotation:(id <MKAnnotation>)annotation;
- (BOOL) mapViewController:(MapViewController *)sender
       samePhotoAnnotation:(id <MKAnnotation>)annotation1
         asPhotoAnnotation:(id <MKAnnotation>)annotation2;
@end

@interface MapViewController : UIViewController
@property (strong,nonatomic) NSArray *annotations;
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;

@end
