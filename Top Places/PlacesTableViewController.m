//
//  PlacesTableViewController.m
//  Top Places
//
//  Created by Henry Tsai on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoListViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "PhotoDetailViewController.h"
#import "FlickerPhoto.h"
#import "MapViewController.h"
#import "PlaceAnnotation.h"

@interface PlacesTableViewController ()<UISplitViewControllerDelegate,PhotoListViewControllerDelegate,MapViewControllerDelegate>
@property (strong,nonatomic) NSArray *topPlaces;
@property (strong,nonatomic) NSMutableSet *photoList;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong,nonatomic) NSMutableDictionary *topPlacesGroupByCountry;
@property (strong,nonatomic) NSMutableArray *countryList;
@end

@implementation PlacesTableViewController

@synthesize topPlaces = _topPlaces;
@synthesize photoList = _photoList;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize topPlacesGroupByCountry = _topPlacesGroupByCountry;
@synthesize countryList = _countryList;

- (UIActivityIndicatorView*) activityIndicatorView{
    if(_activityIndicatorView == nil){
        _activityIndicatorView =
        [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
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

- (NSMutableSet *)photoList{
    if(_photoList==nil){
        _photoList = [[NSMutableSet alloc]init];
    }
    return _photoList;
}

- (NSMutableArray*)countryList{
    if(_countryList == nil){
        _countryList = [[NSMutableArray alloc]init];
    }
    return _countryList;
}

- (NSMutableDictionary*)topPlacesGroupByCountry{
    if(_topPlacesGroupByCountry==nil){
        _topPlacesGroupByCountry = [[NSMutableDictionary alloc]init];
    }
    return _topPlacesGroupByCountry;
}

- (void)setTopPlaces:(NSArray *)topPlaces{
    _topPlaces = topPlaces;
    [self.tableView reloadData];
}

- (NSArray*)topPlaces{
    if(_topPlaces==nil){
        _topPlaces = [[NSArray alloc]init];
    }
    return _topPlaces;
}

- (UITableView*)tableView{
    UITableView  *result;
    if([self.view isKindOfClass:[UITableView class]]){
        result = (UITableView*)self.view;
    }
    return result;
}

- (void)reloadData{
    [self showBusyIndicator];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.topPlaces = [FlickrFetcher topPlaces];
        [self.countryList removeAllObjects];
        [self.topPlacesGroupByCountry removeAllObjects];
        NSMutableSet *countrySet =  [[NSMutableSet alloc]init ];
        for (id object in self.topPlaces) {
            NSArray *placeTokens = [[FlickerPhoto getPlaceStringFromFlickerDataEntry:object] componentsSeparatedByString:@","];
            NSString *countryString = (NSString*)[placeTokens lastObject];
            countryString = [countryString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSMutableArray *placesInCountry = [[self.topPlacesGroupByCountry objectForKey:countryString]mutableCopy];
            if(placesInCountry==nil){
                placesInCountry = [[NSMutableArray alloc]init];
            }
            [placesInCountry addObject:object];
            [self.topPlacesGroupByCountry setObject:placesInCountry forKey:countryString];
            [countrySet addObject:countryString];
        }
        [self.countryList removeAllObjects];
        for(id object in countrySet){
            [self.countryList  addObject:object];
        }
        
        NSArray *sortedArray;
        sortedArray = [self.countryList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [a compare:b];
        }];
        self.countryList = [sortedArray mutableCopy];
        // sort place in each country
        
        NSMutableDictionary *tmpDictionaray = [[NSMutableDictionary alloc]init];
        for(NSString *key in [self.topPlacesGroupByCountry copy]){
            NSMutableArray *placesInCountry = [self.topPlacesGroupByCountry objectForKey:key];
            NSArray *sortedArray;
            sortedArray = [placesInCountry sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSString *first =  [[FlickerPhoto class] getPlaceStringFromFlickerDataEntry:(NSDictionary*)a];
                NSString *second = [[FlickerPhoto class] getPlaceStringFromFlickerDataEntry:(NSDictionary*)b];
                return [first compare:second];
            }];
            [tmpDictionaray setObject:sortedArray forKey:key];
        }
        self.topPlacesGroupByCountry = tmpDictionaray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self hideBusyIndicator];
        });
    });
}

