//
//  CLScrollView.h
//  CLScrollViewUrl
//
//  Created by Lei.C on 15/11/5.
//  Copyright © 2015年 Lei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyDelegate <NSObject>

- (void)doSomethingWithIndex:(int)index;

@end


@interface CLScrollView : UIView<UIScrollViewDelegate>
//公开方法
//主滚动视图
@property (nonatomic,strong)UIScrollView * mainScrollView;//imageView tag = i+10
/*传入文字数组*/
@property (nonatomic,strong)NSArray * textArr;

@property (nonatomic,assign)id <MyDelegate>delegate;

/*传入图片名称数组显示广告滚动视图*/
- (instancetype)initWithFrame:(CGRect)frame andPicArr:(NSArray*)picArr andTextArr:(NSArray *)textArr;
//图片的点击方法
- (void)tap:(UITapGestureRecognizer*)tap;


@end
