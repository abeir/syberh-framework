import QtQuick 2.0
import QtQuick.Window 2.2
import com.syberos.filemanager.filepicker 1.0
import com.syberos.basewidgets 1.0
import com.syberos.basewidgets 2.0
import syberh_filepicker 1.0
import QtWebEngine 1.5
import QtWebChannel 1.0
import QtQml.Models 2.2

import "../js/util/log.js" as LOG
import "./"
import "./CMenu"


CPage{
    id: webView
    //加载进度信号
    signal sloadProgress(var loadProgress)

    //加载信号
    signal sloadingChanged(var loadRequest)
    //返回键信号
    signal keyOnReleased(var event)
    //接受消息信号
    signal receiveMessage(var message)
    //导航栏关闭信号
    signal navigationBarClose()

    property string surl:""

    //页面标题
    property string title: ""

    // 导航栏标题
    property string navigationBarTitle: ""

    //背景色
    property string color: ""

    //设置背景色
    function setBackgroundColor(color){
        root.color = color;
    }

    // 展示navigatorBar
    function showNavigatorBar(title){
       sNavigationBar.show(title);
    }

    // 设置NavigationBar Title
    function setNavigationBarTitle(title){
        //设置navigatorBar title
        LOG.logger.verbose('-----------------set title',title);
        sNavigationBar.show(title);
    }

    // 获取导航栏是否可用
    function getNavigationBarStatus() {
        return sNavigationBar.visible
    }

    function clearHistory(){
        //TODO 暂无找到实现方式
    }
    //是否能回退
    function canGoBack(){
        return swebview.canGoBack;
    }

    //删除所有cookies
    function deleteAllCookies()
    {
        swebview.experimental.deleteAllCookies()
    }

    function canGoForward(){
        return swebview.canGoForward
    }

    //Go backward within the browser's session history, if possible. (Equivalent to the window.history.back() DOM method.)
    function goBack(){
        swebview.goBack();
        swebview.forceActiveFocus()
    }
    //Go forward within the browser's session history, if possible. (Equivalent to the window.history.forward() DOM method.)
    function goForward(){
        swebview.goForward();
    }

    //return the swebview
    function getWebview(){
        return swebview
    }
    //Returns true if the HTML page is currently loading, false otherwise.
    function loading(){
        return swebview.loading;
    }
    //return swebview url
    function getCurrentUrl(){
        return swebview.url.toString();
    }
    //打开url
    function openUrl(url){
        LOG.logger.verbose('swebview openUrl()',url)
        if(swebview.loading){
            LOG.logger.verbose('swebview loading',swebview.loading)
            swebview.stop();
        }
        if(swebview.url.toString()===url){
            return;
        }

        swebview.url=url;

    }
    //停止当前所有动作
    function stop(){
        swebview.stop();
    }
    //重新加载webview
    function reload(url){
        swebview.stop();
        swebview.reload();
        swebview.forceActiveFocus()
    }
    //执行JavaScript代码
    function evaluateJavaScript(res){


    }
    Keys.onReleased: {
        LOG.logger.verbose('SWebview qml Keys.onReleased',Keys.onReleased)
        keyOnReleased(event)
        //event.accepted = true
    }

    contentAreaItem:Rectangle{
        id:root
        anchors.fill:parent
        SNavigationBar{
            id: sNavigationBar
            closeCurWebviewEnable: swebview.canGoBack
            onGoBack: {
                if(swebview.canGoBack) {
                    // 当前webview有history && history.length>1，走这里返回上一个history
                    swebview.goBack();
                } else {
                    // 当前webview有history && history.length==1，直接关闭当前webview
                    navigationBarClose();
                }
            }
            onCloseCurWebview:{
                navigationBarClose();
            }
        }
        ObjectModel {
            id: trans
            WebChannel.id: "trans"
            function postMessage(msg){
              console.log('@@@@@@@@@@>>>>>>>>>>>>>>>>', msg)
            }
        }

        WebChannel {
            id: channel
            registeredObjects: [trans]
        }
        WebEngineView {
            id: swebview
            focus: true
            signal downLoadConfirmRequest
            property url curHoverUrl: ""
            anchors {
                top: sNavigationBar.visible ? sNavigationBar.bottom : parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            url:surl

            profile: WebEngineProfile{
              httpUserAgent: "Mozilla/5.0 (Linux; Android 4.4.2; GT-I9505 Build/JDQ39) SyberOS "+helper.aboutPhone().osVersion+";"
            }

            property bool _autoLoad: true

            onLinkHovered: {
                curHoverUrl= hoveredUrl
            }
            property string navigateUrl: ""
            property string telNumber: ""
            onNavigationRequested: {
                var logger=LOG.logger;
                logger.verbose("onNavigationRequested request.navigationType:",request.navigationType)
                logger.verbose("onNavigationRequested",helper.getWebRootPath())
            }

            onUrlChanged: {
                LOG.logger.verbose('SWebview onUrlChanged',loadProgress)
            }

            onLoadProgressChanged: {
                LOG.logger.verbose('SWebview qml onLoadProgressChanged',loadProgress)
                sloadProgress(loadProgress)
            }

            onLoadingChanged:{
                LOG.logger.verbose('SWebview qml onLoadingChanged',loadRequest.status,loadRequest.url)
                if (!loading && loadRequest.status === WebEngineLoadRequest.LoadFailedStatus){
                    LOG.logger.error('SWebview qml onLoadingChanged 加载失败')
                    //swebview.loadHtml("加载失败 " + loadRequest.url, "", loadRequest.url)
                    //swebview.reload();
                }
                if(!loading && loadRequest.status===WebEngineLoadRequest.LoadSucceededStatus){
                    sloadingChanged(loadRequest);
                }

            }
        }
        

    }


    Component.onCompleted: {
        //设置是否显示状态栏，应与statusBarHoldItemEnabled属性一致
        gScreenInfo.setStatusBar(true);
        console.log('新建页面传入的参数--', navigationBarTitle)
        if(navigationBarTitle){
            showNavigatorBar(navigationBarTitle);
        }
        //设置状态栏样式，取值为"black"，"white"，"transwhite"和"transblack"
        //gScreenInfo.setStatusBarStyle("transblack");
    }
}
