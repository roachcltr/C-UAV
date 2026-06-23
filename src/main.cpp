#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "udplistener.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Instantiate your background processing link
    UdpListener listener;
    
    // Register the component directly into the context environment of your QML canvas
    engine.rootContext()->setContextProperty("udpNetworkBackend", &listener);

    const QUrl url(u"qrc:/RadarFrontend/qml/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);

    return app.exec();
}