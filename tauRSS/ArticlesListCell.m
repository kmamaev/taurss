#import "ArticlesListCell.h"
#import <UIImageView+AFNetworking.h>


@implementation ArticlesListCell

- (void)setUrlForImage:(NSURL *)urlForImage
{
    if (urlForImage == nil) {
        self.imageWidth.constant = 0.0f;
    }
    else {
        [self.articleImageView setImageWithURL:urlForImage];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.articleImageView.image = [[self class] placeholderImage];
}

+ (UIImage *)placeholderImage
{
    static UIImage *placeholderImage = nil;
    if (!placeholderImage) {
        placeholderImage = [UIImage imageNamed:@"image_placeholder.png"];
    }
    return placeholderImage;
}

@end
