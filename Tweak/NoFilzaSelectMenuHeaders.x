#import <UIKit/UIKit.h>

@interface _UIContextMenuHeaderView : UIView
@end

@interface UIContextMenuContainerView : UIView
@end

static BOOL NFHShouldHideHeader(_UIContextMenuHeaderView *view) {
	(void)view;
	return YES;
}

static CGFloat NFHMinimumDimension(void) {
	CGFloat scale = [UIScreen mainScreen].scale;
	if (scale < 1.0) {
		scale = 1.0;
	}
	return 1.0 / scale;
}

%hook _UIContextMenuHeaderView

- (void)didMoveToSuperview {
	%orig;
	if (!NFHShouldHideHeader(self)) {
		return;
	}

	self.hidden = YES;
	self.alpha = 0.0;
	self.userInteractionEnabled = NO;
	self.clipsToBounds = YES;
}

- (void)layoutSubviews {
	%orig;
	if (!NFHShouldHideHeader(self)) {
		return;
	}

	self.hidden = YES;
	self.alpha = 0.0;
	self.userInteractionEnabled = NO;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)attributes {
	UICollectionViewLayoutAttributes *attrs = %orig(attributes);
	if (!attrs) {
		attrs = attributes;
	}
	if (!NFHShouldHideHeader(self) || !attrs) {
		return attrs;
	}

	CGFloat min = NFHMinimumDimension();
	CGSize size = attrs.size;
	size.height = min;
	if (size.width < min) {
		size.width = min;
	}
	attrs.size = size;

	self.hidden = YES;
	self.alpha = 0.0;
	self.userInteractionEnabled = NO;
	self.clipsToBounds = YES;

	return attrs;
}

%end