#import <UIKit/UIKit.h>

@interface _UIContextMenuHeaderView : UIView
@end

static BOOL NFHIsTopmostHeaderView(_UIContextMenuHeaderView *view) {
	UIView *superview = view.superview;
	if (!superview) {
		return NO;
	}

	CGFloat viewY = CGRectGetMinY(view.frame);
	for (UIView *subview in superview.subviews) {
		if (subview == view) {
			continue;
		}
		if (![subview isKindOfClass:%c(_UIContextMenuHeaderView)]) {
			continue;
		}
		if (CGRectGetMinY(subview.frame) < viewY) {
			return NO;
		}
	}

	return YES;
}

static BOOL NFHShouldHideHeader(_UIContextMenuHeaderView *view) {
	if (!view) {
		return YES;
	}
	if (view.subviews.count == 0) {
		return NO;
	}
	if (NFHIsTopmostHeaderView(view)) {
		return NO;
	}
	return YES;
}

static void NFHApplyHiddenState(_UIContextMenuHeaderView *view) {
	view.hidden = YES;
	view.alpha = 0.0;
	view.userInteractionEnabled = NO;
	view.clipsToBounds = YES;
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

	NFHApplyHiddenState(self);
}

- (void)layoutSubviews {
	%orig;
	if (!NFHShouldHideHeader(self)) {
		return;
	}

	NFHApplyHiddenState(self);
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:
	(UICollectionViewLayoutAttributes *)attributes {
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

	NFHApplyHiddenState(self);

	return attrs;
}

%end
