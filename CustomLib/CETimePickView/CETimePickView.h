//
//  CETimePickView.h
//  CETimeSelector
//
//  Created by zhouzhongliang on 2020/5/22.
//  Copyright © 2020 zhouzhongliang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CETimePickView;

@protocol CETimePickViewDataSource <NSObject>

@required

- (NSInteger)numberOfComponentsInPickerView:(CETimePickView *)pickerView;

- (NSInteger)pickerView:(CETimePickView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

@protocol CETimePickViewDelegate <NSObject>

- (NSString *)pickerView:(CETimePickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (void)pickView:(CETimePickView *)pickerView confirmButtonClick:(UIButton *)button;

@optional
- (NSAttributedString *)pickerView:(CETimePickView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)componen;

- (void)pickerView:(CETimePickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

@interface CETimePickView : UIView

@property (nonatomic, weak) id<CETimePickViewDelegate> delegate;
@property (nonatomic, weak) id<CETimePickViewDataSource> dataSource;
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)show;
- (void)dismiss;
// 选中某一行
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
// 获取当前选中的row
- (NSInteger)selectedRowInComponent:(NSInteger)component;

//刷新某列数据
- (void)pickReloadComponent:(NSInteger)component;
//刷新数据
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
