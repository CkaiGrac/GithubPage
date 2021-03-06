## Flutter性能优化小技巧

看了于潇老师的flutter性能测试与理论的演讲，特此整理一下。
演讲中主要说明了UI渲染的测试和优化方法
我简单还原了演讲中的demo，也会在本文最后提供demo下载地址。

### 一、如何知道UI渲染的性能？
最简单的方法是，打开android studio的Flutter Inspector然后再打开Performance面板，在Performance里面我们就能够查看当前的渲染时间。因为debug模式与最后release模式有很大的性能区别，所以建议在测试的时候使用真机的profile模式，proflie模式的性能在两者之间。
![profile mode打开方式](/assets/startprofile.png)
IDE中点击那个按钮或者在命令行下使用``flutter run --profile``这个命令，这样就能以profile模式启动flutter程序了。

![performance](/assets/profilemode.png)
上面这张图就是flutter程序运行时渲染的耗时，可以看到有一个16ms的虚线，低于16ms可以认为在一帧以内就完成了渲染，此时性能表现是优秀的。如果大量高于16ms，性能表现就会下降，此时应该考虑UI渲染上是否出了问题。

### 二、进一步分析
通过上面IDE自带的小工具，我们能通过当前的渲染速度判断是否有性能问题，接下来先看看android、ios的UI渲染责任部件。
对于android来说，渲染最耗时的部分就是测量(measure)、布局(layout)、绘制(draw)
![android](/assets/androidView.png)

对于ios来说，大部分的时间都消耗在遍历图层树上。
![ios](/assets/iosView.png)

对于flutter来说，它的RenderObject跟android的View、ios的UIView一样，它是一个长寿命、有状态的UI单位，但是相比于View和UIView，RenderObject是轻量的。
![RenderObject](/assets/flutterRender.png)

> 在flutter里面，声明式的系统同步地融入在了每一帧的渲染过程中，就是layout上面的build过程。

演讲中主要讲了build过程和paint过程的优化。

假如一颗widget树中一个节点发生变化，如下面的Text的属性A变成了B
```dart
Container(
    color:Colors.blue,
    child:Row(
        children:<Widget>[
            Image.network('.../1.png'),
-           Text('A'),
+           Text('B'),
        ],
    ),
)
```
![widget tree](/assets/sameType.png)
由于Text发生了变化，在遍历widget树时，这个Text就会被标记，那么在下一帧的时候就会重新生成一颗widget树，重新布局，重新绘制Text节点。


#### 1. 提高Build效率
flutter提供了一些build过程的调试工具，只要加入到代码的任何一个地方即可
- debugPrintBeginFrameBanner
  - 没帧开始/结束
- debugPrintScheduleBuildForStacks
  - 为什么被构建
- debugPrintRebuildDirtyWidgets
  - 什么组件被重新构建了
- debugProfileBuildsEnabled
  - 在观测台里显示构建树

注：这些调试工具会影响flutter程序运行的速度，建议用debug模式

还是使用一开始的demo，来调试、优化
下面使用flutter的观测台（Observatory）查看每一帧的渲染，在flutter Inspector面板中的More Actions选择Open Observatory，网页形式，建议用chrome打开
![图片](/assets/openob.png)

点击view timeline，然后选择Record Streams，最后点右上角的Refresh。
![图片](/assets/timeline.png)

刷新界面后点击左边栏圈出来的，然后可以通过``alt+鼠标滚轮``来缩放时间区间
![图片](/assets/flutterUI.png)

然后去寻找每一帧所执行的过程，如下图所示：
![build](/assets/build.png)
由于页面上只有一个Text在不断被更新，但是build却很耗时间，那么接下来就要查看build过程中的具体细节，可以使用之前提到的调试工具，在任何一个地方加入这一行代码，比如在main中加入
```dart
void main() {
    //在观测台里显示构建树
  debugProfileBuildsEnabled = true;
  runApp(new MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.white,
    ),
    home: MyPage(),
  ));
}
```
添加完这个flag，重新启动flutter程序，然后再打开观测台timeline，这时就会发现多了很多内容，如下图所示的就是build过程中每一帧的渲染情况：
![buildflag](/assets/buildflag.png)
每一帧渲染都经历非常多的层级，可以直观的看出应用效率上的问题，所以会导致性能下降。虽然看上去我们只改变了很小一部分的UI但是每次却遍历大部分的节点，每次遍历都是从顶层MyPage开始的。

优化的思想有：一是降低遍历的出发点，二是停止树的遍历。
![方法](/assets/method.png)


##### 降低遍历的出发点
来看一下代码
```dart

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int promoAmount = 0;

  @override
  void initState() {
    super.initState();
    promotions.listen((int count) {
      //mounted为系统变量，可以点进去看注释
      if (mounted) {
        setState(() { promoAmount = count; });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('小店'),),
      body: Column(children: <Widget>[
--------------------------------------
          MyCard(
              ...
            child: Stack(
              children: <Widget>[...],
            ), ),//MyCard

          SizedBox(
            ...
            child: ListView(
              children: <Widget>[.....],
              ),),//SizedBox

          MyCard(
            ...
            child: Stack(children: <Widget>[
                OverflowBox(
                  alignment: Alignment.topLeft,
                  child: Container(
                      ...
                    decoration: BoxDecoration(...),
                    child: Text(promoAmount.toString()),
                ....
              ],),),),
--------------------------------------
            ),//Mycard
        ],),//Column
  }
}
```
虚线中间三个Widget对应了程序的三个模块，仔细分析一下代码就会发现：promoAmount的改变导致了Widget树的更新，而promoAmount是来自顶层MyPageState的变量。
promoAmount在顶层的initState()中监听了外界的值，每当count变化时，都会调用setState去刷新Widget树。
这就是问题的来源。

