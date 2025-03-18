#ifndef UWS_H
#define UWS_H

#include <QObject>
#include <QApplication>
#include <QQuickItem>
// #include <QProcess>
#include <QtConcurrent>
#include <QFuture>
using namespace QtJniTypes;
Q_DECLARE_JNI_CLASS(Shizuku,"com/uwillno/uws/SZK")
Q_DECLARE_JNI_CLASS(Shell,"com/uwillno/uws/Shell")
Q_DECLARE_JNI_CLASS(Environment,"android/os/Environment");
Q_DECLARE_JNI_CLASS(Settings,"android/provider/Settings");
class UWS : public QObject
{
    Q_OBJECT
public:
        // explicit UWS(QObject *parent = nullptr);
    Q_PROPERTY(QProcess::ProcessState pState READ pState WRITE setPState NOTIFY pStateChanged FINAL)

    Q_INVOKABLE void initShizuku();


    // Q_INVOKABLE void initProcess();
    // Q_INVOKABLE void testShizuku();

    Q_INVOKABLE void execByShizuku(QString command);

    Q_INVOKABLE void execByProcess(QString command);

    Q_INVOKABLE void toggleProcess(QString program);

    Q_INVOKABLE void execByRoot(QString command);

    Q_INVOKABLE void execByRoot(QString command,QQuickItem *item);

    static UWS* instance() {
        static UWS uws;
        return &uws;
    }

    Q_INVOKABLE void test(QObject *object);

    Q_INVOKABLE void setStoragePermission();

    Q_INVOKABLE bool hasStoragePermission();

    QProcess::ProcessState pState() const;
    void setPState(const QProcess::ProcessState &newPState);

private slots:
               // void setItemText(QString text,QQuickItem *item);
signals:
    void info(QString info);
    void processReply(QString message);
    void pStateChanged();

private:
    Shizuku szk;
    QList<QPointer<QQuickItem>> itemList;
    // QMap<>
    QProcess p;
    QProcess::ProcessState m_pState = p.state();
    UWS(){
        QObject::connect(&p, &QProcess::stateChanged,this, [&](QProcess::ProcessState newState) {
            setPState(newState);
        });
        connect(&p,&QProcess::readyRead,this,[&]{
            emit processReply(p.readAllStandardOutput());
        });
    };
    // ~UWS(){
    //     p->deleteLater();
    //     deleteLater();
    // }

};

#endif // UWS_H
