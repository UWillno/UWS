import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
Page {
    id:page
    header:
        ColumnLayout{
        RowLayout{
            Layout.fillWidth: true
            Layout.margins: 10
            TextField {
                id:commandTextFeild
                Layout.fillWidth: true
            }
            Button{
                text:qsTr("执行")
                onClicked: {
                    rootSwitch.checked ?
                                execByRoot(commandTextFeild.text) : execByShizuku(commandTextFeild.text)
                }
            }
            Switch{
                id:rootSwitch
                text:checked ? "Root" : "Shizuku"
                onCheckedChanged: {
                    // checked ? UWS.initProcess() :  UWS.initShizuku()
                    if(!checked) UWS.initShizuku()
                }
                Component.onCompleted: {
                    // checked ? UWS.initProcess() :  UWS.initShizuku()
                    if(!checked) UWS.initShizuku()
                }

            }
        }
    }

    property string commands : JSON.stringify([
                                                  {name:qsTr("恢复DPI和分辨率"),command:'wm density reset;wm size reset'},
                                                  {name:"1080p",command:'wm density 240 ;wm size 1080x1920'},
                                                  {name:"cd && ls",command:"cd /sdcard && ls"},
                                              ])

    property var commandsModel: JSON.parse(commands)

    Settings {
        property alias cs: page.commands
        property alias isRoot: rootSwitch.checked

    }
    contentItem :Item {
        clip:true
        ListView {
            id:listview
            anchors.margins: 10
            anchors.fill: parent
            model:JSON.parse(commands)
            spacing: 10
            onModelChanged:{
                listview.positionViewAtIndex(count-1,ListView.End)
            }

            delegate:
                Column {
                width:listview.width
                height:  rootSwitch.checked ? nameLabel.height + buttonRow.height+ flick.height + 50
                                            : nameLabel.height + buttonRow.height + 20
                spacing: 10
                Behavior on height {
                    SpringAnimation { spring: 2; damping: 0.2 }
                }
                clip:true
                Label {
                    id:nameLabel
                    width: parent.width
                    fontSizeMode: Label.Fit
                    text:modelData.name
                    maximumLineCount: 1
                    elide: Label.ElideRight
                    TapHandler{
                        onTapped: {
                            flick.height =  flick.height !==0 ? 0:Math.min(100,itemResultTextArea.contentHeight)
                        }
                    }
                }
                Row {
                    id:buttonRow
                    // Layout.alignment: Qt.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Button {
                        text:qsTr("运行")
                        // onClicked: UWS.test(itemResultTextArea)

                        onClicked:rootSwitch.checked ? execByRoot(modelData.command,itemResultTextArea) : execByShizuku(modelData.command)
                    }
                    Button {
                        text:qsTr("修改")
                        onClicked: {
                            setDialog.index = index
                            setDialog.open()
                        }
                    }
                    Button {
                        text:qsTr("删除")
                        onClicked: {
                            // const m = JSON.parse(commands)
                            commandsModel.splice(index, 1)
                            commands = JSON.stringify(commandsModel)
                        }
                    }
                }
                Flickable {
                    id:flick
                    height:Math.min(100,itemResultTextArea.contentHeight)
                    width: parent.width
                    TextArea.flickable: TextArea {
                        id:itemResultTextArea
                        readOnly: true
                        width: parent.width
                        Connections {
                            target: rootSwitch
                            function onCheckedChanged(){
                                itemResultTextArea.text = ""
                            }
                        }
                    }
                }
            }

        }
    }
    Dialog {
        id:setDialog
        width: parent.width*3/4
        anchors.centerIn: parent
        title: qsTr("设置")
        property int index: -1

        onIndexChanged: {
            if(index >= 0){
                const obj =  commandsModel[index]
                nameField.text = obj.name
                commandField.text = obj.command
            }else {
                nameField.text = ""
                commandField.text = ""
            }
        }
        contentItem: Column {
            id:col
            width: parent.width
            spacing:10
            TextField {
                id:nameField
                width: parent.width
                placeholderText: qsTr("名称")
            }
            TextField {
                id:commandField
                width: parent.width
                placeholderText: qsTr("c1&&c2;c3")
            }
        }
        standardButtons: Dialog.Ok
        onAccepted:{
            if(nameField.text!=="" && commandField.text!==""){
                const obj = { name: nameField.text,
                    command:commandField.text,
                }
                // const m = JSON.parse(commands)
                if(setDialog.index === -1){
                    commandsModel.push(obj)
                }else {
                    commandsModel[setDialog.index] = obj
                    setDialog.index = -1
                }
                commands = JSON.stringify(commandsModel)
                nameField.text=""
                commandField.text=""
            }

        }
    }

    function execByRoot(command,item=null){
        if(item!==null)
            UWS.execByRoot(command,item)
        else
            UWS.execByRoot(command)
        // UWS.execByProcess(command)
    }

    function execByShizuku(command){
        UWS.execByShizuku(command)
    }

    footer:
        Column {
        spacing: 10
        // Behavior on height {
        //     SpringAnimation { spring: 2; damping: 0.2 }
        // }
        RowLayout {
            // Layout.fillWidth: true
            width: parent.width - 2*x
            x:5
            Button {
                text: qsTr("交互式")
                onClicked: {
                    const com = Qt.createComponent("InteractivePage.qml").createObject()
                    stack.push(com)
                }
            }
            Button {
                Layout.fillWidth: true
                text:"+"
                onClicked: {
                    setDialog.index = -1
                    setDialog.open()
                }
            }
        }
        Row {
            width: parent.width - 2*x
            x:5
            Flickable {
                Behavior on height {
                    SpringAnimation { spring: 2; damping: 0.2 }
                }
                width: parent.width
                height:rootSwitch.checked ? 50 : 100
                TextArea.flickable: TextArea {
                    id:resultTextArea
                    readOnly: true
                }
            }
        }

    }

    Connections {
        target: UWS
        function onInfo(info){
            resultTextArea.text = info
        }
    }

}
