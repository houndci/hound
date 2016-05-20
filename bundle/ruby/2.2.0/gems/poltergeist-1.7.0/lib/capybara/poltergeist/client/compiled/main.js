var Poltergeist, system, _ref, _ref1, _ref2,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Poltergeist = (function() {
  function Poltergeist(port, width, height) {
    var that;
    this.browser = new Poltergeist.Browser(this, width, height);
    this.connection = new Poltergeist.Connection(this, port);
    that = this;
    phantom.onError = function(message, stack) {
      return that.onError(message, stack);
    };
    this.running = false;
  }

  Poltergeist.prototype.runCommand = function(command) {
    var error;
    this.running = true;
    try {
      return this.browser.runCommand(command.name, command.args);
    } catch (_error) {
      error = _error;
      if (error instanceof Poltergeist.Error) {
        return this.sendError(error);
      } else {
        return this.sendError(new Poltergeist.BrowserError(error.toString(), error.stack));
      }
    }
  };

  Poltergeist.prototype.sendResponse = function(response) {
    return this.send({
      response: response
    });
  };

  Poltergeist.prototype.sendError = function(error) {
    return this.send({
      error: {
        name: error.name || 'Generic',
        args: error.args && error.args() || [error.toString()]
      }
    });
  };

  Poltergeist.prototype.send = function(data) {
    if (this.running) {
      this.connection.send(data);
      return this.running = false;
    }
  };

  return Poltergeist;

})();

window.Poltergeist = Poltergeist;

Poltergeist.Error = (function() {
  function Error() {}

  return Error;

})();

Poltergeist.ObsoleteNode = (function(_super) {
  __extends(ObsoleteNode, _super);

  function ObsoleteNode() {
    _ref = ObsoleteNode.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  ObsoleteNode.prototype.name = "Poltergeist.ObsoleteNode";

  ObsoleteNode.prototype.args = function() {
    return [];
  };

  ObsoleteNode.prototype.toString = function() {
    return this.name;
  };

  return ObsoleteNode;

})(Poltergeist.Error);

Poltergeist.InvalidSelector = (function(_super) {
  __extends(InvalidSelector, _super);

  function InvalidSelector(method, selector) {
    this.method = method;
    this.selector = selector;
  }

  InvalidSelector.prototype.name = "Poltergeist.InvalidSelector";

  InvalidSelector.prototype.args = function() {
    return [this.method, this.selector];
  };

  return InvalidSelector;

})(Poltergeist.Error);

Poltergeist.FrameNotFound = (function(_super) {
  __extends(FrameNotFound, _super);

  function FrameNotFound(frameName) {
    this.frameName = frameName;
  }

  FrameNotFound.prototype.name = "Poltergeist.FrameNotFound";

  FrameNotFound.prototype.args = function() {
    return [this.frameName];
  };

  return FrameNotFound;

})(Poltergeist.Error);

Poltergeist.MouseEventFailed = (function(_super) {
  __extends(MouseEventFailed, _super);

  function MouseEventFailed(eventName, selector, position) {
    this.eventName = eventName;
    this.selector = selector;
    this.position = position;
  }

  MouseEventFailed.prototype.name = "Poltergeist.MouseEventFailed";

  MouseEventFailed.prototype.args = function() {
    return [this.eventName, this.selector, this.position];
  };

  return MouseEventFailed;

})(Poltergeist.Error);

Poltergeist.JavascriptError = (function(_super) {
  __extends(JavascriptError, _super);

  function JavascriptError(errors) {
    this.errors = errors;
  }

  JavascriptError.prototype.name = "Poltergeist.JavascriptError";

  JavascriptError.prototype.args = function() {
    return [this.errors];
  };

  return JavascriptError;

})(Poltergeist.Error);

Poltergeist.BrowserError = (function(_super) {
  __extends(BrowserError, _super);

  function BrowserError(message, stack) {
    this.message = message;
    this.stack = stack;
  }

  BrowserError.prototype.name = "Poltergeist.BrowserError";

  BrowserError.prototype.args = function() {
    return [this.message, this.stack];
  };

  return BrowserError;

})(Poltergeist.Error);

Poltergeist.StatusFailError = (function(_super) {
  __extends(StatusFailError, _super);

  function StatusFailError() {
    _ref1 = StatusFailError.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  StatusFailError.prototype.name = "Poltergeist.StatusFailError";

  StatusFailError.prototype.args = function() {
    return [];
  };

  return StatusFailError;

})(Poltergeist.Error);

Poltergeist.NoSuchWindowError = (function(_super) {
  __extends(NoSuchWindowError, _super);

  function NoSuchWindowError() {
    _ref2 = NoSuchWindowError.__super__.constructor.apply(this, arguments);
    return _ref2;
  }

  NoSuchWindowError.prototype.name = "Poltergeist.NoSuchWindowError";

  NoSuchWindowError.prototype.args = function() {
    return [];
  };

  return NoSuchWindowError;

})(Poltergeist.Error);

phantom.injectJs("" + phantom.libraryPath + "/web_page.js");

phantom.injectJs("" + phantom.libraryPath + "/node.js");

phantom.injectJs("" + phantom.libraryPath + "/connection.js");

phantom.injectJs("" + phantom.libraryPath + "/browser.js");

system = require('system');

new Poltergeist(system.args[1], system.args[2], system.args[3]);
