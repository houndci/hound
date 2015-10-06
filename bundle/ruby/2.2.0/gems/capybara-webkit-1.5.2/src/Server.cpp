#include "Server.h"
#include "Connection.h"
#include "WebPageManager.h"

#include <QTcpServer>

Server::Server(QObject *parent) : QObject(parent) {
  m_tcp_server = new QTcpServer(this);
}

bool Server::start() {
  connect(m_tcp_server, SIGNAL(newConnection()), this, SLOT(handleConnection()));
  return m_tcp_server->listen(QHostAddress::LocalHost, 0);
}

quint16 Server::server_port() const {
  return m_tcp_server->serverPort();
}

void Server::handleConnection() {
  QTcpSocket *socket = m_tcp_server->nextPendingConnection();
  new Connection(socket, new WebPageManager(this), this);
}
