//
//  ViewController.m
//  CETimeSelector
//
//  Created by zhouzhongliang on 2020/5/22.
//  Copyright © 2020 zhouzhongliang. All rights reserved.
//

#import "ViewController.h"
#import "CETimePickView.h"

#define CEScreenBounds [UIScreen mainScreen].bounds

@interface ViewController ()<CETimePickViewDelegate, CETimePickViewDataSource>{
    UIButton *_button;
}

@property (nonatomic,strong) CETimePickView * pickView;
@property (nonatomic,copy) NSDictionary * dateDic;
@property (nonatomic,copy) NSString * weekStr;
@property (nonatomic,copy) NSString * timeStr;
@property (nonatomic, strong) NSDate *selectDate;
@property (nonatomic, assign) NSInteger currentSelectDay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, (self.view.frame.size.height - 50)/2, 200, 50)];
    [self.view addSubview:_button];
    _button.backgroundColor = [UIColor cyanColor];
    [_button setTitle:@"显示时间" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick{
    self.dateDic = [self LHGetStartTime];
    self.weekStr = self.dateDic[@"week"][0];
    NSDate *date  = [[self.dateDic[@"time"] objectAtIndex:0] objectAtIndex:0];
    self.timeStr = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
    [self.pickView reloadData];
    UIWindow* window = nil;
    for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes){
        if (windowScene.activationState == UISceneActivationStateForegroundActive){
            window = windowScene.windows.firstObject;
            break;
        }
    }
    [window addSubview:self.pickView];
    [self.pickView show];
}

- (void)pickView:(CETimePickView *)pickerView confirmButtonClick:(UIButton *)button{
    NSInteger left = [pickerView selectedRowInComponent:0];
    NSInteger right = [pickerView selectedRowInComponent:1];
    self.selectDate = [[self.dateDic[@"time"] objectAtIndex:left] objectAtIndex:right];
    NSLog(@"select date = %@",[self XZGetTimeStringWithDate:self.selectDate dateFormatStr:@"yyyy-MM-dd HH:mm:ss"]);
    NSLog(@"select date = %@",[self XZGetTimeStringWithDate:self.selectDate dateFormatStr:@"yyyy-MM-dd HH:mm"]);
    NSLog(@"select date = %@",[self XZGetTimeStringWithDate:self.selectDate dateFormatStr:@"MM-dd HH:mm"]);
    [_button setTitle:[NSString stringWithFormat:@"%@",[self XZGetTimeStringWithDate:self.selectDate dateFormatStr:@"yyyy-MM-dd HH:mm"]] forState:UIControlStateNormal];
}

- (NSInteger)pickerView:(CETimePickView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    //时间
    if (component == 0) {
        return [self.dateDic[@"week"] count];
    }else{
        NSInteger whichWeek = [pickerView selectedRowInComponent:0];
        return [[self.dateDic[@"time"] objectAtIndex:whichWeek] count];
    }
}

- (void)pickerView:(CETimePickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(component == 0){
        self.currentSelectDay = [pickerView selectedRowInComponent:0];
        [pickerView pickReloadComponent:1];
        self.weekStr = self.dateDic[@"week"][row];
        NSArray *arr = [[self.dateDic objectForKey:@"time"] objectAtIndex:self.currentSelectDay];
        NSDate *date = [arr objectAtIndex:[pickerView selectedRowInComponent:1]];
        self.timeStr = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
    }else{
        NSInteger whichWeek = [pickerView selectedRowInComponent:0];
        NSDate *date = [[self.dateDic[@"time"] objectAtIndex:whichWeek] objectAtIndex:row];
        self.timeStr = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
    }
}

