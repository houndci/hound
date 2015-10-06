#include "Headers.h"
#include "WebPage.h"
#include "WebPageManager.h"

Headers::Headers(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Headers::start() {
  finish(true, page()->pageHeaders().join("\n"));
}

