#import <Foundation/Foundation.h>
#import "ArticlesController.h"


typedef NS_ENUM(NSInteger, SourceId) {
    sourceIdAllNews   = -1,
    sourceIdFavorites = -2,
};


@interface Source : NSObject

@property (assign, nonatomic) NSInteger sourceId;
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) NSURL *iconURL;
@property (strong, nonatomic) NSURL *sourceURL;

/**
 *  Returns instance of source with predefined title and sourceId equaling to sourceTypeAllNews.
 *  Needs not nil ArticlesController for proper working.
 */
+ (instancetype)allNewsSourceWithArticlesController:(ArticlesController *)articlesController;

/**
 *  Returns instance of source with predefined title and sourceId equaling to sourceTypeFavorites.
 *  Needs not nil ArticlesController for proper working.
 */
+ (instancetype)favoritesSourceWithArticlesController:(ArticlesController *)articlesController;

@end
