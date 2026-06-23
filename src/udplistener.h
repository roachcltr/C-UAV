#pragma once

#include <QObject>
#include <QUdpSocket>
#include <QVariantMap>

class UdpListener : public QObject {
    Q_OBJECT

public:
    explicit UdpListener(QObject *parent = nullptr);

signals:
    // This signal will broadcast structured telemetry records right into QML
    void trackUpdated(const QVariantMap &trackData);

private slots:
    void readPendingDatagrams();

private:
    QUdpSocket *m_udpSocket;
};