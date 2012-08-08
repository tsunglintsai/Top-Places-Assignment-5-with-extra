#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol TopPlacesPhotoProtocol <NSObject>
@property (nonatomic,strong) id photoId;
@property (nonatomic,strong) NSURL *photoSmallURL;
@property (nonatomic,strong) NSURL *photoLargeURL;
@property (nonatomic,strong) NSURL *photoOriginalURL;
@property (nonatomic,strong) NSString *photoTitle;
@property (nonatomic,strong) NSString *photoSubTitle;
@property (nonatomic,strong) UIImage *smallImage;
@property (nonatomic,weak) UIImage *largeImage;
@property (nonatomic,weak) UIImage *originalImage;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@end
