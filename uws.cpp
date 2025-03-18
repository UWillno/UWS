#include "uws.h"

#include <QProcess>

extern "C"
    JNIEXPORT void JNICALL
    Java_com_uwillno_uws_SZK_signal(JNIEnv *env,jobject obj,jstring info){
    emit UWS::instance()->info(env->GetStringUTFChars(info,0));
}
extern "C"
    JNIEXPORT void JNICALL
    Java_com_uwillno_uws_Shell_signal(JNIEnv *env,jobject obj,jstring info){
    emit UWS::instance()->info(env->GetStringUTFChars(info,0));
}
// UWS::UWS(QObject *parent)
//     : QObject{parent}
// {}

void UWS::execByShizuku(QString command)
{
    emit info(tr("通过shizuku执行中"));
    emit info(szk.callMethod<jstring>("execCommand",command).toString());
}

void UWS::execByRoot(QString command)
{
    (void)QtConcurrent::run(
        [&]{
            Shell shell;
            String c = QJniObject::fromString(command);
            String result =  shell.callStaticMethod<String>("exec",c);
            emit this->info(result.toString());
        }
        );
}

void UWS::execByRoot(QString command, QQuickItem *item)
{
    if(item){
        if(!itemList.contains(item)) {
            // qDebug() << itemList.length();
            itemList << item;
            auto future =QtConcurrent::run(
                [&]{
                    Shell shell;
                    String c = QJniObject::fromString(command);
                    String result =  shell.callStaticMethod<String>("exec",c);
                    return result.toString();
                });/*.then([&](QString res){
                    QMetaObject::invokeMethod(QApplication::instance(), [=]{
                        if(item){
                            itemList.removeOne(item);
                            item->setProperty("text",res);
                        }
                    }, Qt::QueuedConnection);
                });*/
            QFutureWatcher<QString> *watcher = new QFutureWatcher<QString>(this);
            watcher->setFuture(future);
            QObject::connect(watcher,&QFutureWatcher<QString>::finished,this,[=]{
                if(item){
                    itemList.removeOne(item);
                    item->setProperty("text",watcher->result());
                }
                watcher->deleteLater();
                // watcher->result();
            });
        }
    }

}

void UWS::test(QObject *object)
{
    // qDebug() << object.;
    object->setProperty("text","asdadsasdasd");
}

void UWS::setStoragePermission()
{
    // if(!hasStoragePermission()){
    String filepermit = Settings::getStaticField<String>("ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
    String pkgName = QJniObject::fromString("package:com.uwillno.uws");
    Uri parseUri = Uri::callStaticMethod<Uri>("parse",pkgName);
    Intent intent(filepermit,parseUri);
    Context context = QNativeInterface::QAndroidApplication::context();
    context.callMethod<void>("startActivity",intent);
    // }
}

bool UWS::hasStoragePermission()
{
    return Environment::callStaticMethod<jboolean>("isExternalStorageManager");
}

QProcess::ProcessState UWS::pState() const
{
    return m_pState;
}

void UWS::setPState(const QProcess::ProcessState &newPState)
{
    if (m_pState == newPState)
        return;
    m_pState = newPState;
    emit pStateChanged();
}

// void UWS::setItemText(QString text, QQuickItem *item)
// {
//     // item.set
//     if(item)
//         item->setProperty("text",text);

// }

void UWS::execByProcess(QString command)
{
    if(p.state() == QProcess::Running){
        p.write((command + "\n").toUtf8());
    }else {
        emit processReply(tr("程序还未启动"));
    }
}

void UWS::toggleProcess(QString program)
{
    if(p.state() == QProcess::Running || p.state() == QProcess::Starting){
        p.terminate();
        p.kill();
    }else {
        p.start(program);
    }
}


void UWS::initShizuku()
{
    szk.callMethod<void>("initShizuku");
}

// void UWS::initProcess()
// {
//     // p.start("su");
//     // emit info("尝试获取root权限");
//     // // p.waitForFinished();
//     // p.start("whoami");
//     // p.startCommand()
//     // // p.waitForFinished();
//     // QString output = p.readAllStandardOutput().trimmed();

//     // if (output == "root") {
//     //     emit info("已获取root权限");
//     // } else {
//     //     emit info("未取得root权限");
//     // }
// }
