//
//  ViewController.m
//  ContacesTest
//
//  Created by yuelixing on 2019/6/14.
//  Copyright © 2019 Ylx. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import "Logger.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, retain) CNContactStore * contactStore;

@property (nonatomic, retain) NSMutableArray * contectArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.statusLabel.text = @"Loading";
    [self.statusLabel sizeToFit];
    
    [self requestAuth];
}

- (void)requestAuth {
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self.statusLabel.text = @"已授权";
                [self loadData];
            } else {
                self.statusLabel.text = @"未授权";
            }
            [self.statusLabel sizeToFit];
        });
    }];
}

- (void)loadData {
    NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    
    // 3.3.请求联系人
    [self.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact,BOOL * _Nonnull stop) {
        
        // 获取联系人全名
        NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        
        name = name.length > 0 ? name : @"无名氏" ;
//        UIImage * headImage = [UIImage imageWithData:contact.thumbnailImageData];
        
        // 获取一个人的所有电话号码
        NSArray * phones = contact.phoneNumbers;
        
        [self.contectArray addObject:contact];
        NSLog(@"%@", contact);
        NSLog(@"%@", name);
        for (CNLabeledValue *labelValue in phones)
        {
            CNPhoneNumber * phoneNumber = labelValue.value;
            NSLog(@"%@", phoneNumber.stringValue);
//            NSString * mobile = [self removeSpecialSubString:phoneNumber.stringValue];
//
//            if (mobile) {
//                PPPersonModel * model = [PPPersonModel new];
//                model.name = name;
//                model.headerImage = headImage;
//                model.phone = mobile;
//
//                //将联系人模型回调出去
//                personModel ? personModel(model) : nil;
//            }
        }
//        *stop = YES;
    }];
    self.statusLabel.text = [NSString stringWithFormat:@"当前共有%ld联系人", self.contectArray.count];
    [self.statusLabel sizeToFit];
}


- (IBAction)deleteButtonClick:(id)sender {
    NSLog(@"%@", self.contectArray);
    NSMutableArray * successArray = [[NSMutableArray alloc] init];
    //创建修改语句
    for (CNContact * temp in self.contectArray) {
        NSString * name = [CNContactFormatter stringFromContact:temp style:CNContactFormatterStyleFullName];
        
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
        CNMutableContact * target = [temp mutableCopy];

        [saveRequest deleteContact:target];

        //执行语句
        NSError * error = nil;
        [self.contactStore executeSaveRequest:saveRequest error:&error];
        if (error == nil) {
            NSLog(@"删除成功 %@", name);
            [successArray addObject:temp];
        } else {
            NSLog(@"删除失败 %@", error);
        }
    }
    [self.contectArray removeObjectsInArray:successArray];
    NSLog(@"%@", self.contectArray);
    self.statusLabel.text = [NSString stringWithFormat:@"删除%ld条联系人",successArray.count];
    [self.statusLabel sizeToFit];
}


- (CNContactStore *)contactStore {
    if (!_contactStore) {
        _contactStore = [[CNContactStore alloc] init];
    }
    return _contactStore;
}
- (NSMutableArray *)contectArray {
    if (!_contectArray) {
        _contectArray = [[NSMutableArray alloc] init];
    }
    return _contectArray;
}
@end