解决办法很简单，只需要把这个Text部件抽离出来，让它自己在内部更新状态。

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('小店'),),
      body: Column(children: <Widget>[
--------------------------------------
          MyCard(
              ...
            child: Stack(
              children: <Widget>[...],
            ), ),//MyCard

          SizedBox(
            ...
            child: ListView(
              children: <Widget>[.....],
              ),),//SizedBox

          MyCard(
            ...
            child: Stack(children: <Widget>[
                OverflowBox(
                  alignment: Alignment.topLeft,
                  child: Container(
                      ...
                    decoration: BoxDecoration(...),
                    child: Badge(),
                ....
              ],),),),
--------------------------------------
            ),//Mycard
        ],),//Column
  }
}

///把Text抽离出来，做成有状态的部件
class Badge extends StatefulWidget {
  @override
  _BadgeState createState() => _BadgeState();
}

class _BadgeState extends State<Badge> {
  int promoAmount = 0;

  @override
  void initState() {
    super.initState();
    promotions.listen((int count) {
      //mounted为系统变量，可以点进去看注释
      if (mounted) {
        setState(() {
          promoAmount = count;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(promoAmount.toString());
  }
}
```
完成修改后，reload app，再次打开观测台查看build过程的渲染情况
![修改后](/assets/after1.png)
可以看到有了明显的改善，build过程不再臃肿，每次只更新Badge下的Text部件。舒服多了。
这就是降低遍历的出发点思想。

##### 停止树的遍历
![停止树的遍历](/assets/stopit.png)
如果更新的界面不影响一部分子树，那么就把这个子树切下来加到新一帧的下面，这样遍历的时候，碰到同一实例的节点的时候就会停止遍历。
![cut](/assets/cuttree.png)

演讲中以SlideTransition举了一个例子：
![SlideTransition](/assets/slideTransition.gif)
```dart
SlideTransition(
  .....
  child: Row(....)
)
```

大概的意思是，SlideTransition每一帧都会对自己叫更新，给他提供一个child，而这个child是一个实例的子树，每次SlideTransition更新的时候把child放在SlideTransition之下，那么这个子树就不会跟着SlideTransition同时遍历。


```dart
class _AnimatedState extends State<AnimatedWidget> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_handleChange);
  }
  @override
  void didUpdateWidget(AnimatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_handleChange);
      widget.listenable.addListener(_handleChange);
    }
  }
  void _handleChange() {
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }
  ....
}
```
翻了一下源码，可能是在``didUpdateWidget``中，判断当前listenable与oldWidget的listenable是否一致，如果不一致就叫更新，一致就不做操作。


#### 2. 提高Paint效率
flutter也提供了一些paint过程的调试工具，只要加入到代码的任何一个地方即可。
- debugDumpLayerTree
  - 查看layer树
- debugPaintLayerBordersEnabled
  - 查看layer界限
- debugRepaintRainbowEnabled
  - 被重新绘制的RenderObject
- debugProfilePaintsEnabled
  - 在观测台里显示绘制树

仍然用刚才的demo做演示。

首先我们在main函数里面加上两个配置参数：
```dart
void main() {
  debugProfileBuildsEnabled = true;
+  debugProfilePaintsEnabled = true; //在观测台里显示绘制树
+  debugPaintLayerBordersEnabled = true; //查看layer界限

  runApp(....);
}
```

hot reload一下会发现，界面上的布局多了边缘线，可以很清晰的看到布局的层级关系

![border](/assets/border.png)

在观测台中paint过程如下:

![border](/assets/nopaintb.png)

仔细观察可以发现，小红点其实是跟深蓝色widget共享图层的，因此在每次更新的时候，小红点中的数字变化会整个重新绘制深蓝色widget。
这时候我们可以使用RepaintBoundary，包裹在OverflowBox之上，hot reload一下，发现图层有了新的变化，但是似乎有些问题。
![repaint](/assets/repaintb.png)

RepaintBoundary的好处在于它会截断图层形成一个新的图层，截断的理由是因为小红点里面的数字每次都在paint，如果不截断，整个深蓝色widget就会跟着repaint，进行了没必要的绘制。
加上了RepaintBoundary之后，小红点的图层就和深蓝色widget图层分离了，也就是说每次只会单独绘制小红点所在的图层，对于简单的布局看不出啥，但是布局一旦复杂起来性能就会有所影响。
所以善加利用RepaintBoundary，积少成多会对性能改善会有帮助。

下图就是加上RepaintBoundary之后的paint过程的情况了。

![border](/assets/afterpaint.png)


最后这篇文章中整理了一些改善UI渲染性能的方法和理论，如果内容有误请务必指正
文中配套demo在这： [https://git.code.oa.com/bakichen/flutter_demo](https://git.code.oa.com/bakichen/flutter_demo)

结束。


