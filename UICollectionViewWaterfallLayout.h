//
//  UICollectionViewWaterfallLayout.h
//
//  Created by Nelson on 12/11/19.
//  Copyright (c) 2012 Nelson Tai. All rights reserved.
//


#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
#define PSUICollectionView PSUICollectionView_
#define PSUICollectionViewCell PSUICollectionViewCell_
#define PSUICollectionReusableView PSUICollectionReusableView_
#define PSUICollectionViewDelegate PSTCollectionViewDelegate
#define PSUICollectionViewDataSource PSTCollectionViewDataSource
#define PSUICollectionViewLayout PSUICollectionViewLayout_
#define PSUICollectionViewFlowLayout PSUICollectionViewFlowLayout_
#define PSUICollectionViewLayoutAttributes PSUICollectionViewLayoutAttributes_
#define PSUICollectionViewController PSUICollectionViewController_

@interface PSUICollectionView_ : PSTCollectionView @end
@interface PSUICollectionViewCell_ : PSTCollectionViewCell @end
@interface PSUICollectionReusableView_ : PSTCollectionReusableView @end
@interface PSUICollectionViewLayout_ : PSTCollectionViewLayout @end
@interface PSUICollectionViewFlowLayout_ : PSTCollectionViewFlowLayout @end
@interface PSUICollectionViewLayoutAttributes_ : PSTCollectionViewLayoutAttributes @end
@interface PSUICollectionViewController_ : PSTCollectionViewController <PSUICollectionViewDelegate, PSUICollectionViewDataSource> @end

#else
#define PSUICollectionView UICollectionView
#define PSUICollectionViewCell UICollectionViewCell
#define PSUICollectionReusableView UICollectionReusableView
#define PSUICollectionViewDelegate UICollectionViewDelegate
#define PSUICollectionViewDataSource UICollectionViewDataSource
#define PSUICollectionViewLayout UICollectionViewLayout
#define PSUICollectionViewFlowLayout UICollectionViewFlowLayout
#define PSUICollectionViewLayoutAttributes UICollectionViewLayoutAttributes
#define PSUICollectionViewController UICollectionViewController
#endif

@class UICollectionViewWaterfallLayout;
@protocol UICollectionViewDelegateWaterfallLayout <PSUICollectionViewDelegate>
- (CGFloat)collectionView:(PSUICollectionView *)collectionView
                   layout:(UICollectionViewWaterfallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UICollectionViewWaterfallLayout : PSUICollectionViewLayout
@property (nonatomic, weak) id<UICollectionViewDelegateWaterfallLayout> delegate;
@property (nonatomic, assign) NSUInteger columnCount; // How many columns
@property (nonatomic, assign) CGFloat itemWidth; // Width for every column
@property (nonatomic, assign) UIEdgeInsets sectionInset; // The margins used to lay out content in a section
@end
