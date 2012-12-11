//
//  UICollectionViewWaterfallLayout.h
//
//  Created by Nelson on 12/11/19.
//  Copyright (c) 2012 Nelson Tai. All rights reserved.
//

@class UICollectionViewWaterfallLayout;
@protocol UICollectionViewDelegateWaterfallLayout < UICollectionViewDelegate>
- (CGFloat)collectionView:( UICollectionView *)collectionView
                   layout:(UICollectionViewWaterfallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UICollectionViewWaterfallLayout :  UICollectionViewLayout

@property (nonatomic, weak) id<UICollectionViewDelegateWaterfallLayout> delegate;

    // How many columns
@property (nonatomic, assign) NSUInteger columnCount;

    // Width for every column
@property (nonatomic, assign) CGFloat itemWidth;

    // The outside margins used to layout content
@property (nonatomic, assign) UIEdgeInsets contentInset;

    // The margins between items
@property (nonatomic, assign) UIOffset itemMargins;

- (CGFloat)longestColumnHeightForHeights:(NSNumber *)heights withWidth:(CGFloat)width;

@end