- (NSString *)pickerView:(CETimePickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0){
        return self.dateDic[@"week"][row];
    }else{
        NSArray *arr = [[self.dateDic objectForKey:@"time"] objectAtIndex:self.currentSelectDay];
        NSDate *date = [arr objectAtIndex:row];
        NSString *str = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
        return str;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(CETimePickView *)pickerView{
    return 2;
}

- (NSString *)XZGetTimeStringWithDate:(NSDate *)date dateFormatStr:(NSString *)dateFormatStr {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = dateFormatStr;
    return [format stringFromDate:date];
}

- (NSDictionary *)LHGetStartTime {
    // 获取当前date
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDictionary *weekDict = @{@"2" : @"周一", @"3" : @"周二", @"4" : @"周三", @"5" : @"周四", @"6" : @"周五", @"7" : @"周六", @"1" : @"周日"};
    // 日期格式
    NSDateFormatter *fullFormatter = [[NSDateFormatter alloc] init];
    fullFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    // 获取当前几时(晚上23点要把今天的时间做处理)
    NSInteger currentHour = [calendar component:NSCalendarUnitHour fromDate:date];
    // 存放周几和时间的数组
    NSMutableArray *weekStrArr = [NSMutableArray array];
    NSMutableArray *detailTimeArr = [NSMutableArray array];
    // 设置合适的时间
    NSArray *weekDayArray = [self getCurrentDayToLastServeDay];
    NSLog(@"weekDayArray = %@",weekDayArray);
    NSMutableArray *dayArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dic in weekDayArray) {
        NSString *day = dic[@"day"];
        [dayArray addObject:day];
    }
    NSLog(@"dayArray = %@",dayArray);
    int i = 0;
    for (NSString *days in dayArray) {
        NSDate *new = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:date options:NSCalendarMatchStrictly];
        NSInteger week = [calendar component:NSCalendarUnitWeekday fromDate:new];
        // 周几
        NSString *weekStr = weekDict[[NSString stringWithFormat:@"%ld",week]];
        // 今天周几 明天周几 后天周几
        NSString *resultWeekStr = [NSString stringWithFormat:@"%@ %@",days,weekStr];
        [weekStrArr addObject:resultWeekStr];
        
        NSInteger year = [calendar component:NSCalendarUnitYear fromDate:new];
        NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:new];
        NSInteger day = [calendar component:NSCalendarUnitDay fromDate:new];
        
        // 把符合条件的时间筛选出来
        NSMutableArray *smallArr = [NSMutableArray array];
        for (int hour = 0; hour < 24; hour++) {
            for (int min = 0; min < 60; min ++) {
                if (min % 30 == 0) {
                    NSString *tempDateStr = [NSString stringWithFormat:@"%ld-%ld-%ld %d:%d",year,month,day,hour,min];

                    NSDate *tempDate = [fullFormatter dateFromString:tempDateStr];
                    // 今天 之后的时间段
                    if (i == 0) {
                        if ([calendar compareDate:tempDate toDate:date toUnitGranularity:NSCalendarUnitHour] == 1) {
                            [smallArr addObject:tempDate];
                        }
                    }else{
                        [smallArr addObject:tempDate];
                    }
                }
            }
        }
        [detailTimeArr addObject:smallArr];
        i++;
    }
    // 晚上23点把今天对应的周几和今天的时间空数组去掉
    if (currentHour == 23) {
        [weekStrArr removeObjectAtIndex:0];
        [detailTimeArr removeObjectAtIndex:0];
    }
    NSDictionary *resultDic = @{@"week" : weekStrArr , @"time" : detailTimeArr};
    return resultDic;
}

#pragma mark - getter methods
- (CETimePickView *)pickView{
    if(!_pickView){
        _pickView = [[CETimePickView alloc]initWithFrame:CEScreenBounds title:@"请选择"];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}

//获取当前日期开始的七天日期
- (NSMutableArray *)getCurrentDayToLastServeDay{
    NSMutableArray *weekArr = [[NSMutableArray alloc] init];
    NSDate *nowDate = [NSDate date];
    //计算从当前日期开始的七天日期
    for (int i = 0; i < 7; i ++) {
           //从现在开始的24小时
           NSTimeInterval secondsPerDay = i * 24*60*60;
           NSDate *curDate = [NSDate dateWithTimeInterval:secondsPerDay sinceDate:nowDate];
           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           [dateFormatter setDateFormat:@"M月d日"];
           NSString *dateStr = [dateFormatter stringFromDate:curDate];//几月几号
        //自定义星期显示
        dateFormatter.weekdaySymbols = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
        //自定义日期显示
        dateFormatter.dateFormat = @" EEEE";
        NSString *weekStr = [dateFormatter stringFromDate:curDate];
        NSDictionary *dic = @{@"day":dateStr,@"week":weekStr};
        [weekArr addObject:dic];
       }
    return weekArr;
}

@end
