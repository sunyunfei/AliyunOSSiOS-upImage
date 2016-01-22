//
//  ViewController.m
//  上传图片
//
//  Created by 孙云 on 16/1/22.
//  Copyright © 2016年 haidai. All rights reserved.
//

#import "ViewController.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonHMAC.h>
NSString * const AccessKey = @"－－－－－－－－－";
NSString * const SecretKey = @"－－－－－－－－－";
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    OSSClient * client;
}
@property(nonatomic,strong)NSData *imageData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 100);
    btn.backgroundColor =[UIColor redColor];
    [btn addTarget:self action:@selector(upImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
/**
 *  按钮事件
 */
- (void)upImage
{
    [self loadImagePicker];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  压缩图片尺寸
 *
 *  @param image   图片
 *  @param newSize 大小
 *
 *  @return 真实图片
 */
- (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{

    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  进入相册方法
 */
-(void)loadImagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate                 = self;
    picker.sourceType               = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing            = YES;
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *avatar = info[UIImagePickerControllerOriginalImage];
    //处理完毕，回到个人信息页面
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //判断图片是不是png格式的文件
    if (UIImagePNGRepresentation(avatar)) {
        //返回为png图像。
        UIImage *imagenew = [self imageWithImageSimple:avatar scaledToSize:CGSizeMake(200, 200)];
        self.imageData = UIImagePNGRepresentation(imagenew);
    }else {
        //返回为JPEG图像。
        UIImage *imagenew = [self imageWithImageSimple:avatar scaledToSize:CGSizeMake(200, 200)];
        self.imageData = UIImageJPEGRepresentation(imagenew, 0.1);
    }
#warning 参数设置
    NSString *endpoint = @"----------";
    // 明文设置secret的方式建议只在测试时使用，更多鉴权模式参考后面链接给出的官网完整文档的`访问控制`章节
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey
                                                                                                            secretKey:SecretKey];
    client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    // required fields
#warning 参数设置
    put.bucketName = @"---------";
    NSString *objectKeys = [NSString stringWithFormat:@"User/%@.jpg",[self getTimeNow]];
    
    put.objectKey = objectKeys;
    //put.uploadingFileURL = [NSURL fileURLWithPath:fullPath];
    put.uploadingData = self.imageData;
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        task = [client presignPublicURLWithBucketName:@"-------"
                                        withObjectKey:objectKeys];
        NSLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {

            NSLog(@"upload object success!");

        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
    
    
}
/**
 *  返回当前时间
 *
 *  @return <#return value description#>
 */
- (NSString *)getTimeNow
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    date = [formatter stringFromDate:[NSDate date]];
    //取出个随机数
    int last = arc4random() % 10000;
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@-%i", date,last];
    NSLog(@"%@", timeNow);
    return timeNow;
}
@end
