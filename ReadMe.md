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

###TableCellView复用问题，导致渲染出错解决
1. 统一Cell上的附属子视图刷新关联的，入口API：如refreshCellView.

2. 相应NSTableView的Delegate事件，准备获取Cell
```
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    VideoMemberListCellView *cellView = [self.memberTableView makeViewWithIdentifier:@"VideoMemberListCellView" owner:self];
}
```

3. 更新Cell关联的新Model数据。

4. 确保所有属性更新完毕后，调用1中的API，刷新Cell。
注意：这里的刷新，需要确保Cell里面的SubView && subView's SubView. 跟随绑定的Model来刷新所有级别的子视图。
如：NSTextFiled, NSIamgeView, NSBbutton, Other CustomView.

####Cell复用：
1.复用会导致Cell上的子视图，会残留上一个视图的Model数据。导致展示错误。

2.比如『上一个成员的入会状态』 与 【当前成员的状态本不相同】。
但是，刷新某个"间接（非直接关系）依赖于状态"的子控件的时候，先用『状态』刷新了视图。 后面更新了【当前成员的状态】。
（这里有个错误前提：理所当然的认为，只要状态存在有效值，则认为这个状态是真实的状态）

3.确保影响因子，正确更新后，才刷新对应的视图。



