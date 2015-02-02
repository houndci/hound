Namespaced = {
  'declare': function(namespace) {
    var parts = namespace.split('.');
    var scope = window;

    for (var i = 0; i < parts.length; i++) {
      var part = parts[i];

      if (scope[part]) {
        scope = scope[part];
      } else {
        scope = scope[part] = {};
      }
    }
  }
};
