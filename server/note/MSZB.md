#### 简单的屏幕适配相关问题
**什么是DPI，如何计算？**
DPI（Dots Per Inch），指每一英寸长度中，可显示输出的像素个数
DPI的数值受屏幕尺寸和分辨率所影响

例子：
屏幕：6.5寸
屏幕最佳分辨率：1920x1080
$$DPI=\frac{\sqrt{1920^2 + 1080^2}}{6.5} = 500$$

**dip与px的关系**
px即像素pixel是构成图像的最小单位
dip：Desity Independent pixels的缩写，即密度无关像素
在android内部图像识别像素以160dpi为基准，1dip=1px或1dp=1px
480 * 320 160dpi 那么这台机器上的1DP会被翻译成1px
800 * 480 240dpi 而这台机器上的1DP会被翻译成1.5px
也就是说当前我们设备的DP是由android给予的基础标准按比例进行翻译的，这也是为什么我们用DP能解决一部分适配的原因

**各种分辨率对应的像素密度范围**
|名称|像素密度范围|图片大小
|----|----|----|
|mdpi|120dp~160dp |48×48px
|hdpi|160dp~240dp | 72×72px
|xhdpi| 240dp~320dp |96×96px
|xxhdpi|320dp~480dp |144×144px
|xxxhdpi|480dp~640dp|192×192px

**常见的屏幕适配的方法**
- 使用``wrap_content``与``match_parent``
- 使用RelativeLayout
- 使用.9图片
- 使用限定符``small``、``large``等

**自定义布局方案**
方案原理：
根据一个参照分辨率进行布局，然后再各个机器上提取当前机器分辨率换算出系数，然后通过重新测量的方式达到适配效果，可以在app启动时获取当前屏幕参数。

先看Util工具类：
通过反射获取系统R.dimen的system_bar_height系统状态栏的高度，然后纵向高度减去状态栏高度就是安全区域的高度

```java

//参照宽高
public final float STANDARD_WIDTH = 1080;
public final float STANDARD_HEIGHT = 1920;

//当前设备实际宽高
public float displayMetricsWidth ;
public float displayMetricsHeight ;

//这些可以在app启动过程中获取，只要获取一次就可以了
WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);

//加载当前界面信息
DisplayMetrics displayMetrics = new DisplayMetrics();
windowManager.getDefaultDisplay().getMetrics(displayMetrics);

if(displayMetricsWidth == 0.0f || displayMetricsHeight == 0.0f){
    //获取状态框信息
    
    try {
        Class<?> clazz = Class.forName("com.android.internal.R$dimen");
        Object r = clazz.newInstance();
        Field field = clazz.getField(systemid);
        int x = (int) field.get(r);
        int systemBarHeight =  context.getResources().getDimensionPixelOffset(x);

    } catch (Exception e) { 
    }

    //横屏
    if(displayMetrics.widthPixels > displayMetrics.heightPixels){
        this.displayMetricsWidth = displayMetrics.heightPixels;
        this.displayMetricsHeight = displayMetrics.widthPixels - systemBarHeight;
    }else{
        //竖屏
        this.displayMetricsWidth = displayMetrics.widthPixels;
        this.displayMetricsHeight = displayMetrics.heightPixels - systemBarHeight;
        }
    }
```

对外方法：
```java
//对外提供系数
public float getHorizontalScaleValue(){
    return displayMetricsWidth / STANDARD_WIDTH;
}

public float getVerticalScaleValue(){

    return displayMetricsHeight / STANDARD_HEIGHT;
}
```

再看自定义布局：
继承RelativeLayout，重写onMeasure方法，在这个方法里面遍历子view给他们设置修正后的宽高，从而达到适配的效果

```java
@Override
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    //isFlag防止重复测量
    if(isFlag){
        int count = this.getChildCount();
        float scaleX =  UIUtils.getInstance(this.getContext()).getHorizontalScaleValue();
        float scaleY =  UIUtils.getInstance(this.getContext()).getVerticalScaleValue();

        for (int i = 0;i < count;i++){
            View child = this.getChildAt(i);
            //代表的是当前空间的所有属性列表
            LayoutParams layoutParams = (LayoutParams) child.getLayoutParams();
            layoutParams.width = (int) (layoutParams.width * scaleX);
            layoutParams.height = (int) (layoutParams.height * scaleY);
            layoutParams.rightMargin = (int) (layoutParams.rightMargin * scaleX);
            layoutParams.leftMargin = (int) (layoutParams.leftMargin * scaleX);
            layoutParams.topMargin = (int) (layoutParams.topMargin * scaleY);
            layoutParams.bottomMargin = (int) (layoutParams.bottomMargin * scaleY);
        }
        isFlag = false;
    }
    super.onMeasure(widthMeasureSpec, heightMeasureSpec);
}
```




