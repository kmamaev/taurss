#import "ArticlesListVC.h"
#import "IIViewDeckController.h"


@interface ArticlesListVC ()
@end


@implementation ArticlesListVC

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _articles = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"left"
                                             style:UIBarButtonItemStylePlain
                                             target:self.viewDeckController
                                             action:@selector(toggleLeftView)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"reuseID2"];
    Article *article = self.articles[indexPath.row];
    cell.textLabel.text = article.title;
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    Article *article = self.articles[ip.row];
    [self.navigationController pushViewController:[[ArticleDetailsVC alloc] initWithArticle:article]
                                         animated:YES];
}

@end
