//
//  FlickerPhoto.m
//  Top Places
//
//  Created by Henry Tsai on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickerPhoto.h"
#import "FlickrFetcher.h"
#import <MapKit/MapKit.h>

#define PhotoCacheEntry_Property_KEY_PHOTO_ID @"photoId"
#define PhotoCacheEntry_Property_KEY_URL @"url"
#define PhotoCacheEntry_Property_KEY_FILE_URL @"file_url"
#define PhotoCacheEntry_Property_KEY_IMAGE @"image"
#define PhotoCacheEntry_Property_KEY_PHTO_SIZE @"photo_size"

typedef enum {
    small,
    large,
    original
} PhotoSize;

@interface PhotoCacheEntry : NSObject
@property (strong,nonatomic) NSString *photoId;
@property (strong,nonatomic) NSURL *url;
@property (strong,nonatomic) NSURL *fileURL;
@property (strong,nonatomic) UIImage *image;
@property (nonatomic) PhotoSize photoSize;
@end
@implementation PhotoCacheEntry
@synthesize photoId = _photoId;
@synthesize image = _image;
@synthesize fileURL = _fileURL;
@synthesize photoSize = _photoSize;
@synthesize url = _url;

- (NSURL*)fileURL{
    if(_fileURL == nil){
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSURL *documentDirectory = [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
        NSURL* imageFolderUrl = [documentDirectory URLByAppendingPathComponent:@"image"];
        NSString *fileName = [NSString stringWithFormat:@"%@_%i",self.photoId.description,self.photoSize];
        NSURL *newPhotoDiskCacheImageFileUrl = [imageFolderUrl URLByAppendingPathComponent:fileName];
        _fileURL = [newPhotoDiskCacheImageFileUrl URLByAppendingPathExtension:@"png"];
    }
    return _fileURL;
}

- (BOOL)isEqual:(id)anObject{
    BOOL result = false;
    if([anObject isKindOfClass:[PhotoCacheEntry class]]){
        PhotoCacheEntry *b = anObject;
        result = [self.photoId isEqual:b.photoId] && self.photoSize == b.photoSize;
    }
    return result;
}

- (NSDictionary*)getPropertyList{
    NSMutableDictionary* result = [[NSMutableDictionary alloc]init];
    [result setObject:self.photoId forKey:PhotoCacheEntry_Property_KEY_PHOTO_ID];
    [result setObject:[self.url description] forKey:PhotoCacheEntry_Property_KEY_URL];
    [result setObject:[self.fileURL path] forKey:PhotoCacheEntry_Property_KEY_FILE_URL];
    [result setObject:[NSNumber numberWithInt:self.photoSize] forKey:PhotoCacheEntry_Property_KEY_PHTO_SIZE];
    return result;
}

+ (PhotoCacheEntry*)getPhotoCacheEntryFromPropertyList: (NSDictionary *)propertyList{
    PhotoCacheEntry *result = [[PhotoCacheEntry alloc]init];
    [propertyList enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if([key isEqual:PhotoCacheEntry_Property_KEY_PHOTO_ID]){
            result.photoId = value;
        }else if([key isEqual:PhotoCacheEntry_Property_KEY_URL]){
            result.url = [NSURL URLWithString:value];
        }else if([key isEqual:PhotoCacheEntry_Property_KEY_FILE_URL]){
            result.fileURL = [NSURL fileURLWithPath:value];
        }else if([key isEqual:PhotoCacheEntry_Property_KEY_PHTO_SIZE]){
            result.photoSize = [value intValue];
        }
    }];
    return result;
}
@end


#define PHOTO_DISK_CACHE_SIZE 10
#define PHOTO_MEMORY_CACHE_SIZE 2
#define RECENT_PHOTO_KEY @"RECENT_PHOTO"
#define UKNOWN_PHOTO_TITLE_STRING @"Unknown"

@interface FlickerPhoto ()
@end

@implementation FlickerPhoto
@synthesize photoSmallURL = _photoSmallURL;
@synthesize photoLargeURL = _photoLargeURL;
@synthesize photoOriginalURL = _photoOriginalURL;
@synthesize photoTitle = _photoTitle;
@synthesize photoSubTitle = _photoSubTitle;
@synthesize smallImage = _smallImage;
@synthesize largeImage = _largeImage;
@synthesize originalImage = _originalImage;
@synthesize photoData = _photoData;
@synthesize photoId = _photoId;
@synthesize coordinate = _coordinate;

