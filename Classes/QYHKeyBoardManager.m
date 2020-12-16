//
//  QYHKeyBoardManager.m
//  qyhKeyBoardManager
//
//  Created by Qiu on 16/4/3.
//  Copyright © 2016年 YongHuaiQIu. All rights reserved.
//

#import "QYHKeyBoardManager.h"

@interface QYHKeyBoardManager ()
@property (nonatomic, assign) CGFloat textFieldY;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect newFrame;
@property (nonatomic, assign) BOOL isShow;//是否改变了
@property (nonatomic, assign) BOOL isDidShow;//判断键盘已经完成弹起
@property (nonatomic, strong) UIView *oldTextView;//
@property (nonatomic, strong) NSNotification *oldNoti;
@end

@implementation QYHKeyBoardManager

static QYHKeyBoardManager *manager=nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QYHKeyBoardManager alloc]init];
        manager.keyBoardTop = 30.0f;
    });
    
    return manager;
}

#pragma mark 监听键盘事件
- (void)KeyboardWillShow:(NSNotification *)noti{
    self.oldNoti = noti;
    self.isDidShow = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //获取键盘的frame
        CGRect keboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        //获取键盘动画时间
        CGFloat timeLength  = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        //如果键盘没遮盖就不上移
        if (self.textFieldY < keboardFrame.origin.y){
            self.isShow = NO;
            self.isDidShow = YES;
            return;
        }
        
        self.newFrame = self.selfView.frame;
        //偏移值+30   **********这里可以更改弹起的高度*************
        self->_newFrame.origin.y = - ( self.textFieldY - keboardFrame.origin.y + self.keyBoardTop) + self.selfView.frame.origin.y;
        //如果偏移值大于键盘的高度就只偏于键盘的高度
        if (-self.newFrame.origin.y > keboardFrame.size.height){
            self->_newFrame.origin.y = -keboardFrame.size.height;
        }
        
        if (!self.isShow) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //设置Text的动画
                [UIView animateWithDuration:timeLength animations:^{
                    self.selfView.frame = self.newFrame;
                    //注意这里不是改变值，之前已经改变值了，
                    //在这里需要做的事强制布局
                    [self.selfView layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.isShow = NO;
                    self.isDidShow = YES;
                }];
            });
        }
        
        self.isShow = YES;
    });
}

- (void)KeyboardWillHide:(NSNotification *)noti{
    self.isDidShow = NO;
    self.isShow = NO;
    //获取键盘动画时间
    CGFloat timeLength = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //还原原来的frame
    self.selfView.frame = self.oldFrame;
    //设置Text的动画
    [UIView animateWithDuration:timeLength animations:^{
        //注意这里不是改变值，之前已经改变值了，
        //在这里需要做的事强制布局
        [self.selfView layoutIfNeeded];
    }];
}

//实现通知方法
- (void)textChange:(NSNotification *)notification{
    //    NSLog(@"notification==%@",notification.object);
    self.selfView.frame = self.oldFrame;
    
    if (self.oldTextView) {
        if (self.oldTextView != [notification object]) {
            self.isShow = NO;
        }
    }else{
        self.isShow = NO;
    }
    self.oldTextView = [notification object];
    
    if ([[notification object] isKindOfClass:[UITextField class]]){
        UITextField *textField = [notification object];
        [self convertRectFromView:textField oldFrame:textField.frame];
    }else{
        UITextView *textView = [notification object];
        [self convertRectFromView:textView oldFrame:textView.frame];
    }
    
    if (self.isDidShow) {
        [self KeyboardWillShow:self.oldNoti];
    }
}


#pragma mark 重写set方法
-(void)setSelfView:(UIView *)selfView{
    _selfView = selfView;
    
    [self setup];
}

- (void)setup{
    [self keyboardHide];
    [self removeObserver];
    
    if (self.selfView) {
        [self addObserver];
    }
    
    self.oldFrame = self.selfView.frame;
    
    //添加键盘掉落事件(针对UIScrollView或者继承UIScrollView的界面)
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.selfView addGestureRecognizer:tapGestureRecognizer];
}

//取得textFiled和textView在self.selfView的位置frame
- (void)convertRectFromView:(UIView *)view oldFrame:(CGRect)oldFrame{
    CGRect rect = [[UIApplication sharedApplication].keyWindow convertRect:oldFrame fromView:[view superview]];
    self.textFieldY = CGRectGetMaxY(rect);
}


#pragma mark 触摸其他地方掉下键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.isDidShow) {
         [self.selfView endEditing:YES];
    }
}

-(void)keyboardHide{
    if (self.isDidShow) {
        [self.selfView endEditing:YES];
    }
}

#pragma mark - 添加通知
- (void)addObserver{
    //设置通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (textChange:)name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (textChange:)name:UITextViewTextDidBeginEditingNotification object:nil];
    //监听键盘抬起
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘键盘掉下
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 移除通知
-(void)removeObserver{
//    NSLog(@"QYHKeyBoardManagerViewController--dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
}


@end
