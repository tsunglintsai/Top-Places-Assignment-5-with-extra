//
//  PhotoListViewController.m
//  Top Places
//
//  Created by Henry Tsai on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoListViewController.h"
#import "FlickrFetcher.h"
#import "PhotoDetailViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "PhotoCell.h"
#import "PhotoMapViewController.h"
#import "PhotoAnnotation.h"
#import <MapKit/MapKit.h>

@interface PhotoListViewController ()<UISplitViewControllerDelegate,UITableViewDelegate,PhotoMapViewControllerDelegate>

@property(strong,nonatomic) UIImage *loadingImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property(strong,nonatomic) UIBarButtonItem *barButtonItem;

@end

@implementation PhotoListViewController
@synthesize photoList = _photoList;
@synthesize listTitle = _listTitle;
@synthesize delegate = _delegate;
@synthesize loadingImage = _loadingImage;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize isShowBusyIndicator = _isShowBusyIndicator;
@synthesize barButtonItem = _barButtonItem;

- (void) viewDidLoad{
    [super viewDidLoad];
    self.barButtonItem = self.navigationItem.leftBarButtonItem;
}

- (void) setIsShowBusyIndicator:(BOOL)isShowBusyIndicator{
    _isShowBusyIndicator = isShowBusyIndicator;
    if(_isShowBusyIndicator){
        [self showBusyIndicator];
    }else{
        [self hideBusyIndicator];
    }
}

- (UIActivityIndicatorView*) activityIndicatorView{
    if(_activityIndicatorView == nil){
        _activityIndicatorView =
        [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

- (void)mapButtonClicked{
    [self performSegueWithIdentifier:@"PushToPhotoMapView" sender:self];
}

- (void)showBusyIndicator{
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    self.navigationItem.rightBarButtonItem =  barButton;
    [self.activityIndicatorView startAnimating];
}

- (void)hideBusyIndicator{
    self.navigationItem.rightBarButtonItem = nil;
    [self.activityIndicatorView stopAnimating];

    UIBarButtonItem * barButton = [[UIBarButtonItem alloc]initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(mapButtonClicked)];
    self.navigationItem.rightBarButtonItem =  barButton;
}

-(UIImage *) loadingImage{
    if(_loadingImage==nil){
        _loadingImage = [UIImage imageNamed:@"loading.jpg"];
    }
    return _loadingImage;
}

-(NSArray*) photoList{
    return [_photoList mutableCopy];
}

- (void) setPhotoList:(NSArray *)photoList{
    _photoList = [photoList mutableCopy];
    [self.tableView reloadData];
    [self hideBusyIndicator];
}

- (void)endUpdates{
    NSLog(@"endUpdates");
}

- (void)viewWillAppear:(BOOL)animated{
    //NSLog(@"viewWillAppear:%@",self.listTitle);
    self.navigationItem.title = self.listTitle;
    if(_isShowBusyIndicator){
        [self showBusyIndicator];
    }else{
        [self hideBusyIndicator];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photoList count];
}

- (void) fillInPhotoCellFromPhoto: (PhotoCell*) photoCell
                       withPhoto : (id<TopPlacesPhotoProtocol>) photo {
    photoCell.imageView.image = self.loadingImage;
    photoCell.textLabel.text = photo.photoTitle;
    photoCell.detailTextLabel.text = photo.photoSubTitle;
    photoCell.photoId = photo.photoId;
    if(photoCell.detailTextLabel.text == nil){
        photoCell.detailTextLabel.text = @"  ";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    id<TopPlacesPhotoProtocol> photo = [self.photoList objectAtIndex:indexPath.row];
    [self fillInPhotoCellFromPhoto:cell withPhoto:photo];   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = photo.smallImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            if([cell.photoId isEqual:photo.photoId]){ // prevent overrwrite reuse cell
                cell.imageView.image = image;
            }
        });
    });
    return cell;
}

- (void)configurePhotoDetailViewController: (PhotoDetailViewController*)photoDetailViewController
                                 withPhoto:(id<TopPlacesPhotoProtocol>)photo{
    photo.largeImage = nil; // force release image memory
    photoDetailViewController.photo = photo;
    photoDetailViewController.photoTitle = photo.photoTitle;
    [self.delegate photoSelected:photo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToPhotoDetailSegue"]) {
        id viewController = [self.splitViewController.viewControllers lastObject];
        if(viewController==nil){ // iphone code
            PhotoDetailViewController *photoDetailViewController = segue.destinationViewController;
            [self configurePhotoDetailViewController:photoDetailViewController withPhoto:[self.photoList objectAtIndex:[self.tableView indexPathForCell:sender].row]];
        }
    }else if ([segue.identifier isEqualToString:@"PushToPhotoMapView"]) {
        
        MapViewController *mapViewController;
        if(self.splitViewController == nil){ // iphone
            UINavigationController *navigationController = segue.destinationViewController;
            mapViewController = (MapViewController*) navigationController.visibleViewController;
        }else{
            mapViewController = segue.destinationViewController;
        }
        
        NSMutableArray *annotations = [[NSMutableArray alloc]initWithCapacity:[self.photoList count]];
        for( id<TopPlacesPhotoProtocol> photo in self.photoList){
            [annotations addObject:[PhotoAnnotation annotationForPhoto:photo]];
        }
        mapViewController.annotations = annotations;
        mapViewController.delegate = self;
    }
}

#pragma mark - MapViewControllerDelegate call back

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation{
    return ((PhotoAnnotation*)annotation).photo.smallImage;
}

- (id<TopPlacesPhotoProtocol>)mapViewController:(MapViewController *)sender photoForAnnotation:(id <MKAnnotation>)annotation{
    id<TopPlacesPhotoProtocol> selectedPhoto = ((PhotoAnnotation*)annotation).photo;
    [self.delegate photoSelected:selectedPhoto];
    return ((PhotoAnnotation*)annotation).photo;
}
- (BOOL) mapViewController:(MapViewController *)sender
       samePhotoAnnotation:(id <MKAnnotation>)annotation1
         asPhotoAnnotation:(id <MKAnnotation>)annotation2{
    id<TopPlacesPhotoProtocol> selectedPhoto1 = ((PhotoAnnotation*)annotation1).photo;
    id<TopPlacesPhotoProtocol> selectedPhoto2 = ((PhotoAnnotation*)annotation2).photo;
    if([selectedPhoto1.photoId isEqual:selectedPhoto2.photoId]){
        return true;
    }
    return false;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id viewController = [self.splitViewController.viewControllers lastObject];
    if(viewController!=nil){ // ipad code
        PhotoDetailViewController *photoDetailViewController  = viewController;
        [self configurePhotoDetailViewController:photoDetailViewController withPhoto:[self.photoList objectAtIndex:indexPath.row]];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
