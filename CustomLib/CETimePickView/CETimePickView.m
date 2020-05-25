//
//  CETimePickView.m
//  CETimeSelector
//
//  Created by zhouzhongliang on 2020/5/22.
//  Copyright © 2020 zhouzhongliang. All rights reserved.
//

#import "CETimePickView.h"
#import "Masonry.h"
#import "UIView+CETimeCategory.h"

// 屏幕宽度
#define CEScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define CEScreenHeight [UIScreen mainScreen].bounds.size.height

#define CEColor(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:1]

@interface CETimePickView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) UIView *naviContainView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIPickerView *pickView;

@property (nonatomic, strong) UIButton *bgBtn;

@property (nonatomic, strong) UIView *mainView;

@end

@implementation CETimePickView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
        self.titleLabel.text = title;
    }
    return self;
}

- (void)setupChildViews {
    
    [self addSubview:self.bgBtn];
    [self addSubview:self.mainView];
    
    [self.mainView addSubview:self.naviContainView];
    [self.naviContainView addSubview:self.cancelBtn];
    [self.naviContainView addSubview:self.titleLabel];
    [self.naviContainView addSubview:self.confirmBtn];
    [self.mainView addSubview:self.pickView];
    
    [self.bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.mainView setFrame:CGRectMake(0, CEScreenHeight, CEScreenWidth, 260)];
    
    [self.naviContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.mainView);
        make.height.mas_equalTo(44);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.centerY.equalTo(self.naviContainView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.naviContainView);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.equalTo(self.naviContainView);
    }];
    
    [self.pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviContainView.mas_bottom);
        make.left.right.bottom.equalTo(self.mainView);
    }];
}

#pragma mark - private methods

- (void)cancelAction:(UIButton *)btn {
    [self dismiss];
}

- (void)confirmAction:(UIButton *)btn {
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(pickView:confirmButtonClick:)]) {
        [self.delegate pickView:self confirmButtonClick:btn];
    }
}

#pragma mark - public methods

- (void)show {
    
    self.bgBtn.alpha = 0.3;
    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.y = CEScreenHeight - 260;
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.y = CEScreenHeight;
        self.bgBtn.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    [self.pickView selectRow:row inComponent:component animated:animated];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component {
    return [self.pickView selectedRowInComponent:component];
}

#pragma mark - UIPickViewDelegate, UIPickViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.dataSource numberOfComponentsInPickerView:self];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.dataSource pickerView:self numberOfRowsInComponent:component];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
        return [self.delegate pickerView:self titleForRow:row forComponent:component];
    }else{
        return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        return [self.delegate pickerView:self didSelectRow:row inComponent:component];
    }
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.delegate respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)]) {
        return [self.delegate pickerView:self attributedTitleForRow:row forComponent:component];
    }else{
        return nil;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    //普通状态的颜色
   UILabel* norLabel = (UILabel*)view;
   if (!norLabel){
       norLabel = [[UILabel alloc] init];
       norLabel.textColor = [UIColor blackColor];
       norLabel.adjustsFontSizeToFitWidth = YES;
       [norLabel setTextAlignment:NSTextAlignmentCenter];
       [norLabel setBackgroundColor:[UIColor grayColor]];
       [norLabel setFont:[UIFont systemFontOfSize:13]];
   }
   norLabel.text = [self pickerView:pickerView
                           titleForRow:row
                          forComponent:component];
   //当前选中的颜色
   UILabel *selLb = (UILabel*)[pickerView viewForRow:row forComponent:0];
   if (selLb) {
       selLb.textColor = [UIColor blackColor];
       selLb.adjustsFontSizeToFitWidth = YES;
       [selLb setTextAlignment:NSTextAlignmentCenter];
       [selLb setBackgroundColor:[UIColor grayColor]];
       [selLb setFont:[UIFont systemFontOfSize:16]];
   }
   return norLabel;
}

#pragma mark - getter methods

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:CEColor(85, 85, 85) forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelBtn sizeToFit];
    }
    return _cancelBtn;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] init];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:CEColor(255, 126, 0) forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmBtn sizeToFit];
    }
    return _confirmBtn;
}

- (UIView *)naviContainView {
    if (!_naviContainView) {
        _naviContainView = [[UIView alloc] init];
        _naviContainView.backgroundColor = [UIColor whiteColor];
    }
    return _naviContainView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"title";
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

- (UIPickerView *)pickView {
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] init];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}

- (UIButton *)bgBtn {
    if (!_bgBtn) {
        _bgBtn = [[UIButton alloc] init];
        _bgBtn.backgroundColor = [UIColor blackColor];
        _bgBtn.alpha = 0.3;
        [_bgBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgBtn;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = [UIColor whiteColor];
    }
    return _mainView;
}

- (void)pickReloadComponent:(NSInteger)component{
    [self.pickView reloadComponent:component];
}

- (void)reloadData{
    [self.pickView reloadAllComponents];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
