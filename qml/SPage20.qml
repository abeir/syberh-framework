import QtQuick 2.0
import QtQuick.Window 2.2
import QtWebEngine 1.5
import QtWebChannel 1.0
import com.syberos.basewidgets 2.0
import com.syberos.api 2.0
import "../js/util/log.js" as LOG
import "../js/syber.js" as Syberh

SWebview{

    id:spage
    surl:"file://" + helper.getWebRootPath() + "/index.html"
    Component.onCompleted: {
        LOG.logger.verbose("SPage20:onCompleted ,url:[%s]",spage.surl)
        Syberh.init(spage,spage, '2.0')
    }
}
