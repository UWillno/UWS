import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
Page {
    StackView.onRemoved: {
        if(UWS.pState!==0){
            UWS.toggleProcess(programField.text)
        }
        destroy()
    }
    Component.onCompleted: {
        if(UWS.pState===0){
            UWS.toggleProcess(programField.text)
        }
    }

    Settings {
        property alias program: programField.text
    }
    property string pState: {
        switch(UWS.pState){
        case 0:
            return qsTr("未启动")
        case 1:
            return qsTr("启动中")
        case 2:
            return qsTr("运行中")
        default:
            return qsTr("未知状态")
        }
    }
    header:ColumnLayout{
        RowLayout{
            Layout.fillWidth: true
            Layout.margins: 5
            TextField {
                id:programField
                Layout.fillWidth: true
                placeholderText:qsTr("程序")
                text:"sh"
            }
        }
        RowLayout{
            Layout.fillWidth: true
            Layout.margins: 5
            Label {
                Layout.fillWidth: true
                text:qsTr("状态：") + pState
            }
            Button {
                text:qsTr("切换")
                onClicked: {
                    UWS.toggleProcess(programField.text)
                }
            }
        }
    }

    contentItem :
        Item {
        clip:true
        ListView {
            id:listView
            spacing: 5
            anchors.fill: parent
            anchors.margins: 5
            delegate: Loader {
                property string content: model.content
                sourceComponent: type ==="exec" ? execCom : replyCom
            }
            model:ListModel {
                id:listModel
                onCountChanged: {
                    listView.positionViewAtIndex(listView.count - 1, ListView.End)
                }
            }
        }
    }
    Component {
        id:execCom
        Label {
            width: listView.width
            text:content
            wrapMode:"WrapAnywhere"
        }
    }
    Component {
        id:replyCom
        Flickable {
            id:flick
            width: listView.width
            height: Math.min(resultArea.contentHeight,200)
            TextArea.flickable: TextArea{
                id:resultArea
                readOnly: true
                selectByMouse: false
                text:content
                width: parent.width
                wrapMode: "WrapAnywhere"
                onTextChanged:flick.contentY = 0
            }
        }
    }
    Connections{
        target: UWS
        function onProcessReply(message){
            listModel.append({content:message,type:"result"})

        }
    }

    footer: ColumnLayout{
        RowLayout{
            Layout.fillWidth: true
            Layout.margins: 10
            TextField {
                id:commandField
                Layout.fillWidth: true
                placeholderText:qsTr("命令")
            }
            Button {
                text:qsTr("执行")
                onClicked: {
                    if(UWS.pState === 2 && commandField.text!=="" ){

                        listModel.append({
                                             content:commandField.text,
                                             type:"exec"
                                         })
                        UWS.execByProcess(commandField.text)
                        commandField.text = ""
                    }
                }
            }
        }
    }
}