- (BOOL)isEqual:(id)anObject{
    BOOL result = false;
    if([anObject conformsToProtocol:@protocol(TopPlacesPhotoProtocol)]){
        FlickerPhoto *b = anObject;
        result = [self.photoId isEqual:b.photoId];
    }
    return result;
}

-(UIImage*) smallImage{
    if(_smallImage==nil){
        if(self.photoSmallURL!=nil){
            _smallImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoSmallURL]];
            //_smallImage = [[self class]getImageFromCache:self.photoSmallURL withPhotoId:self.photoId withImageSize:small];
        }
    }
    return _smallImage;
}

-(UIImage*) largeImage{
    if(_largeImage==nil){
        if(self.photoLargeURL!=nil){
            _largeImage = [[self class]getImageFromCache:self.photoLargeURL withPhotoId:self.photoId withImageSize:large];
        }
    }
    return _largeImage;
}

-(UIImage*) originalImage{
    if(_originalImage==nil){
        if(self.photoOriginalURL!=nil){
            //_originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoOriginalURL]];
            _originalImage = [[self class]getImageFromCache:self.photoOriginalURL withPhotoId:self.photoId withImageSize:original];

        }
    }
    return _originalImage;
}

+(void) createDiskCacheForPhotoCacheEntry: (PhotoCacheEntry*)photoCacheEntry{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    // check if image already exist in disk
    if([fileManager isReadableFileAtPath:[photoCacheEntry.fileURL path]]){
    }else{
        // create disk image from memory cache
        [UIImagePNGRepresentation(photoCacheEntry.image) writeToURL:photoCacheEntry.fileURL atomically:YES];
    }
}

+(float) getFileSize: (NSURL*) fileUrl{
    // Get file attributes
    NSDictionary* attributeDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileUrl path] error:nil];
    // Get size attribute
    NSNumber* fileSizeObj = [attributeDict objectForKey:NSFileSize];
    return fileSizeObj.floatValue;
}

+(void) massagePhotoCache: (NSMutableArray*)photoCache{
    __block float totalFileSizeInDisk = 0;
    [photoCache enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        PhotoCacheEntry *photoCacheEntry = object;
        if(idx < PHOTO_MEMORY_CACHE_SIZE){
            if(photoCacheEntry.image == nil){
                // check if image is in disk
                if([[NSFileManager defaultManager] isReadableFileAtPath:[photoCacheEntry.fileURL path]]){
                    photoCacheEntry.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoCacheEntry.fileURL]];
                }
            }
            if(photoCacheEntry.image == nil){
                photoCacheEntry.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoCacheEntry.url]];
                NSLog(@"load from internet");
            }
        }else{
            [[self class]createDiskCacheForPhotoCacheEntry:photoCacheEntry];            
            //free up memory cache
            photoCacheEntry.image = nil;
            if(totalFileSizeInDisk + [[self class]getFileSize:photoCacheEntry.fileURL] > PHOTO_DISK_CACHE_SIZE * 1000*1000){
                [[NSFileManager defaultManager]removeItemAtURL:photoCacheEntry.fileURL error:nil];
                //NSLog(@"delete file:%@",photoCacheEntry.fileURL);
            }else{
                totalFileSizeInDisk += [[self class]getFileSize:photoCacheEntry.fileURL];
            }
       }
    }];
}
+(NSURL*) propertyListFileUrl{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *documentDirectory = [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    NSString *fileName = [NSString stringWithFormat:@"CachePropertyList"];
    NSURL *propertyListFileUrl = [documentDirectory URLByAppendingPathComponent:fileName];
    propertyListFileUrl = [propertyListFileUrl URLByAppendingPathExtension:@"plist"];
    return propertyListFileUrl;
}

+(void) writeCacheToPropertyListInDisk{
    NSMutableArray *photoCache = [[self class]photoCache];
    NSMutableArray *propertyListContent = [[NSMutableArray alloc]init];
    [photoCache enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if(idx >= PHOTO_MEMORY_CACHE_SIZE){
            PhotoCacheEntry *photoCacheEntry = object;
            [propertyListContent addObject:[photoCacheEntry getPropertyList]];
        }
    }];
    [propertyListContent writeToURL:[[self class] propertyListFileUrl] atomically:YES];
}

