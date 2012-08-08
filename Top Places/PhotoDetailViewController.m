//
//  PhotoDetailViewController.m
//  Top Places
//
//  Created by Henry Tsai on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoDetailViewController ()<UIScrollViewDelegate,SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong,nonatomic) UIBarButtonItem * busyIndicatorBarButton;
@property (strong,nonatomic) UIBarButtonItem *flexibleSpaceBeforeBusyIndicatorBarButton;

@end

@implementation PhotoDetailViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize photoTitle = _photoTitle;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolBar = _toolBar;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize busyIndicatorBarButton = _busyIndicatorBarButton;
@synthesize flexibleSpaceBeforeBusyIndicatorBarButton = _flexibleSpaceBeforeBusyIndicatorBarButton;

- (UIActivityIndicatorView*) activityIndicatorView{
    if(_activityIndicatorView == nil){
        _activityIndicatorView =
        [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

- (UIBarButtonItem*)busyIndicatorBarButton{
    if(_busyIndicatorBarButton==nil){
        _busyIndicatorBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    }
    return _busyIndicatorBarButton;
}

- (UIBarButtonItem*) flexibleSpaceBeforeBusyIndicatorBarButton{
    if(_flexibleSpaceBeforeBusyIndicatorBarButton == nil){
        _flexibleSpaceBeforeBusyIndicatorBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    return _flexibleSpaceBeforeBusyIndicatorBarButton;
}

- (void)showBusyIndicator{
    [self.activityIndicatorView startAnimating];

    // ipad
    NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
    if([toolbarItems containsObject:self.flexibleSpaceBeforeBusyIndicatorBarButton]){
        [toolbarItems removeObject:self.flexibleSpaceBeforeBusyIndicatorBarButton];
    }
    if([toolbarItems containsObject:self.busyIndicatorBarButton]){
        [toolbarItems removeObject:self.busyIndicatorBarButton];
    }
    [toolbarItems addObject:self.flexibleSpaceBeforeBusyIndicatorBarButton];
    [toolbarItems addObject:self.busyIndicatorBarButton];
    self.toolBar.items = toolbarItems;
    //iphone
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    self.navigationItem.rightBarButtonItem =  barButton;
}

- (void)hideBusyIndicator{
    // ipad
    NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
    if([toolbarItems containsObject:self.flexibleSpaceBeforeBusyIndicatorBarButton]){
        [toolbarItems removeObject:self.flexibleSpaceBeforeBusyIndicatorBarButton];
    }
    if([toolbarItems containsObject:self.busyIndicatorBarButton]){
        [toolbarItems removeObject:self.busyIndicatorBarButton];
    }
    self.toolBar.items = toolbarItems;
    //iphone
    self.navigationItem.rightBarButtonItem = nil;
    [self.activityIndicatorView stopAnimating];
}

- (void)updateImageView{
    [self showBusyIndicator];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = self.photo.largeImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scrollView.zoomScale = 1.0; // reset zoomScale
            self.imageView.image = image;
            if(self.imageView.image!=nil){
                self.imageView.frame = CGRectMake(0, 0, self.photo.largeImage.size.width, self.photo.largeImage.size.height);
                self.scrollView.delegate = self;
                self.scrollView.contentSize = self.photo.largeImage.size;
                float xScale = self.scrollView.frame.size.width/self.imageView.image.size.width;
                float yScale = self.scrollView.frame.size.height/self.imageView.image.size.height;
                CGRect zoomToRect;
                float xOffset = 0;
                float yOffset = 0;
                if(yScale > xScale){
                    xOffset = (self.imageView.bounds.size.width * yScale - self.scrollView.bounds.size.width )/2;
                    zoomToRect = CGRectMake(0, 0, 0, self.imageView.image.size.height);
                }else{
                    yOffset = (self.imageView.frame.size.height * xScale - self.scrollView.frame.size.height )/2;
                    zoomToRect = CGRectMake(0, 0, self.imageView.image.size.width, 0);
                }
                [self.scrollView zoomToRect:zoomToRect animated:false];
                self.scrollView.contentOffset = CGPointMake(xOffset , yOffset );
            }
            [self hideBusyIndicator];
        });
    });
}

- (void)setPhoto:(id<TopPlacesPhotoProtocol>)photo{
    _photo = photo;
    [self updateImageView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateImageView];    
    self.navigationItem.title = self.photoTitle;

}

- (void)viewWillLayoutSubviews{
    [self updateImageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolBar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
