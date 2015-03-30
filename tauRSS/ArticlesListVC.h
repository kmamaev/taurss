#import <UIKit/UIKit.h>
#import "ArticlesController.h"


@class Source;

@interface ArticlesListVC : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *articlesTable;
@property (strong, nonatomic) ArticlesController *articlesController;
@property (weak, nonatomic) Source *source;

@end
