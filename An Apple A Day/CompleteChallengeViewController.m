//
//  CompleteChallengeViewController.m
//  An Apple A Day
//
//  Created by Alice Jia Qi Liu on 12/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "CompleteChallengeViewController.h"

@interface CompleteChallengeViewController ()

@end

@implementation CompleteChallengeViewController

- (id)init {
    self = [super initWithNibName:@"CompleteChallengeViewController" bundle:nil];
    if (self != nil) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeChallenge:(id)sender {
    NSDictionary *properties = @{@"text":_textView.text,
                                 @"image":_imageView.image};
    [_presenter updateCompletedDailyChallengeWithProperties:properties];
    [self dismissViewControllerAnimated:YES completion:nil];

    // Quickly dismiss, then save to built
    BuiltObject *obj = [BuiltObject objectWithClassUID:@"usersChallenges"];
    [obj setReference:[_presenter.globalKeyValueStore getValueforKey:kBuiltUserUID]
               forKey:@"user"];
    [obj setReference:[_presenter.challenge objectForKey:@"uid"]
               forKey:@"challenge"];
    [obj setObject:_textView.text forKey:@"comment"];
    
    [obj saveOnSuccess:^{
        // object is created successfully
        NSLog(@"initial update, modal is done.");
    } onError:^(NSError *error) {
        // there was an error in creating the object
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", @"ERROR");
        NSLog(@"%@", error.userInfo);
    }];

    BuiltFile *imgFile = [BuiltFile file];
    if (_imageView.image != nil) {
        [imgFile setImage:_imageView.image forKey:@"image"];
        [imgFile saveOnSuccess:^ {
            //file successfully uploaded
            //file properties are populated
            
            NSLog(@"Image up, uid: %@", imgFile.uid);
            
            [obj setObject:[NSArray arrayWithObjects: imgFile.uid, nil]
                    forKey:@"files"];
            
            [obj saveOnSuccess:^{
                // object is created successfully
                NSLog(@"Secondary update, image attached");
            } onError:^(NSError *error) {
                // there was an error in creating the object
                // error.userinfo contains more details regarding the same
                NSLog(@"%@", @"ERROR");
                NSLog(@"%@", error.userInfo);
            }];
        } onError:^(NSError *error) {
            //error in uploading
        }];
    }
    
    BuiltFile *videoFile = [BuiltFile file];
    if (_videoUrl != nil) {
        [videoFile setFile:[[NSBundle mainBundle] pathForResource:_videoUrl ofType:@"mov"] forKey:@"movie"];
        [videoFile saveOnSuccess:^ {
            //file successfully uploaded
            //file properties are populated
            
            NSLog(@"Video up, uid: %@", videoFile.uid);
            
            [obj setObject:[NSArray arrayWithObjects: videoFile.uid, nil]
                    forKey:@"files"];
            
            [obj saveOnSuccess:^{
                // object is created successfully
                NSLog(@"Secondary update, video attached");
            } onError:^(NSError *error) {
                // there was an error in creating the object
                // error.userinfo contains more details regarding the same
                NSLog(@"%@", @"ERROR");
                NSLog(@"%@", error.userInfo);
            }];
        } onError:^(NSError *error) {
            //error in uploading
        }];
    }
}

- (IBAction)useCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (IBAction)useImages:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = NO;
    }
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        _imageView.image = image;
        
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        _videoUrl = [url relativePath];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
        player.view.frame = CGRectMake(0, 200, 400, 300);
        [self.view addSubview:player.view];
        
        if (_newMedia)
            UISaveVideoAtPathToSavedPhotosAlbum(_videoUrl,
                                                self,
                                                @selector(video:didFinishSavingWithError:contextInfo:),
                                                nil);
    }
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save video"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
