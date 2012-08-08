
#import <UIKit/UIKit.h>
#import "TopPlacesPhotoProtocol.h"

@protocol PhotoListViewControllerDelegate
- (void)photoSelected:(id<TopPlacesPhotoProtocol>)photoSelected;
@end

@interface PhotoListViewController : UITableViewController
@property (nonatomic,strong) NSArray* photoList;
@property (nonatomic,strong) NSString* listTitle;
@property (nonatomic,weak) id<PhotoListViewControllerDelegate> delegate;
@property (nonatomic) BOOL isShowBusyIndicator;
@end
