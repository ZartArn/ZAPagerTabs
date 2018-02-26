//
//  ZAPageTabsCell.h
//  ZAPageTabs
//
//  Created by ZartArn on 22.11.17.
//

#import <UIKit/UIKit.h>

@protocol ZAPageTabsCellProtocol <NSObject>

@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@interface ZAPageTabsCell : UICollectionViewCell <ZAPageTabsCellProtocol>

@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *titleLabel;

@end




