//
//  ViewController.m
//  glkit金字塔
//
//  Created by lvAsia on 2020/8/2.
//  Copyright © 2020 yazhou lv. All rights reserved.
//https://github.com/zedlv/glkitPyramid

#import "ViewController.h"
typedef struct OPVertex{
    GLKVector3 positionCoord;
    GLKVector3 colorCoord;
    GLKMatrix2 tureCoord;
}OPVertex;

@interface ViewController ()
@property(nonatomic, strong) EAGLContext *myContext;
@property(nonatomic, strong) GLKBaseEffect *effect;
@property(nonatomic, assign) int count;

//旋转的度数
@property(nonatomic,assign)float XDegree;
@property(nonatomic,assign)float YDegree;
@property(nonatomic,assign)float ZDegree;

//是否旋转X,Y,Z
@property(nonatomic,assign) BOOL XB;
@property(nonatomic,assign) BOOL YB;
@property(nonatomic,assign) BOOL ZB;
@property(nonatomic, assign) OPVertex *vertices;
@end
static int const kCount = 8;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpcontext];
    [self render];
}

- (void)setUpcontext{
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    GLKView *view = (GLKView *)self.view;
    view.context = self.myContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
   BOOL isSuc =  [EAGLContext setCurrentContext:self.myContext];
    if (!isSuc){
        
        NSLog(@"setCurrentContext error");
        return;
    }
    glEnable(GL_DEPTH_TEST);
}
- (void)render{
    self.vertices = (OPVertex *)malloc(sizeof(OPVertex)*kCount);
    self.vertices[0] = (OPVertex){{-0.5f, 0.5f, 0.0f},{1.0f, 0.0f, 1.0f},{0.0f,1.0f}};
    self.vertices[1] = (OPVertex){{0.5f, 0.5f, 0.0f},{1.0f, 0.0f, 1.0f},{1.0f,1.0f}};
    self.vertices[2] = (OPVertex){{-0.5f, -0.5f, 0.0f},{1.0f, 1.0f, 1.0f},{0.0f,0.0f}};
    self.vertices[3] = (OPVertex){{0.5f, -0.5f, 0.0f},{1.0f, 1.0f, 1.0f},{1.0f,0.0f}};
    self.vertices[4] = (OPVertex){{0.0f, 0.0f, 1.0f},{0.0f, 1.0f, 0.0f},{0.5f,0.5f}};
    //绘图索引
    
    GLfloat attrArr[] =
        {
            -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
            0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f,       1.0f, 1.0f,//右上
            -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f,       0.0f, 0.0f,//左下
    
            0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f,       1.0f, 0.0f,//右下
            0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f,       0.5f, 0.5f,//顶点
        };
    GLuint indices[] =
       {
           0, 3, 2,
           0, 1, 3,
           0, 2, 4,
           0, 4, 1,
           2, 3, 4,
           1, 4, 3,
       };
    self.count = sizeof(indices) /sizeof(GLuint);
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(OPVertex)*kCount, self.vertices, GL_DYNAMIC_DRAW);
    
    GLuint bufferIndex;
    glGenBuffers(1, &bufferIndex);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufferIndex);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    
   
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(OPVertex), offsetof(OPVertex, positionCoord) + NULL);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(OPVertex), offsetof(OPVertex, colorCoord)+ NULL);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(OPVertex), offsetof(OPVertex,tureCoord)+ NULL);
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"iu" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"1",GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filepath options:options error:nil];
    
    //创建着色器
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
    self.effect.texture2d0.target = textureInfo.target;
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    
    GLKMatrix4 projectionMatirx = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1f, 150.f);
    projectionMatirx = GLKMatrix4Scale(projectionMatirx, 1.0f, 1.0f, 1.0f);
    self.effect.transform.projectionMatrix = projectionMatirx;
    
    GLKMatrix4 modelViewMatirx = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.effect.transform.modelviewMatrix = modelViewMatirx;
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.XDegree += 0.1f * self.XB;
        self.YDegree += 0.1f * self.YB;
        self.ZDegree += 0.1f * self.ZB ;
//        [self update];
    }];
    
}
- (void)update{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -2.5);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.XDegree);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.YDegree);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.ZDegree);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.1f, 0.3f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
}

- (IBAction)roteAction:(UIButton *)sender {
    _XB = !_XB;
    
}
- (IBAction)roteYaction:(UIButton *)sender {
    _YB = !_YB;
}
- (IBAction)roteZAction:(UIButton *)sender {
    _ZB = !_ZB;
}

@end