+(UIImage*) getImageFromCache: (NSURL*) url
                  withPhotoId: (id) photoId
                withImageSize: (PhotoSize) photoSize{
    __block UIImage *result;
    dispatch_sync([[self class]photoCahchHandlingQueue], ^{
        NSMutableArray *photoCache = [[self class]photoCache];
        [[self class]createImageFolderIfNotExist];
        PhotoCacheEntry *photoCacheEntry = [[PhotoCacheEntry alloc]init];
        photoCacheEntry.photoId = photoId;
        photoCacheEntry.photoSize = photoSize;
        photoCacheEntry.url = url;
        if([photoCache containsObject:photoCacheEntry]){ // find image from cache
            photoCacheEntry = [photoCache objectAtIndex:[photoCache indexOfObject:photoCacheEntry]];
        }
        [photoCache removeObject:photoCacheEntry];
        // only cache large image in meemory
        if(photoSize == large || photoSize == original || [photoCache count] < PHOTO_MEMORY_CACHE_SIZE){
            [photoCache insertObject:photoCacheEntry atIndex:0];
        }else{
            [photoCache insertObject:photoCacheEntry atIndex:PHOTO_MEMORY_CACHE_SIZE-1];
        }
        // message cache
        [[self class]massagePhotoCache:photoCache];
        // write property list to disk
        [[self class]writeCacheToPropertyListInDisk];
        result = photoCacheEntry.image;
    });
    return result;
}

+(dispatch_queue_t)photoCahchHandlingQueue{    
    static dispatch_queue_t _photoCahchHandlingQueue = nil;
    if (_photoCahchHandlingQueue == nil){
        _photoCahchHandlingQueue = dispatch_queue_create("com.pyrogusto.operation", NULL);
    }
    return _photoCahchHandlingQueue;
}

+(NSMutableArray*) photoCache
{
    static NSMutableArray* _photoCache = nil;
    if (_photoCache == nil){
        _photoCache = [[NSMutableArray alloc]init];
        // read cache from property list
        NSArray *propertyListContent = [NSArray arrayWithContentsOfURL:[[self class]propertyListFileUrl]];
        [propertyListContent enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            PhotoCacheEntry *photoCacheEntry = [[PhotoCacheEntry class]getPhotoCacheEntryFromPropertyList:object];
            [_photoCache addObject:photoCacheEntry];
        }];
        // copy first N entry as memory cache.
        if([_photoCache count]>0){
            NSRange range;
            range.location = 0;
            range.length = [_photoCache count];
            if(range.length > PHOTO_MEMORY_CACHE_SIZE){
                range.length = PHOTO_MEMORY_CACHE_SIZE;
            }
            NSMutableArray *new_photoCache = [[_photoCache objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]mutableCopy];
            [new_photoCache addObjectsFromArray:_photoCache];
            _photoCache = new_photoCache;
        }
    }
    return _photoCache;
}

+(NSString*) generateUniqueFileName{
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    return uuidStr;
}

