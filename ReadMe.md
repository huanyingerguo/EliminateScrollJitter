##Function

解决NSTableView 滚动条位置变动的时候，通过增加『消除去抖』模块，解决用户不经意间的触发滚动条，导致多次过于触发底层的『位置变动事件』，从而多次跟业务方（数据库，网络等）要数据，导致界面卡住的问题。

### EliminateJitter
滚动条去抖动： 去抖动助手，通过定时轮训标识状态，判断业务方的状态是否稳定。每次定时轮徐的时候，到时间后内部复位Not Running.
若相邻两次运行状态都是Not Running，则认为没有抖动。


### LoadBalancer
UI刷新均衡器: 负载均衡器，通过确保时间间隔里，最多触发2次回调（首次回调与最后一次回调），从而控制调用频次。

### 判断NSTableView 滚动到底部
1.监听ScrollView的ContentView的尺寸变动事件
2.判断滚动条的滚动位置scrollPosition(即docvisibleRect.origin.y）是否超出默认范围 （0, docHeight-contHeight）
3. scrollPosition <= 0,说明触顶
4. scrollPosition > docHeight-contHeight,说明触底部


