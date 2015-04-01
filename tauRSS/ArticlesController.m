#import "ArticlesController.h"
#import "SourcesController.h"
#import <AFHTTPRequestOperationManager.h>
#import "RSSParser.h"
#import "StorageController.h"


@interface ArticlesController ()
@property (strong, nonatomic) SourcesController *sourcesController;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@end


@implementation ArticlesController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

+ (ArticlesController *)sharedInstance
{
    static ArticlesController *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[ArticlesController alloc] init];
    });
    return sharedInstance;
}

- (SourcesController *)sourcesController
{
    if (!_sourcesController) {
        _sourcesController = [SourcesController sharedInstance];
    }
    return _sourcesController;
}

- (void)setRead:(BOOL)isRead forArticle:(Article *)article
{
    article.isRead = isRead;
    NSMutableArray *unreadArticles = [article.source.unreadArticles mutableCopy];
    isRead ? [unreadArticles removeObject:article] : [unreadArticles addObject:article];
    article.source.unreadArticles = unreadArticles;
#warning resolve TODO mark
    // TODO: Implement working with db
}

- (void)setFavorite:(BOOL)isFavorite forArticle:(Article *)article
{
#warning resolve TODO mark
    // TODO: Implement this
}

- (NSArray *)allArticles
{
    NSMutableArray *articles = [NSMutableArray array];
    NSArray *sources = self.sourcesController.sources;
    for (Source *source in sources) {
        if (source.sourceId != sourceIdAllNews && source.sourceId != sourceIdFavorites) {
            [articles addObjectsFromArray:source.articles];
        }
    }
    return [[self class] articlesArraySortedByPublishDate:articles];
}

- (NSArray *)favoriteArticles
{

    if (_favoriteArticles == nil)
    {
        _favoriteArticles = [self.sourcesController.storageController getFavoriteArticles];
    }
    return [[self class] articlesArraySortedByPublishDate:_favoriteArticles];
}

- (NSArray *)unreadArticlesForSource:(Source *)source
{
    NSMutableArray *unreadArticles = [NSMutableArray array];
    if (source.sourceId == sourceIdAllNews) {
        for (Source *s in self.sourcesController.sources) {
            [unreadArticles addObjectsFromArray:s.unreadArticles];
        }
        return [[self class] articlesArraySortedByPublishDate:unreadArticles];
    }
    else {
        for (Article *article in source.articles) {
            if (!article.isRead) {
                [unreadArticles addObject:article];
            }
        }
        return unreadArticles;
    }
}

- (void)updateArticlesForSource:(Source *)source
    success:(void (^)(BOOL))success
    failure:(void (^)(NSArray *))failure
{
    // If source is equal to "All news"
    if (source.sourceId == sourceIdAllNews) {
        NSMutableArray *__block errors = [NSMutableArray array];
        BOOL __block areAllArticlesHaveUpdates = NO;
        dispatch_group_t group = dispatch_group_create();
        for (Source *s in self.sourcesController.sources) {
            dispatch_group_enter(group);
            [self updateArticlesForSource:s
                success:^(BOOL areNewArticlesAdded) {
                    if (areNewArticlesAdded && !areAllArticlesHaveUpdates) {
                        areAllArticlesHaveUpdates = YES;
                    }
                    dispatch_group_leave(group);
                } failure:^(NSArray *error) {
                    @synchronized(errors) {
                        [errors addObjectsFromArray:error];
                    }
                    dispatch_group_leave(group);
                }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"All sources updated.");
            if (errors.count > 0) {
                if (!failure) {
                    return;
                }
                failure(errors);
            }
            else {
                if (!success) {
                    return;
                }
                success(areAllArticlesHaveUpdates);
            }
        });
    }
    
    // If source is equal to "Favorites"
    else if (source.sourceId == sourceIdFavorites) {
        if (success) {
            success(NO);
        }
    }
    
    // If source is not equal to "All news" or "Favorites"
    else {
        NSString *URLString = source.sourceURL.absoluteString;
        self.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
#warning I am not sure that only type "application/rss+xml" is necessary. Need to additional investigation.
        self.manager.responseSerializer.acceptableContentTypes =
            [NSSet setWithObject:@"application/rss+xml"];
        [self.manager GET:URLString
            parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                RSSParser *rssParser = [[RSSParser alloc] init];
                NSMutableSet *fetchedArticles = [rssParser
                    parseResponse:(NSXMLParser *)responseObject forSource:source];
                NSSet *currentArticles = [NSSet setWithArray:source.articles];
                [fetchedArticles minusSet:currentArticles];
                NSArray *newArticles = [[self class] articlesArrayBySortingASet:fetchedArticles];
                source.articles = [newArticles arrayByAddingObjectsFromArray:source.articles];
                source.unreadArticles = [newArticles
                    arrayByAddingObjectsFromArray:source.unreadArticles];
                NSLog(@"Update for source \"%@\" has finished, %ld articles are added.",
                    source.title, newArticles.count);
                if (!success) {
                    return;
                }
                success(newArticles.count > 0);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (!failure) {
                    return;
                }
                failure(@[error]);
            }];
    }
}

// Sort the specified articles set by publish date and returns the sorted set as array
+ (NSArray *)articlesArrayBySortingASet:(NSSet *)unsortedArticlesSet
{
    NSSortDescriptor *publishDateSortDescriptor = [NSSortDescriptor
        sortDescriptorWithKey:@"publishDate" ascending:NO];
    return [unsortedArticlesSet sortedArrayUsingDescriptors:@[publishDateSortDescriptor]];
}

// Sort the specified articles array by publish date and returns the sorted array
+ (NSArray *)articlesArraySortedByPublishDate:(NSArray *)unsortedArticles
{
    NSSortDescriptor *publishDateSortDescriptor = [NSSortDescriptor
        sortDescriptorWithKey:@"publishDate" ascending:NO];
    return [unsortedArticles sortedArrayUsingDescriptors:@[publishDateSortDescriptor]];
}

@end
