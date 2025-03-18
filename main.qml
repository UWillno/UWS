import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3

// import QtQuick.Controls.Material
ApplicationWindow {
    id:window
    width: 640
    height: 480
    visible: true
    title: "UWS"
    // FluentWinUI3

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "<"
                font.pointSize: 20
                // enabled: stack.depth !==1
                opacity: stack.depth === 1 ? 0 : 1
                onClicked:
                    if(stack.depth !==1)
                        stack.pop()
            }
            Label {
                text: "UWS"
                font.pointSize: 16
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: "⚙"
                font.pointSize: 20
                // visible: false
                onClicked: UWS.setStoragePermission()
            }
        }
    }
    StackView {
        id: stack
        anchors.fill: parent
        initialItem: IndexPage{}
    }
    // closing:
    onClosing: (close)=>{
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
            close.accepted = false;
            // if (menu.isShown) menu.hide();
            if (stack.depth > 1) stack.pop();
            else Qt.quit();
        }
    }


}
