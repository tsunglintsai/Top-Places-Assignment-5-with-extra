#import "MyUITabBarController.h"
#import "PhotoListViewController.h"
#import "FlickrFetcher.h"
#import "PhotoDetailViewController.h"
#import "FlickerPhoto.h"

@interface MyUITabBarController()<UITabBarControllerDelegate>
	
@end


@implementation MyUITabBarController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad{
    self.delegate = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(id)viewController{
    //NSLog(@"didSelectViewController %@",viewController);
    if([viewController isKindOfClass:[UINavigationController class]]){
        UINavigationController *navigationController = viewController;
        if([navigationController.visibleViewController isKindOfClass:[PhotoListViewController class]]){
            PhotoListViewController* photoListViewController = (PhotoListViewController*) navigationController.visibleViewController;
            if([photoListViewController.title isEqualToString:@"Recent Viewed Photo"]){
                photoListViewController.photoList = [[FlickerPhoto class]getFavoritePhotoList];
                photoListViewController.listTitle = @"Recent Viewed Photo";
            }
        }
    }
}

@end
