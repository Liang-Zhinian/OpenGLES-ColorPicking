//
//  CubeViewController.m
//  texture-coordinates
//
//  Created by sprite on 2018/11/28.
//  Copyright © 2018年 Christoph Halang. All rights reserved.
//

#import "CubeViewController.h"

@interface CubeViewController () {
}

@property (weak, nonatomic) IBOutlet CubeView *cubeView;

@end

@implementation CubeViewController

- (id)init
{
    if ( (self = [super init]) != nil)
    {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preferredFramesPerSecond = 60;
    self.cubeView.controller = self;
    [self.cubeView resize];
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