+(NSURL*)imageFolderUrl{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *documentDirectory = [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    NSURL* fileURL = [documentDirectory URLByAppendingPathComponent:@"image"];
    return fileURL;
}

+(void) createImageFolderIfNotExist{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL *imageFolderURL = [[self class] imageFolderUrl];
    NSError *error;
    if([fileManager isReadableFileAtPath:[imageFolderURL path]]){
        // do nothing.
    }else{
        [fileManager createDirectoryAtURL:imageFolderURL withIntermediateDirectories:YES attributes:nil error:&error];
        if(error){
            NSLog(@"%@",[error description]);
        }
    }
    if(error){
        NSLog(@"%@",[error description]);
        
    }
}


+ (NSArray*) getPhotoListFromFlickerPhotoListResponseData:(NSDictionary*)photoDataList withLimit:(int) limit{
    NSArray *photoList = [FlickrFetcher photosInPlace:photoDataList maxResults:limit];
    NSMutableArray *photoListForPhotoListView = [[NSMutableArray alloc]init];
    for (id photo in photoList) {
        FlickerPhoto *flickerPhoto = [[FlickerPhoto class]getPhotoFromFlickerPhotoResposneData:photo];
        [photoListForPhotoListView addObject:flickerPhoto];                
    }        
    return photoListForPhotoListView;
}

+ (NSArray*) getFavoritePhotoList{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSArray *photoDataList = [prefs objectForKey:RECENT_PHOTO_KEY];
    for (id photo in photoDataList) {
        FlickerPhoto *flickerPhoto = [[self class]getPhotoFromFlickerPhotoResposneData:photo];
        flickerPhoto.photoData = photo;
        [result addObject:flickerPhoto];                
    }    
    return result;
}

+ (void) addFavoritPhoto:(NSDictionary*)photo{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    NSMutableArray *recentPhotoList = [[prefs objectForKey:RECENT_PHOTO_KEY]mutableCopy];
    if(recentPhotoList==nil){
        recentPhotoList = [[NSMutableArray alloc]init];
    }
    if([recentPhotoList containsObject:photo]){
        for (id object in recentPhotoList) {
            if([object isEqual:photo]){
                [recentPhotoList removeObject:object];
                break;
            }
        }
    }
    [recentPhotoList insertObject:photo atIndex:0];    
    [prefs setObject:recentPhotoList forKey:RECENT_PHOTO_KEY];
    [prefs synchronize];
}

+ (NSString*) getCityStringFromFlickPlaceString:(NSString*)flickerPlaceString{
    NSString *result;
    if([flickerPlaceString isKindOfClass:[NSString class]]){
        NSRange fristCommonRange = [flickerPlaceString rangeOfString:@","];
        if(!fristCommonRange.location!=NSNotFound){ // if found common 
            result = [flickerPlaceString substringToIndex:fristCommonRange.location];
        }else{
            result = flickerPlaceString;
        }
    }    
    return result;
}

+ (NSString*) getRestOfPlaceStringOtherFromFlickPlaceString:(NSString*)flickerPlaceString{
    NSString *result;
    if([flickerPlaceString isKindOfClass:[NSString class]]){
        NSRange fristCommonRange = [flickerPlaceString rangeOfString:@","];
        if(!fristCommonRange.location!=NSNotFound){ // if found common 
            result = [[flickerPlaceString substringFromIndex:fristCommonRange.location+1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }else{
            result = flickerPlaceString;
        }
    }    
    return result;
}

+ (NSString*) getPlaceStringFromFlickerDataEntry:(NSDictionary*)dataEntry{
    NSString *result;
    if([dataEntry isKindOfClass:[NSDictionary class]]){
        result = [dataEntry objectForKey:FLICKR_PLACE_NAME];
    }
    return result;
    
}

+ (FlickerPhoto*)getPhotoFromFlickerPhotoResposneData:(NSDictionary*)photoData{
    FlickerPhoto *photoEntry = [[FlickerPhoto alloc]init];
    photoEntry.photoId = [photoData objectForKey:FLICKR_PHOTO_ID];
    photoEntry.photoSmallURL = [FlickrFetcher urlForPhoto:photoData format:FlickrPhotoFormatSquare];
    photoEntry.photoLargeURL = [FlickrFetcher urlForPhoto:photoData format:FlickrPhotoFormatLarge];
    photoEntry.photoOriginalURL = [FlickrFetcher urlForPhoto:photoData format:FlickrPhotoFormatOriginal];
    photoEntry.photoData = photoData;
    photoEntry.coordinate = CLLocationCoordinate2DMake([[photoData valueForKey:FLICKR_LATITUDE] floatValue], [[photoData valueForKey:FLICKR_LONGITUDE] floatValue]);
    NSString *titleInResponseData = [photoData valueForKey:FLICKR_PHOTO_TITLE];
    NSString *descriptionInResponseData = [photoData valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if(![titleInResponseData isEqualToString:@""]){
        photoEntry.photoTitle = titleInResponseData;
    }
    if(photoEntry.photoTitle==nil){
        if(![descriptionInResponseData isEqualToString:@""]){
            photoEntry.photoTitle = descriptionInResponseData;
        }else{
            photoEntry.photoTitle = UKNOWN_PHOTO_TITLE_STRING;
        }
    }else{
        if(![descriptionInResponseData isEqualToString:@""]){
            photoEntry.photoSubTitle = descriptionInResponseData;
        }        
    }
    return photoEntry;
}

@end