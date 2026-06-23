#include "udplistener.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

UdpListener::UdpListener(QObject *parent) : QObject(parent) {
    m_udpSocket = new QUdpSocket(this);
    
    // Bind directly to port 12346 matching your C++ backend setup
    if (m_udpSocket->bind(QHostAddress::LocalHost, 12346)) {
        qDebug() << "[*] Qt UI listening for incoming target packets on port 12346...";
    } else {
        qCritical() << "[!] Failed to bind Qt interface to UDP port 12346!";
    }

    // Trigger an asynchronous read event whenever packets register on the socket buffer
    connect(m_udpSocket, &QUdpSocket::readyRead, this, &UdpListener::readPendingDatagrams);
}

void UdpListener::readPendingDatagrams() {
    while (m_udpSocket->hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(m_udpSocket->pendingDatagramSize());
        m_udpSocket->readDatagram(datagram.data(), datagram.size());

        // Standard validation of arriving JSON payloads
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(datagram, &parseError);
        
        if (parseError.error == QJsonParseError::NoError && doc.isObject()) {
            // Convert to a flexible QVariantMap that QML reads organically
            QVariantMap rawMap = doc.object().toVariantMap();
            emit trackUpdated(rawMap);
        } else {
            qWarning() << "Error parsing incoming JSON packet structure:" << parseError.errorString();
        }
    }
}