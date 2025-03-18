#include "uws.h"
#include <QGuiApplication>
// #include <QProcess>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQmlContext>
#include <QProcess>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    app.setOrganizationName("UWlab");
    app.setOrganizationDomain("uwillno.com");
    app.setApplicationName("UWS");
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    QLocale locale;
    QString language = locale.name();
    if (!language.startsWith("zh")) {
        QTranslator *tr = new QTranslator(&app);
        if(tr->load(":/translations/uws.qm")){
            app.installTranslator(tr);
            engine.retranslate();
        }
    }
    engine.rootContext()->setContextProperty("UWS",UWS::instance());
    engine.loadFromModule("UWS", "Main");


    return app.exec();
}
