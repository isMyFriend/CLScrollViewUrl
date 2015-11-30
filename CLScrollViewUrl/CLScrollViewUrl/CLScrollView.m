//
//  CLScrollView.m
//  CLScrollViewUrl
//
//  Created by Lei.C on 15/11/5.
//  Copyright © 2015年 Lei. All rights reserved.
//

#import "CLScrollView.h"

@implementation CLScrollView
{
    NSTimer * _timer;
    NSInteger _i;
    UIPageControl * _pageControl;
    NSMutableArray * _arr;
}
- (instancetype)initWithFrame:(CGRect)frame andPicArr:(NSArray *)picArr andTextArr:(NSArray *)textArr{
    if (self = [super initWithFrame:frame]) {
        _i = 1;
        _arr = [[NSMutableArray alloc]initWithArray:picArr];
        float width = frame.size.width;
        float height = frame.size.height;
        
        _mainScrollView = [[UIScrollView alloc]initWithFrame:frame];
        _mainScrollView.contentSize = CGSizeMake(width * (picArr.count + 2),
                                                 height);
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        [_mainScrollView setContentOffset:CGPointMake(width, 0)];
        [self addSubview:_mainScrollView];
        
        //创建线程
        dispatch_group_t group = dispatch_group_create();
        //图片
        for (int i = 0 ; i < picArr.count; i++) {
            UIImageView * picImageView = [[UIImageView alloc]initWithFrame:
                                          CGRectMake(width * (i+1),
                                                     0,
                                                     width,
                                                     height)];
            picImageView.userInteractionEnabled = YES;
            picImageView.tag = i+10;
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
            [picImageView addGestureRecognizer:tap];

            dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
                // 并行执行的线程一
                NSData * data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:picArr[i]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    picImageView.image = [UIImage imageWithData:data];
                });
                
                
            });

            
            [_mainScrollView addSubview:picImageView];
        }
        //文字
        for (int i = 0; i < picArr.count; i ++) {
            //标题文字
            UILabel * textLabel = [[UILabel alloc]initWithFrame:
                                                    CGRectMake(width * (i+1),
                                                               height -20,
                                                               width ,
                                                               20)];
            textLabel.text = textArr[i];
            
            [_mainScrollView addSubview:textLabel];
            
       }
        //第0个图片
        UIImageView * image0 = [[UIImageView alloc]initWithFrame:
                                                                CGRectMake(0,
                                                                           0,
                                                                           width,
                                                                           height)];
        
        UIImageView * imageView = [self viewWithTag:_arr.count - 1 +10];

        [_mainScrollView addSubview:image0];
        
        UILabel * textLabel0 = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                        height -20,
                                                                        width ,
                                                                        20)];
        
        textLabel0.text = textArr[textArr.count-1];
        
        [_mainScrollView addSubview:textLabel0];
        
        //第arr.count个图片
        UIImageView * imageMax = [[UIImageView alloc]initWithFrame:CGRectMake(width *               (_arr.count +1),
                                                                              0,
                                                                              width,
                                                                              height)];
        UIImageView * imageView1 = [self viewWithTag:10];
        
        [_mainScrollView addSubview:imageMax];
        //在图片请求线程结束后 执行这个线程
        dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                image0.image = imageView.image;
                imageMax.image = imageView1.image;
            });
            
        });
        UILabel * textLabelMax = [[UILabel alloc]initWithFrame:CGRectMake(width * (_arr.count +1), height -20, width , 20)];
        
        textLabelMax.text = textArr[0];
        
        [_mainScrollView addSubview:textLabelMax];
        
        //自动滚动计时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(change) userInfo:nil repeats:YES];
        //添加小白点
        [self addPageControl];
    }
    return  self;
}

- (void)change{
    CGPoint point = CGPointMake(self.frame.size.width * _i, 0);
    [_mainScrollView setContentOffset:point animated:YES];
    _i++;
    if (_i == _arr.count+2) {
        _i = 1;
    }
}

#pragma mark ScrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self loop:scrollView];
    
    float offset_x = scrollView.contentOffset.x;
    _i = offset_x/self.frame.size.width;
    _pageControl.currentPage = _i - 1;
    
    
}

- (void)loop:(UIScrollView*)scrollView{
    if (scrollView.contentOffset.x == self.frame.size.width * (_arr.count +1)) {
        [scrollView setContentOffset:
                                    CGPointMake(self.frame.size.width, 0)];
    }
    if (scrollView.contentOffset.x == 0){
        [scrollView setContentOffset:
                                    CGPointMake(self.frame.size.width * (_arr.count), 0)];
    }
}

//显示多少白点
- (void)addPageControl{
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(self.frame.size.width - (_arr.count * 5) -20, self.frame.size.height-10, _arr.count * 5, 10)];
    _pageControl.numberOfPages = _arr.count ;
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    [self addSubview:_pageControl];
}


- (void)tap:(UITapGestureRecognizer*)tap{
    [self.delegate doSomethingWithIndex:(int)tap.view.tag];
    
}



@end
