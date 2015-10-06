#include "Authenticate.h"
#include "WebPage.h"
#include "NetworkAccessManager.h"
#include "WebPageManager.h"

Authenticate::Authenticate(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Authenticate::start() {
  QString username = arguments()[0];
  QString password = arguments()[1];

  NetworkAccessManager* networkAccessManager = manager()->networkAccessManager();
  networkAccessManager->setUserName(username);
  networkAccessManager->setPassword(password);

  finish(true);
}