- (void) viewDidLoad{
    [super viewDidLoad];
    [self reloadData];
    NSLog(@"test");
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *countryString = [self.countryList objectAtIndex:section];
    return [[self.topPlacesGroupByCountry objectForKey:countryString]count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countryList objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }    
    NSString *countryString = [self.countryList objectAtIndex:indexPath.section];
    NSArray *placesInCountry = [self.topPlacesGroupByCountry objectForKey:countryString];
    NSString *locationString = [[FlickerPhoto class]getPlaceStringFromFlickerDataEntry:[placesInCountry objectAtIndex:indexPath.row]];
    NSString *cityString = [[FlickerPhoto class]getCityStringFromFlickPlaceString:locationString];
    NSString *restStringOtherThanCity = [[FlickerPhoto class]getRestOfPlaceStringOtherFromFlickPlaceString:locationString];
    cell.textLabel.text = cityString;
    cell.detailTextLabel.text = restStringOtherThanCity;
    return cell;
}

#pragma mark - Segueway Methods


- (void) configPhotoListViewController: (PhotoListViewController*) photoListViewController
                          withLocation:(NSDictionary*)location{
    NSDictionary *selectedLocation = location;
    NSString *locationString = [[FlickerPhoto class]getPlaceStringFromFlickerDataEntry:selectedLocation];
    NSString *cityString = [[FlickerPhoto class]getCityStringFromFlickPlaceString:locationString];
    photoListViewController.listTitle = cityString;
    photoListViewController.delegate = self;
    photoListViewController.isShowBusyIndicator = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* photoForPlace = [FlickerPhoto getPhotoListFromFlickerPhotoListResponseData:selectedLocation withLimit:50];
        [self.photoList addObjectsFromArray:photoForPlace];
        dispatch_async(dispatch_get_main_queue(), ^{
            photoListViewController.photoList = photoForPlace;
            photoListViewController.isShowBusyIndicator = NO;
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToPhotoListSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSArray *placesInCountry = [self.topPlacesGroupByCountry objectForKey:[self.countryList objectAtIndex:indexPath.section]];
        NSDictionary *selectedLocation = [placesInCountry objectAtIndex:indexPath.row];
        [self configPhotoListViewController:segue.destinationViewController withLocation:selectedLocation];
    }else if([segue.identifier isEqualToString:@"PushToMapViewFromPlace"]){
        MapViewController *mapViewController;
        if(self.splitViewController == nil){ // iphone
            UINavigationController *navigationController = segue.destinationViewController;
            mapViewController = (MapViewController*) navigationController.visibleViewController;
        }else{
            mapViewController = segue.destinationViewController;
        }
        NSMutableArray *annotations = [[NSMutableArray alloc]initWithCapacity:[self.photoList count]];
        for( NSDictionary *place in self.topPlaces){
            [annotations addObject:[PlaceAnnotation annotationForPlace:place]];
        }
        mapViewController.annotations = annotations;
        mapViewController.delegate = self;
    }
}


- (void)mapButtonClicked{
    [self performSegueWithIdentifier:@"PushToMapViewFromPlace" sender:self];
}

- (void)photoSelected:(id<TopPlacesPhotoProtocol>)photoSelected{
    // save selected photo to nsuserdefault   
    for (id object in self.photoList) { 
        if([object isEqual:photoSelected] && [object isKindOfClass:[FlickerPhoto class]] ){
            FlickerPhoto *selectedPhoto = object;
            [[FlickerPhoto class] addFavoritPhoto:selectedPhoto.photoData];
            break;
        }
    }
}

#pragma mark - MapViewControllerDelegate call back


- (UIImage *)mapViewController:(MapViewController *)sender
            imageForAnnotation:(id <MKAnnotation>)annotation{
    return nil;
}

- (void)mapViewController:(MapViewController *)sender
configPhotoListViewController:(PhotoListViewController*) photoListViewController
               withAnnotation:(id <MKAnnotation>)annotation{
    PlaceAnnotation *placeAnnotation = annotation;
    NSDictionary *selectedLocation = placeAnnotation.place;
    [self configPhotoListViewController:photoListViewController withLocation:selectedLocation];
}

- (BOOL) mapViewController:(MapViewController *)sender
       samePhotoAnnotation:(id <MKAnnotation>)annotation1
         asPhotoAnnotation:(id <MKAnnotation>)annotation2{
    NSDictionary *place1 = ((PlaceAnnotation*)annotation1).place;
    NSDictionary *place2 = ((PlaceAnnotation*)annotation2).place;
    if([place1 isEqual:place2]){
        return true;
    }
    return false;
}

#pragma mark - ╭━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
#pragma mark - ┃ SplitView              {  ┃
#pragma mark - ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━╯
- (void)awakeFromNib  // always try to be the split view's delegate
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    self.splitViewController.presentsWithGesture = NO;
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"shouldHideViewController");

    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    NSLog(@"willHideViewController");
    barButtonItem.title = @"Menu";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSLog(@"willShowViewController");
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}


#pragma mark - ╭━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
#pragma mark - ┃ SplitView              }  ┃
#pragma mark - ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━╯

@end
