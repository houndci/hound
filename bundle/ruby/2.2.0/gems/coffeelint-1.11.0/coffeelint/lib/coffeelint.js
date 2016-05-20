!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.coffeelint=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

/*
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
 */
var ASTLinter, CoffeeScript, ERROR, ErrorReport, IGNORE, LexicalLinter, LineLinter, RULES, WARN, _rules, cache, coffeelint, defaults, difference, extend, hasSyntaxError, mergeDefaultConfig, nodeRequire, packageJSON, sameJSON,
  slice = [].slice,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

coffeelint = exports;

nodeRequire = require;

if (typeof window !== "undefined" && window !== null) {
  CoffeeScript = window.CoffeeScript;
}

if (CoffeeScript == null) {
  CoffeeScript = nodeRequire('coffee-script');
}

if (CoffeeScript == null) {
  throw new Error('Unable to find CoffeeScript');
}

packageJSON = require('./../package.json');

coffeelint.VERSION = packageJSON.version;

ERROR = 'error';

WARN = 'warn';

IGNORE = 'ignore';

coffeelint.RULES = RULES = require('./rules.coffee');

extend = function() {
  var destination, k, len, n, source, sources, v;
  destination = arguments[0], sources = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  for (n = 0, len = sources.length; n < len; n++) {
    source = sources[n];
    for (k in source) {
      v = source[k];
      destination[k] = v;
    }
  }
  return destination;
};

defaults = function(source, defaults) {
  return extend({}, defaults, source);
};

difference = function(a, b) {
  var j, ref, results;
  j = 0;
  results = [];
  while (j < a.length) {
    if (ref = a[j], indexOf.call(b, ref) >= 0) {
      results.push(a.splice(j, 1));
    } else {
      results.push(j++);
    }
  }
  return results;
};

LineLinter = require('./line_linter.coffee');

LexicalLinter = require('./lexical_linter.coffee');

ASTLinter = require('./ast_linter.coffee');

cache = null;

mergeDefaultConfig = function(userConfig) {
  var config, rule, ruleConfig, ruleLoader;
  try {
    ruleLoader = nodeRequire('./ruleLoader');
    ruleLoader.loadFromConfig(coffeelint, userConfig);
  } catch (_error) {}
  config = {};
  if (userConfig.coffeelint) {
    config.coffeelint = userConfig.coffeelint;
  }
  for (rule in RULES) {
    ruleConfig = RULES[rule];
    config[rule] = defaults(userConfig[rule], ruleConfig);
  }
  return config;
};

sameJSON = function(a, b) {
  return JSON.stringify(a) === JSON.stringify(b);
};

coffeelint.trimConfig = function(userConfig) {
  var config, dConfig, dValue, key, newConfig, ref, rule, value;
  newConfig = {};
  userConfig = mergeDefaultConfig(userConfig);
  for (rule in userConfig) {
    config = userConfig[rule];
    dConfig = RULES[rule];
    if (rule === 'coffeelint') {
      config.transforms = config._transforms;
      delete config._transforms;
      config.coffeescript = config._coffeescript;
      delete config._coffeescript;
      newConfig[rule] = config;
    } else if ((config.level === (ref = dConfig.level) && ref === 'ignore')) {
      void 0;
    } else if (config.level === 'ignore') {
      newConfig[rule] = {
        level: 'ignore'
      };
    } else {
      config.module = config._module;
      delete config._module;
      for (key in config) {
        value = config[key];
        if (key === 'message' || key === 'description' || key === 'name') {
          continue;
        }
        dValue = dConfig[key];
        if (value !== dValue && !sameJSON(value, dValue)) {
          if (newConfig[rule] == null) {
            newConfig[rule] = {};
          }
          newConfig[rule][key] = value;
        }
      }
    }
  }
  return newConfig;
};

coffeelint.invertLiterate = function(source) {
  var len, line, n, newSource, ref;
  source = CoffeeScript.helpers.invertLiterate(source);
  newSource = "";
  ref = source.split("\n");
  for (n = 0, len = ref.length; n < len; n++) {
    line = ref[n];
    if (line.match(/^#/)) {
      line = line.replace(/\s*$/, '');
    }
    line = line.replace(/^\s{4}/g, '');
    newSource += line + "\n";
  }
  return newSource;
};

_rules = {};

coffeelint.registerRule = function(RuleConstructor, ruleName) {
  var e, name, p, ref, ref1;
  if (ruleName == null) {
    ruleName = void 0;
  }
  p = new RuleConstructor;
  name = (p != null ? (ref = p.rule) != null ? ref.name : void 0 : void 0) || "(unknown)";
  e = function(msg) {
    throw new Error("Invalid rule: " + name + " " + msg);
  };
  if (p.rule == null) {
    e("Rules must provide rule attribute with a default configuration.");
  }
  if (p.rule.name == null) {
    e("Rule defaults require a name");
  }
  if ((ruleName != null) && ruleName !== p.rule.name) {
    e("Mismatched rule name: " + ruleName);
  }
  if (p.rule.message == null) {
    e("Rule defaults require a message");
  }
  if (p.rule.description == null) {
    e("Rule defaults require a description");
  }
  if ((ref1 = p.rule.level) !== 'ignore' && ref1 !== 'warn' && ref1 !== 'error') {
    e("Default level must be 'ignore', 'warn', or 'error'");
  }
  if (typeof p.lintToken === 'function') {
    if (!p.tokens) {
      e("'tokens' is required for 'lintToken'");
    }
  } else if (typeof p.lintLine !== 'function' && typeof p.lintAST !== 'function') {
    e("Rules must implement lintToken, lintLine, or lintAST");
  }
  RULES[p.rule.name] = p.rule;
  return _rules[p.rule.name] = RuleConstructor;
};

coffeelint.getRules = function() {
  var key, len, n, output, ref;
  output = {};
  ref = Object.keys(RULES).sort();
  for (n = 0, len = ref.length; n < len; n++) {
    key = ref[n];
    output[key] = RULES[key];
  }
  return output;
};

coffeelint.registerRule(require('./rules/arrow_spacing.coffee'));

coffeelint.registerRule(require('./rules/braces_spacing.coffee'));

coffeelint.registerRule(require('./rules/no_tabs.coffee'));

coffeelint.registerRule(require('./rules/no_trailing_whitespace.coffee'));

coffeelint.registerRule(require('./rules/max_line_length.coffee'));

coffeelint.registerRule(require('./rules/line_endings.coffee'));

coffeelint.registerRule(require('./rules/no_trailing_semicolons.coffee'));

coffeelint.registerRule(require('./rules/indentation.coffee'));

coffeelint.registerRule(require('./rules/camel_case_classes.coffee'));

coffeelint.registerRule(require('./rules/colon_assignment_spacing.coffee'));

coffeelint.registerRule(require('./rules/no_implicit_braces.coffee'));

coffeelint.registerRule(require('./rules/no_nested_string_interpolation.coffee'));

coffeelint.registerRule(require('./rules/no_plusplus.coffee'));

coffeelint.registerRule(require('./rules/no_throwing_strings.coffee'));

coffeelint.registerRule(require('./rules/no_backticks.coffee'));

coffeelint.registerRule(require('./rules/no_implicit_parens.coffee'));

coffeelint.registerRule(require('./rules/no_empty_param_list.coffee'));

coffeelint.registerRule(require('./rules/no_stand_alone_at.coffee'));

coffeelint.registerRule(require('./rules/space_operators.coffee'));

coffeelint.registerRule(require('./rules/duplicate_key.coffee'));

coffeelint.registerRule(require('./rules/empty_constructor_needs_parens.coffee'));

coffeelint.registerRule(require('./rules/cyclomatic_complexity.coffee'));

coffeelint.registerRule(require('./rules/newlines_after_classes.coffee'));

coffeelint.registerRule(require('./rules/no_unnecessary_fat_arrows.coffee'));

coffeelint.registerRule(require('./rules/missing_fat_arrows.coffee'));

coffeelint.registerRule(require('./rules/non_empty_constructor_needs_parens.coffee'));

coffeelint.registerRule(require('./rules/no_unnecessary_double_quotes.coffee'));

coffeelint.registerRule(require('./rules/no_debugger.coffee'));

coffeelint.registerRule(require('./rules/no_interpolation_in_single_quotes.coffee'));

coffeelint.registerRule(require('./rules/no_empty_functions.coffee'));

coffeelint.registerRule(require('./rules/prefer_english_operator.coffee'));

coffeelint.registerRule(require('./rules/spacing_after_comma.coffee'));

coffeelint.registerRule(require('./rules/transform_messes_up_line_numbers.coffee'));

coffeelint.registerRule(require('./rules/ensure_comprehensions.coffee'));

coffeelint.registerRule(require('./rules/no_this.coffee'));

coffeelint.registerRule(require('./rules/eol_last.coffee'));

coffeelint.registerRule(require('./rules/no_private_function_fat_arrows.coffee'));

hasSyntaxError = function(source) {
  try {
    CoffeeScript.tokens(source);
    return false;
  } catch (_error) {}
  return true;
};

ErrorReport = require('./error_report.coffee');

coffeelint.getErrorReport = function() {
  return new ErrorReport(coffeelint);
};

coffeelint.lint = function(source, userConfig, literate) {
  var all_errors, astErrors, block_config, cmd, config, disabled, disabled_initially, e, errors, i, l, len, len1, len2, lexErrors, lexicalLinter, lineErrors, lineLinter, m, n, name, next_line, o, q, r, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ruleLoader, rules, s, sourceLength, t, tokensByLine, transform;
  if (userConfig == null) {
    userConfig = {};
  }
  if (literate == null) {
    literate = false;
  }
  errors = [];
  if (cache != null) {
    cache.setConfig(userConfig);
  }
  if (cache != null ? cache.has(source) : void 0) {
    return cache != null ? cache.get(source) : void 0;
  }
  config = mergeDefaultConfig(userConfig);
  if (literate) {
    source = this.invertLiterate(source);
  }
  if ((userConfig != null ? (ref = userConfig.coffeelint) != null ? ref.transforms : void 0 : void 0) != null) {
    sourceLength = source.split("\n").length;
    ref2 = userConfig != null ? (ref1 = userConfig.coffeelint) != null ? ref1.transforms : void 0 : void 0;
    for (n = 0, len = ref2.length; n < len; n++) {
      m = ref2[n];
      try {
        ruleLoader = nodeRequire('./ruleLoader');
        transform = ruleLoader.require(m);
        source = transform(source);
      } catch (_error) {}
    }
    if (sourceLength !== source.split("\n").length && config.transform_messes_up_line_numbers.level !== 'ignore') {
      errors.push(extend({
        lineNumber: 1,
        context: "File was transformed from " + sourceLength + " lines to " + (source.split("\n").length) + " lines"
      }, config.transform_messes_up_line_numbers));
    }
  }
  if ((userConfig != null ? (ref3 = userConfig.coffeelint) != null ? ref3.coffeescript : void 0 : void 0) != null) {
    CoffeeScript = ruleLoader.require(userConfig.coffeelint.coffeescript);
  }
  for (name in userConfig) {
    if (name !== 'coffeescript_error' && name !== '_comment') {
      if (_rules[name] == null) {
        void 0;
      }
    }
  }
  disabled_initially = [];
  ref4 = source.split('\n');
  for (o = 0, len1 = ref4.length; o < len1; o++) {
    l = ref4[o];
    s = LineLinter.configStatement.exec(l);
    if ((s != null ? s.length : void 0) > 2 && indexOf.call(s, 'enable') >= 0) {
      ref5 = s.slice(1);
      for (q = 0, len2 = ref5.length; q < len2; q++) {
        r = ref5[q];
        if (r !== 'enable' && r !== 'disable') {
          if (!(r in config && ((ref6 = config[r].level) === 'warn' || ref6 === 'error'))) {
            disabled_initially.push(r);
            config[r] = {
              level: 'error'
            };
          }
        }
      }
    }
  }
  astErrors = new ASTLinter(source, config, _rules, CoffeeScript).lint();
  errors = errors.concat(astErrors);
  if (!hasSyntaxError(source)) {
    lexicalLinter = new LexicalLinter(source, config, _rules, CoffeeScript);
    lexErrors = lexicalLinter.lint();
    errors = errors.concat(lexErrors);
    tokensByLine = lexicalLinter.tokensByLine;
    lineLinter = new LineLinter(source, config, _rules, tokensByLine, literate);
    lineErrors = lineLinter.lint();
    errors = errors.concat(lineErrors);
    block_config = lineLinter.block_config;
  } else {
    block_config = {
      enable: {},
      disable: {}
    };
  }
  errors.sort(function(a, b) {
    return a.lineNumber - b.lineNumber;
  });
  all_errors = errors;
  errors = [];
  disabled = disabled_initially;
  next_line = 0;
  for (i = t = 0, ref7 = source.split('\n').length; 0 <= ref7 ? t < ref7 : t > ref7; i = 0 <= ref7 ? ++t : --t) {
    for (cmd in block_config) {
      rules = block_config[cmd][i];
      if (rules != null) {
        ({
          'disable': function() {
            return disabled = disabled.concat(rules);
          },
          'enable': function() {
            difference(disabled, rules);
            if (rules.length === 0) {
              return disabled = disabled_initially;
            }
          }
        })[cmd]();
      }
    }
    while (next_line === i && all_errors.length > 0) {
      next_line = all_errors[0].lineNumber - 1;
      e = all_errors[0];
      if (e.lineNumber === i + 1 || (e.lineNumber == null)) {
        e = all_errors.shift();
        if (ref8 = e.rule, indexOf.call(disabled, ref8) < 0) {
          errors.push(e);
        }
      }
    }
  }
  if (cache != null) {
    cache.set(source, errors);
  }
  return errors;
};

coffeelint.setCache = function(obj) {
  return cache = obj;
};



},{"./../package.json":2,"./ast_linter.coffee":3,"./error_report.coffee":5,"./lexical_linter.coffee":6,"./line_linter.coffee":7,"./rules.coffee":8,"./rules/arrow_spacing.coffee":9,"./rules/braces_spacing.coffee":10,"./rules/camel_case_classes.coffee":11,"./rules/colon_assignment_spacing.coffee":12,"./rules/cyclomatic_complexity.coffee":13,"./rules/duplicate_key.coffee":14,"./rules/empty_constructor_needs_parens.coffee":15,"./rules/ensure_comprehensions.coffee":16,"./rules/eol_last.coffee":17,"./rules/indentation.coffee":18,"./rules/line_endings.coffee":19,"./rules/max_line_length.coffee":20,"./rules/missing_fat_arrows.coffee":21,"./rules/newlines_after_classes.coffee":22,"./rules/no_backticks.coffee":23,"./rules/no_debugger.coffee":24,"./rules/no_empty_functions.coffee":25,"./rules/no_empty_param_list.coffee":26,"./rules/no_implicit_braces.coffee":27,"./rules/no_implicit_parens.coffee":28,"./rules/no_interpolation_in_single_quotes.coffee":29,"./rules/no_nested_string_interpolation.coffee":30,"./rules/no_plusplus.coffee":31,"./rules/no_private_function_fat_arrows.coffee":32,"./rules/no_stand_alone_at.coffee":33,"./rules/no_tabs.coffee":34,"./rules/no_this.coffee":35,"./rules/no_throwing_strings.coffee":36,"./rules/no_trailing_semicolons.coffee":37,"./rules/no_trailing_whitespace.coffee":38,"./rules/no_unnecessary_double_quotes.coffee":39,"./rules/no_unnecessary_fat_arrows.coffee":40,"./rules/non_empty_constructor_needs_parens.coffee":41,"./rules/prefer_english_operator.coffee":42,"./rules/space_operators.coffee":43,"./rules/spacing_after_comma.coffee":44,"./rules/transform_messes_up_line_numbers.coffee":45}],2:[function(require,module,exports){
module.exports={
  "name": "coffeelint",
  "description": "Lint your CoffeeScript",
  "version": "1.11.0",
  "homepage": "http://www.coffeelint.org",
  "keywords": [
    "lint",
    "coffeescript",
    "coffee-script"
  ],
  "author": "Matthew Perpick <clutchski@gmail.com>",
  "main": "./lib/coffeelint.js",
  "engines": {
    "npm": ">=1.3.7",
    "node": ">=0.8.0"
  },
  "repository": {
    "type": "git",
    "url": "git://github.com/clutchski/coffeelint.git"
  },
  "bin": {
    "coffeelint": "./bin/coffeelint"
  },
  "dependencies": {
    "browserify": "~8.1.0",
    "coffee-script": "^1.9.1",
    "coffeeify": "~1.0.0",
    "glob": "^4.0.0",
    "ignore": "^2.2.15",
    "optimist": "^0.6.1",
    "resolve": "^0.6.3",
    "strip-json-comments": "^1.0.2"
  },
  "devDependencies": {
    "vows": ">=0.6.0",
    "underscore": ">=1.4.4"
  },
  "license": "MIT",
  "scripts": {
    "pretest": "cake compile",
    "test": "./vowsrunner.js --spec test/*.coffee test/*.litcoffee",
    "testrule": "npm run compile && ./vowsrunner.js --spec",
    "posttest": "npm run lint",
    "prepublish": "cake prepublish",
    "publish": "cake publish",
    "install": "cake install",
    "lint": "cake compile && ./bin/coffeelint .",
    "lint-csv": "cake compile && ./bin/coffeelint --csv .",
    "lint-jslint": "cake compile && ./bin/coffeelint --jslint .",
    "compile": "cake compile"
  }
}

},{}],3:[function(require,module,exports){
var ASTApi, ASTLinter, BaseLinter, hasChildren, node_children,
  hasProp = {}.hasOwnProperty,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseLinter = require('./base_linter.coffee');

node_children = {
  Class: ['variable', 'parent', 'body'],
  Code: ['params', 'body'],
  For: ['body', 'source', 'guard', 'step'],
  If: ['condition', 'body', 'elseBody'],
  Obj: ['properties'],
  Op: ['first', 'second'],
  Switch: ['subject', 'cases', 'otherwise'],
  Try: ['attempt', 'recovery', 'ensure'],
  Value: ['base', 'properties'],
  While: ['condition', 'guard', 'body']
};

hasChildren = function(node, children) {
  var ref;
  return (node != null ? (ref = node.children) != null ? ref.length : void 0 : void 0) === children.length && (node != null ? node.children.every(function(elem, i) {
    return elem === children[i];
  }) : void 0);
};

ASTApi = (function() {
  function ASTApi(config1) {
    this.config = config1;
  }

  ASTApi.prototype.getNodeName = function(node) {
    var children, name, ref;
    name = node != null ? (ref = node.constructor) != null ? ref.name : void 0 : void 0;
    if (node_children[name]) {
      return name;
    } else {
      for (name in node_children) {
        if (!hasProp.call(node_children, name)) continue;
        children = node_children[name];
        if (hasChildren(node, children)) {
          return name;
        }
      }
    }
  };

  return ASTApi;

})();

module.exports = ASTLinter = (function(superClass) {
  extend(ASTLinter, superClass);

  function ASTLinter(source, config, rules, CoffeeScript) {
    this.CoffeeScript = CoffeeScript;
    ASTLinter.__super__.constructor.call(this, source, config, rules);
    this.astApi = new ASTApi(this.config);
  }

  ASTLinter.prototype.acceptRule = function(rule) {
    return typeof rule.lintAST === 'function';
  };

  ASTLinter.prototype.lint = function() {
    var coffeeError, err, errors, j, len, ref, rule, v;
    errors = [];
    try {
      this.node = this.CoffeeScript.nodes(this.source);
    } catch (_error) {
      coffeeError = _error;
      err = this._parseCoffeeScriptError(coffeeError);
      if (err != null) {
        errors.push(err);
      }
      return errors;
    }
    ref = this.rules;
    for (j = 0, len = ref.length; j < len; j++) {
      rule = ref[j];
      this.astApi.createError = (function(_this) {
        return function(attrs) {
          if (attrs == null) {
            attrs = {};
          }
          return _this.createError(rule.rule.name, attrs);
        };
      })(this);
      rule.errors = errors;
      v = this.normalizeResult(rule, rule.lintAST(this.node, this.astApi));
      if (v != null) {
        return v;
      }
    }
    return errors;
  };

  ASTLinter.prototype._parseCoffeeScriptError = function(coffeeError) {
    var attrs, lineNumber, match, message, rule;
    rule = this.config['coffeescript_error'];
    message = coffeeError.toString();
    lineNumber = -1;
    if (coffeeError.location != null) {
      lineNumber = coffeeError.location.first_line + 1;
    } else {
      match = /line (\d+)/.exec(message);
      if ((match != null ? match.length : void 0) > 1) {
        lineNumber = parseInt(match[1], 10);
      }
    }
    attrs = {
      message: message,
      level: rule.level,
      lineNumber: lineNumber
    };
    return this.createError('coffeescript_error', attrs);
  };

  return ASTLinter;

})(BaseLinter);



},{"./base_linter.coffee":4}],4:[function(require,module,exports){
var BaseLinter, defaults, extend,
  slice = [].slice;

extend = function() {
  var destination, i, k, len, source, sources, v;
  destination = arguments[0], sources = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  for (i = 0, len = sources.length; i < len; i++) {
    source = sources[i];
    for (k in source) {
      v = source[k];
      destination[k] = v;
    }
  }
  return destination;
};

defaults = function(source, defaults) {
  return extend({}, defaults, source);
};

module.exports = BaseLinter = (function() {
  function BaseLinter(source1, config, rules) {
    this.source = source1;
    this.config = config;
    this.setupRules(rules);
  }

  BaseLinter.prototype.isObject = function(obj) {
    return obj === Object(obj);
  };

  BaseLinter.prototype.createError = function(ruleName, attrs) {
    var level;
    if (attrs == null) {
      attrs = {};
    }
    if (attrs.level == null) {
      attrs.level = this.config[ruleName].level;
    }
    level = attrs.level;
    if (level !== 'ignore' && level !== 'warn' && level !== 'error') {
      throw new Error("unknown level " + level);
    }
    if (level === 'error' || level === 'warn') {
      attrs.rule = ruleName;
      return defaults(attrs, this.config[ruleName]);
    } else {
      return null;
    }
  };

  BaseLinter.prototype.acceptRule = function(rule) {
    throw new Error("acceptRule needs to be overridden in the subclass");
  };

  BaseLinter.prototype.setupRules = function(rules) {
    var RuleConstructor, level, name, results, rule;
    this.rules = [];
    results = [];
    for (name in rules) {
      RuleConstructor = rules[name];
      level = this.config[name].level;
      if (level === 'error' || level === 'warn') {
        rule = new RuleConstructor(this, this.config);
        if (this.acceptRule(rule)) {
          results.push(this.rules.push(rule));
        } else {
          results.push(void 0);
        }
      } else if (level !== 'ignore') {
        throw new Error("unknown level " + level);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  BaseLinter.prototype.normalizeResult = function(p, result) {
    if (result === true) {
      return this.createError(p.rule.name);
    }
    if (this.isObject(result)) {
      return this.createError(p.rule.name, result);
    }
  };

  return BaseLinter;

})();



},{}],5:[function(require,module,exports){
var ErrorReport;

module.exports = ErrorReport = (function() {
  function ErrorReport(coffeelint) {
    this.coffeelint = coffeelint;
    this.paths = {};
  }

  ErrorReport.prototype.lint = function(filename, source, config, literate) {
    if (config == null) {
      config = {};
    }
    if (literate == null) {
      literate = false;
    }
    return this.paths[filename] = this.coffeelint.lint(source, config, literate);
  };

  ErrorReport.prototype.getExitCode = function() {
    var path;
    for (path in this.paths) {
      if (this.pathHasError(path)) {
        return 1;
      }
    }
    return 0;
  };

  ErrorReport.prototype.getSummary = function() {
    var error, errorCount, errors, i, len, path, pathCount, ref, warningCount;
    pathCount = errorCount = warningCount = 0;
    ref = this.paths;
    for (path in ref) {
      errors = ref[path];
      pathCount++;
      for (i = 0, len = errors.length; i < len; i++) {
        error = errors[i];
        if (error.level === 'error') {
          errorCount++;
        }
        if (error.level === 'warn') {
          warningCount++;
        }
      }
    }
    return {
      errorCount: errorCount,
      warningCount: warningCount,
      pathCount: pathCount
    };
  };

  ErrorReport.prototype.getErrors = function(path) {
    return this.paths[path];
  };

  ErrorReport.prototype.pathHasWarning = function(path) {
    return this._hasLevel(path, 'warn');
  };

  ErrorReport.prototype.pathHasError = function(path) {
    return this._hasLevel(path, 'error');
  };

  ErrorReport.prototype.hasError = function() {
    var path;
    for (path in this.paths) {
      if (this.pathHasError(path)) {
        return true;
      }
    }
    return false;
  };

  ErrorReport.prototype._hasLevel = function(path, level) {
    var error, i, len, ref;
    ref = this.paths[path];
    for (i = 0, len = ref.length; i < len; i++) {
      error = ref[i];
      if (error.level === level) {
        return true;
      }
    }
    return false;
  };

  return ErrorReport;

})();



},{}],6:[function(require,module,exports){
var BaseLinter, LexicalLinter, TokenApi,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

TokenApi = (function() {
  function TokenApi(CoffeeScript, source, config1, tokensByLine) {
    this.config = config1;
    this.tokensByLine = tokensByLine;
    this.tokens = CoffeeScript.tokens(source);
    this.lines = source.split('\n');
    this.tokensByLine = {};
  }

  TokenApi.prototype.i = 0;

  TokenApi.prototype.peek = function(n) {
    if (n == null) {
      n = 1;
    }
    return this.tokens[this.i + n] || null;
  };

  return TokenApi;

})();

BaseLinter = require('./base_linter.coffee');

module.exports = LexicalLinter = (function(superClass) {
  extend(LexicalLinter, superClass);

  function LexicalLinter(source, config, rules, CoffeeScript) {
    LexicalLinter.__super__.constructor.call(this, source, config, rules);
    this.tokenApi = new TokenApi(CoffeeScript, source, this.config, this.tokensByLine);
    this.tokensByLine = this.tokenApi.tokensByLine;
  }

  LexicalLinter.prototype.acceptRule = function(rule) {
    return typeof rule.lintToken === 'function';
  };

  LexicalLinter.prototype.lint = function() {
    var error, errors, i, j, k, len, len1, ref, ref1, token;
    errors = [];
    ref = this.tokenApi.tokens;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      token = ref[i];
      this.tokenApi.i = i;
      ref1 = this.lintToken(token);
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        error = ref1[k];
        errors.push(error);
      }
    }
    return errors;
  };

  LexicalLinter.prototype.lintToken = function(token) {
    var base, errors, j, len, lineNumber, ref, ref1, rule, type, v, value;
    type = token[0], value = token[1], lineNumber = token[2];
    if (typeof lineNumber === "object") {
      if (type === 'OUTDENT' || type === 'INDENT') {
        lineNumber = lineNumber.last_line;
      } else {
        lineNumber = lineNumber.first_line;
      }
    }
    if ((base = this.tokensByLine)[lineNumber] == null) {
      base[lineNumber] = [];
    }
    this.tokensByLine[lineNumber].push(token);
    this.lineNumber = lineNumber || this.lineNumber || 0;
    this.tokenApi.lineNumber = this.lineNumber;
    errors = [];
    ref = this.rules;
    for (j = 0, len = ref.length; j < len; j++) {
      rule = ref[j];
      if (!(ref1 = token[0], indexOf.call(rule.tokens, ref1) >= 0)) {
        continue;
      }
      v = this.normalizeResult(rule, rule.lintToken(token, this.tokenApi));
      if (v != null) {
        errors.push(v);
      }
    }
    return errors;
  };

  LexicalLinter.prototype.createError = function(ruleName, attrs) {
    if (attrs == null) {
      attrs = {};
    }
    attrs.lineNumber = this.lineNumber + 1;
    attrs.line = this.tokenApi.lines[this.lineNumber];
    return LexicalLinter.__super__.createError.call(this, ruleName, attrs);
  };

  return LexicalLinter;

})(BaseLinter);



},{"./base_linter.coffee":4}],7:[function(require,module,exports){
var BaseLinter, LineApi, LineLinter, configStatement,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LineApi = (function() {
  function LineApi(source, config1, tokensByLine1, literate1) {
    this.config = config1;
    this.tokensByLine = tokensByLine1;
    this.literate = literate1;
    this.line = null;
    this.lines = source.split('\n');
    this.lineCount = this.lines.length;
    this.context = {
      "class": {
        inClass: false,
        lastUnemptyLineInClass: null,
        classIndents: null
      }
    };
  }

  LineApi.prototype.lineNumber = 0;

  LineApi.prototype.isLiterate = function() {
    return this.literate;
  };

  LineApi.prototype.maintainClassContext = function(line) {
    if (this.context["class"].inClass) {
      if (this.lineHasToken('INDENT')) {
        this.context["class"].classIndents++;
      } else if (this.lineHasToken('OUTDENT')) {
        this.context["class"].classIndents--;
        if (this.context["class"].classIndents === 0) {
          this.context["class"].inClass = false;
          this.context["class"].classIndents = null;
        }
      }
      if (this.context["class"].inClass && !line.match(/^\s*$/)) {
        this.context["class"].lastUnemptyLineInClass = this.lineNumber;
      }
    } else {
      if (!line.match(/\\s*/)) {
        this.context["class"].lastUnemptyLineInClass = null;
      }
      if (this.lineHasToken('CLASS')) {
        this.context["class"].inClass = true;
        this.context["class"].lastUnemptyLineInClass = this.lineNumber;
        this.context["class"].classIndents = 0;
      }
    }
    return null;
  };

  LineApi.prototype.isLastLine = function() {
    return this.lineNumber === this.lineCount - 1;
  };

  LineApi.prototype.lineHasToken = function(tokenType, lineNumber) {
    var i, len, token, tokens;
    if (tokenType == null) {
      tokenType = null;
    }
    if (lineNumber == null) {
      lineNumber = null;
    }
    lineNumber = lineNumber != null ? lineNumber : this.lineNumber;
    if (tokenType == null) {
      return this.tokensByLine[lineNumber] != null;
    } else {
      tokens = this.tokensByLine[lineNumber];
      if (tokens == null) {
        return null;
      }
      for (i = 0, len = tokens.length; i < len; i++) {
        token = tokens[i];
        if (token[0] === tokenType) {
          return true;
        }
      }
      return false;
    }
  };

  LineApi.prototype.getLineTokens = function() {
    return this.tokensByLine[this.lineNumber] || [];
  };

  return LineApi;

})();

BaseLinter = require('./base_linter.coffee');

configStatement = /coffeelint:\s*(disable|enable)(?:=([\w\s,]*))?/;

module.exports = LineLinter = (function(superClass) {
  extend(LineLinter, superClass);

  LineLinter.configStatement = configStatement;

  function LineLinter(source, config, rules, tokensByLine, literate) {
    if (literate == null) {
      literate = false;
    }
    LineLinter.__super__.constructor.call(this, source, config, rules);
    this.lineApi = new LineApi(source, config, tokensByLine, literate);
    this.block_config = {
      enable: {},
      disable: {}
    };
  }

  LineLinter.prototype.acceptRule = function(rule) {
    return typeof rule.lintLine === 'function';
  };

  LineLinter.prototype.lint = function() {
    var error, errors, i, j, len, len1, line, lineNumber, ref, ref1;
    errors = [];
    ref = this.lineApi.lines;
    for (lineNumber = i = 0, len = ref.length; i < len; lineNumber = ++i) {
      line = ref[lineNumber];
      this.lineApi.lineNumber = this.lineNumber = lineNumber;
      this.lineApi.maintainClassContext(line);
      this.collectInlineConfig(line);
      ref1 = this.lintLine(line);
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        error = ref1[j];
        errors.push(error);
      }
    }
    return errors;
  };

  LineLinter.prototype.lintLine = function(line) {
    var errors, i, len, ref, rule, v;
    errors = [];
    ref = this.rules;
    for (i = 0, len = ref.length; i < len; i++) {
      rule = ref[i];
      v = this.normalizeResult(rule, rule.lintLine(line, this.lineApi));
      if (v != null) {
        errors.push(v);
      }
    }
    return errors;
  };

  LineLinter.prototype.collectInlineConfig = function(line) {
    var cmd, i, len, r, ref, result, rules;
    result = configStatement.exec(line);
    if (result != null) {
      cmd = result[1];
      rules = [];
      if (result[2] != null) {
        ref = result[2].split(',');
        for (i = 0, len = ref.length; i < len; i++) {
          r = ref[i];
          rules.push(r.replace(/^\s+|\s+$/g, ""));
        }
      }
      this.block_config[cmd][this.lineNumber] = rules;
    }
    return null;
  };

  LineLinter.prototype.createError = function(rule, attrs) {
    var ref;
    if (attrs == null) {
      attrs = {};
    }
    attrs.lineNumber = this.lineNumber + 1;
    attrs.level = (ref = this.config[rule]) != null ? ref.level : void 0;
    return LineLinter.__super__.createError.call(this, rule, attrs);
  };

  return LineLinter;

})(BaseLinter);



},{"./base_linter.coffee":4}],8:[function(require,module,exports){
var ERROR, IGNORE, WARN;

ERROR = 'error';

WARN = 'warn';

IGNORE = 'ignore';

module.exports = {
  coffeescript_error: {
    level: ERROR,
    message: ''
  }
};



},{}],9:[function(require,module,exports){
var ArrowSpacing;

module.exports = ArrowSpacing = (function() {
  function ArrowSpacing() {}

  ArrowSpacing.prototype.rule = {
    name: 'arrow_spacing',
    level: 'ignore',
    message: 'Function arrows (-> and =>) must be spaced properly',
    description: "<p>This rule checks to see that there is spacing before and after\nthe arrow operator that declares a function. This rule is disabled\nby default.</p> <p>Note that if arrow_spacing is enabled, and you\npass an empty function as a parameter, arrow_spacing will accept\neither a space or no space in-between the arrow operator and the\nparenthesis</p>\n<pre><code># Both of this will not trigger an error,\n# even with arrow_spacing enabled.\nx(-> 3)\nx( -> 3)\n\n# However, this will trigger an error\nx((a,b)-> 3)\n</code>\n</pre>"
  };

  ArrowSpacing.prototype.tokens = ['->', '=>'];

  ArrowSpacing.prototype.lintToken = function(token, tokenApi) {
    var pp;
    pp = tokenApi.peek(-1);
    if (!pp) {
      return;
    }
    if (!token.spaced && (pp[1] === "(" && (pp.generated == null)) && tokenApi.peek(1)[0] === 'INDENT' && tokenApi.peek(2)[0] === 'OUTDENT') {
      return null;
    } else if (!(((token.spaced != null) || (token.newLine != null) || this.atEof(tokenApi)) && (((pp.spaced != null) || pp[0] === 'TERMINATOR') || (pp.generated != null) || pp[0] === "INDENT" || (pp[1] === "(" && (pp.generated == null))))) {
      return true;
    } else {
      return null;
    }
  };

  ArrowSpacing.prototype.atEof = function(tokenApi) {
    var i, j, len, ref, ref1, token, tokens;
    tokens = tokenApi.tokens, i = tokenApi.i;
    ref = tokens.slice(i + 1);
    for (j = 0, len = ref.length; j < len; j++) {
      token = ref[j];
      if (!(token.generated || ((ref1 = token[0]) === 'OUTDENT' || ref1 === 'TERMINATOR'))) {
        return false;
      }
    }
    return true;
  };

  return ArrowSpacing;

})();



},{}],10:[function(require,module,exports){
var BracesSpacing;

module.exports = BracesSpacing = (function() {
  function BracesSpacing() {}

  BracesSpacing.prototype.rule = {
    name: 'braces_spacing',
    level: 'ignore',
    spaces: 0,
    empty_object_spaces: 0,
    message: 'Curly braces must have the proper spacing',
    description: 'This rule checks to see that there is the proper spacing inside\ncurly braces. The spacing amount is specified by "spaces".\nThe spacing amount for empty objects is specified by\n"empty_object_spaces".\n\n<pre><code>\n# Spaces is 0\n{a: b}     # Good\n{a: b }    # Bad\n{ a: b}    # Bad\n{ a: b }   # Bad\n\n# Spaces is 1\n{a: b}     # Bad\n{a: b }    # Bad\n{ a: b}    # Bad\n{ a: b }   # Good\n{ a: b  }  # Bad\n{  a: b }  # Bad\n{  a: b  } # Bad\n\n# Empty Object Spaces is 0\n{}         # Good\n{ }        # Bad\n\n# Empty Object Spaces is 1\n{}         # Bad\n{ }        # Good\n</code></pre>\n\nThis rule is disabled by default.'
  };

  BracesSpacing.prototype.tokens = ['{', '}'];

  BracesSpacing.prototype.distanceBetweenTokens = function(firstToken, secondToken) {
    return secondToken[2].first_column - firstToken[2].last_column - 1;
  };

  BracesSpacing.prototype.findNearestToken = function(token, tokenApi, difference) {
    var nearestToken, totalDifference;
    totalDifference = 0;
    while (true) {
      totalDifference += difference;
      nearestToken = tokenApi.peek(totalDifference);
      if (nearestToken[0] === 'OUTDENT') {
        continue;
      }
      return nearestToken;
    }
  };

  BracesSpacing.prototype.tokensOnSameLine = function(firstToken, secondToken) {
    return firstToken[2].first_line === secondToken[2].first_line;
  };

  BracesSpacing.prototype.getExpectedSpaces = function(tokenApi, firstToken, secondToken) {
    var config, ref;
    config = tokenApi.config[this.rule.name];
    if (firstToken[0] === '{' && secondToken[0] === '}') {
      return (ref = config.empty_object_spaces) != null ? ref : config.spaces;
    } else {
      return config.spaces;
    }
  };

  BracesSpacing.prototype.lintToken = function(token, tokenApi) {
    var actual, expected, firstToken, msg, ref, secondToken;
    if (token.generated) {
      return null;
    }
    ref = token[0] === '{' ? [token, this.findNearestToken(token, tokenApi, 1)] : [this.findNearestToken(token, tokenApi, -1), token], firstToken = ref[0], secondToken = ref[1];
    if (!this.tokensOnSameLine(firstToken, secondToken)) {
      return null;
    }
    expected = this.getExpectedSpaces(tokenApi, firstToken, secondToken);
    actual = this.distanceBetweenTokens(firstToken, secondToken);
    if (actual === expected) {
      return null;
    } else {
      msg = "There should be " + expected + " space";
      if (expected !== 1) {
        msg += 's';
      }
      msg += " inside \"" + token[0] + "\"";
      return {
        context: msg
      };
    }
  };

  return BracesSpacing;

})();



},{}],11:[function(require,module,exports){
var CamelCaseClasses, regexes;

regexes = {
  camelCase: /^[A-Z_][a-zA-Z\d]*$/
};

module.exports = CamelCaseClasses = (function() {
  function CamelCaseClasses() {}

  CamelCaseClasses.prototype.rule = {
    name: 'camel_case_classes',
    level: 'error',
    message: 'Class name should be UpperCamelCased',
    description: "This rule mandates that all class names are UpperCamelCased.\nCamel casing class names is a generally accepted way of\ndistinguishing constructor functions - which require the 'new'\nprefix to behave properly - from plain old functions.\n<pre>\n<code># Good!\nclass BoaConstrictor\n\n# Bad!\nclass boaConstrictor\n</code>\n</pre>\nThis rule is enabled by default."
  };

  CamelCaseClasses.prototype.tokens = ['CLASS'];

  CamelCaseClasses.prototype.lintToken = function(token, tokenApi) {
    var className, offset, ref, ref1, ref2;
    if ((token.newLine != null) || ((ref = tokenApi.peek()[0]) === 'INDENT' || ref === 'EXTENDS')) {
      return null;
    }
    className = null;
    offset = 1;
    while (!className) {
      if (((ref1 = tokenApi.peek(offset + 1)) != null ? ref1[0] : void 0) === '.') {
        offset += 2;
      } else if (((ref2 = tokenApi.peek(offset)) != null ? ref2[0] : void 0) === '@') {
        offset += 1;
      } else {
        className = tokenApi.peek(offset)[1];
      }
    }
    if (!regexes.camelCase.test(className)) {
      return {
        context: "class name: " + className
      };
    }
  };

  return CamelCaseClasses;

})();



},{}],12:[function(require,module,exports){
var ColonAssignmentSpacing;

module.exports = ColonAssignmentSpacing = (function() {
  function ColonAssignmentSpacing() {}

  ColonAssignmentSpacing.prototype.rule = {
    name: 'colon_assignment_spacing',
    level: 'ignore',
    message: 'Colon assignment without proper spacing',
    spacing: {
      left: 0,
      right: 0
    },
    description: "<p>This rule checks to see that there is spacing before and\nafter the colon in a colon assignment (i.e., classes, objects).\nThe spacing amount is specified by\nspacing.left and spacing.right, respectively.\nA zero value means no spacing required.\n</p>\n<pre><code>\n#\n# If spacing.left and spacing.right is 1\n#\n\n# Good\nobject = {spacing : true}\nclass Dog\n  canBark : true\n\n# Bad\nobject = {spacing: true}\nclass Cat\n  canBark: false\n</code></pre>"
  };

  ColonAssignmentSpacing.prototype.tokens = [':'];

  ColonAssignmentSpacing.prototype.lintToken = function(token, tokenApi) {
    var checkSpacing, getSpaceFromToken, isLeftSpaced, isRightSpaced, leftSpacing, nextToken, previousToken, ref, ref1, rightSpacing, spaceRules;
    spaceRules = tokenApi.config[this.rule.name].spacing;
    previousToken = tokenApi.peek(-1);
    nextToken = tokenApi.peek(1);
    getSpaceFromToken = function(direction) {
      switch (direction) {
        case 'left':
          return token[2].first_column - previousToken[2].last_column - 1;
        case 'right':
          return nextToken[2].first_column - token[2].first_column - 1;
      }
    };
    checkSpacing = function(direction) {
      var isSpaced, spacing;
      spacing = getSpaceFromToken(direction);
      isSpaced = spacing < 0 ? true : spacing === parseInt(spaceRules[direction]);
      return [isSpaced, spacing];
    };
    ref = checkSpacing('left'), isLeftSpaced = ref[0], leftSpacing = ref[1];
    ref1 = checkSpacing('right'), isRightSpaced = ref1[0], rightSpacing = ref1[1];
    if (isLeftSpaced && isRightSpaced) {
      return null;
    } else {
      return {
        context: "Incorrect spacing around column " + token[2].first_column + ".\nExpected left: " + spaceRules.left + ", right: " + spaceRules.right + ".\nGot left: " + leftSpacing + ", right: " + rightSpacing + "."
      };
    }
  };

  return ColonAssignmentSpacing;

})();



},{}],13:[function(require,module,exports){
var CyclomaticComplexity;

module.exports = CyclomaticComplexity = (function() {
  function CyclomaticComplexity() {}

  CyclomaticComplexity.prototype.rule = {
    name: 'cyclomatic_complexity',
    value: 10,
    level: 'ignore',
    message: 'The cyclomatic complexity is too damn high',
    description: 'Examine the complexity of your application.'
  };

  CyclomaticComplexity.prototype.getComplexity = function(node) {
    var complexity, name, ref;
    name = this.astApi.getNodeName(node);
    complexity = name === 'If' || name === 'While' || name === 'For' || name === 'Try' ? 1 : name === 'Op' && ((ref = node.operator) === '&&' || ref === '||') ? 1 : name === 'Switch' ? node.cases.length : 0;
    return complexity;
  };

  CyclomaticComplexity.prototype.lintAST = function(node, astApi) {
    this.astApi = astApi;
    this.lintNode(node);
    return void 0;
  };

  CyclomaticComplexity.prototype.lintNode = function(node, line) {
    var complexity, error, name, ref, rule;
    name = (ref = this.astApi) != null ? ref.getNodeName(node) : void 0;
    complexity = this.getComplexity(node);
    node.eachChild((function(_this) {
      return function(childNode) {
        var nodeLine;
        nodeLine = childNode.locationData.first_line;
        if (childNode) {
          return complexity += _this.lintNode(childNode, nodeLine);
        }
      };
    })(this));
    rule = this.astApi.config[this.rule.name];
    if (name === 'Code' && complexity >= rule.value) {
      error = this.astApi.createError({
        context: complexity + 1,
        lineNumber: line + 1,
        lineNumberEnd: node.locationData.last_line + 1
      });
      if (error) {
        this.errors.push(error);
      }
    }
    return complexity;
  };

  return CyclomaticComplexity;

})();



},{}],14:[function(require,module,exports){
var DuplicateKey;

module.exports = DuplicateKey = (function() {
  DuplicateKey.prototype.rule = {
    name: 'duplicate_key',
    level: 'error',
    message: 'Duplicate key defined in object or class',
    description: "Prevents defining duplicate keys in object literals and classes"
  };

  DuplicateKey.prototype.tokens = ['IDENTIFIER', '{', '}'];

  function DuplicateKey() {
    this.braceScopes = [];
  }

  DuplicateKey.prototype.lintToken = function(arg, tokenApi) {
    var type;
    type = arg[0];
    if (type === '{' || type === '}') {
      this.lintBrace.apply(this, arguments);
      return void 0;
    }
    if (type === 'IDENTIFIER') {
      return this.lintIdentifier.apply(this, arguments);
    }
  };

  DuplicateKey.prototype.lintIdentifier = function(token, tokenApi) {
    var key, nextToken, previousToken;
    key = token[1];
    if (this.currentScope == null) {
      return null;
    }
    nextToken = tokenApi.peek(1);
    if (nextToken[1] !== ':') {
      return null;
    }
    previousToken = tokenApi.peek(-1);
    if (previousToken[0] === '@') {
      key = "@" + key;
    }
    key = "identifier-" + key;
    if (this.currentScope[key]) {
      return true;
    } else {
      this.currentScope[key] = token;
      return null;
    }
  };

  DuplicateKey.prototype.lintBrace = function(token) {
    if (token[0] === '{') {
      if (this.currentScope != null) {
        this.braceScopes.push(this.currentScope);
      }
      this.currentScope = {};
    } else {
      this.currentScope = this.braceScopes.pop();
    }
    return null;
  };

  return DuplicateKey;

})();



},{}],15:[function(require,module,exports){
var EmptyConstructorNeedsParens;

module.exports = EmptyConstructorNeedsParens = (function() {
  function EmptyConstructorNeedsParens() {}

  EmptyConstructorNeedsParens.prototype.rule = {
    name: 'empty_constructor_needs_parens',
    level: 'ignore',
    message: 'Invoking a constructor without parens and without arguments',
    description: "Requires constructors with no parameters to include the parens"
  };

  EmptyConstructorNeedsParens.prototype.tokens = ['UNARY'];

  EmptyConstructorNeedsParens.prototype.lintToken = function(token, tokenApi) {
    var expectedCallStart, expectedIdentifier, identifierIndex, peek, ref;
    if (token[1] === 'new') {
      peek = tokenApi.peek.bind(tokenApi);
      identifierIndex = 1;
      while (true) {
        expectedIdentifier = peek(identifierIndex);
        expectedCallStart = peek(identifierIndex + 1);
        if ((expectedIdentifier != null ? expectedIdentifier[0] : void 0) === 'IDENTIFIER') {
          if ((expectedCallStart != null ? expectedCallStart[0] : void 0) === '.') {
            identifierIndex += 2;
            continue;
          }
          if ((expectedCallStart != null ? expectedCallStart[0] : void 0) === 'INDEX_START') {
            while (((ref = peek(identifierIndex)) != null ? ref[0] : void 0) !== 'INDEX_END') {
              identifierIndex++;
            }
            continue;
          }
        }
        break;
      }
      if ((expectedIdentifier != null ? expectedIdentifier[0] : void 0) === 'IDENTIFIER' && (expectedCallStart != null)) {
        return this.handleExpectedCallStart(expectedCallStart);
      }
    }
  };

  EmptyConstructorNeedsParens.prototype.handleExpectedCallStart = function(expectedCallStart) {
    if (expectedCallStart[0] !== 'CALL_START') {
      return true;
    }
  };

  return EmptyConstructorNeedsParens;

})();



},{}],16:[function(require,module,exports){
var EnsureComprehensions,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = EnsureComprehensions = (function() {
  function EnsureComprehensions() {}

  EnsureComprehensions.prototype.rule = {
    name: 'ensure_comprehensions',
    level: 'warn',
    message: 'Comprehensions must have parentheses around them',
    description: 'This rule makes sure that parentheses are around comprehensions.'
  };

  EnsureComprehensions.prototype.tokens = ['FOR'];

  EnsureComprehensions.prototype.forBlock = false;

  EnsureComprehensions.prototype.lintToken = function(token, tokenApi) {
    var atEqual, idents, numCallEnds, numCallStarts, peeker, prevIdents, prevToken, ref, ref1;
    idents = this.findIdents(tokenApi);
    if (this.forBlock) {
      this.forBlock = false;
      return;
    }
    peeker = -1;
    atEqual = false;
    numCallEnds = 0;
    numCallStarts = 0;
    prevIdents = [];
    while ((prevToken = tokenApi.peek(peeker))) {
      if (prevToken[0] === 'CALL_END') {
        numCallEnds++;
      }
      if (prevToken[0] === 'CALL_START') {
        numCallStarts++;
      }
      if (prevToken[0] === 'IDENTIFIER') {
        if (!atEqual) {
          prevIdents.push(prevToken[1]);
        } else if (ref = prevToken[1], indexOf.call(idents, ref) >= 0) {
          return;
        }
      }
      if (((ref1 = prevToken[0]) === '(' || ref1 === '->' || ref1 === 'TERMINATOR') || (prevToken.newLine != null)) {
        break;
      }
      if (prevToken[0] === '=') {
        atEqual = true;
      }
      peeker--;
    }
    if (atEqual && prevIdents.length > 0 && numCallStarts === numCallEnds) {
      return {
        context: ''
      };
    }
  };

  EnsureComprehensions.prototype.findIdents = function(tokenApi) {
    var idents, nextToken, peeker, ref;
    peeker = 1;
    idents = [];
    while ((nextToken = tokenApi.peek(peeker))) {
      if (nextToken[0] === 'IDENTIFIER') {
        idents.push(nextToken[1]);
      }
      if ((ref = nextToken[0]) === 'FORIN' || ref === 'FOROF') {
        break;
      }
      peeker++;
    }
    while ((nextToken = tokenApi.peek(peeker))) {
      if (nextToken[0] === 'TERMINATOR') {
        break;
      }
      if (nextToken[0] === 'INDENT') {
        this.forBlock = true;
        break;
      }
      peeker++;
    }
    return idents;
  };

  return EnsureComprehensions;

})();



},{}],17:[function(require,module,exports){
var EOLLast;

module.exports = EOLLast = (function() {
  function EOLLast() {}

  EOLLast.prototype.rule = {
    name: 'eol_last',
    level: 'ignore',
    message: 'File does not end with a single newline',
    description: "Checks that the file ends with a single newline"
  };

  EOLLast.prototype.lintLine = function(line, lineApi) {
    if (!lineApi.isLastLine()) {
      return null;
    }
    if (line.length) {
      return true;
    }
  };

  return EOLLast;

})();



},{}],18:[function(require,module,exports){
var Indentation;

module.exports = Indentation = (function() {
  Indentation.prototype.rule = {
    name: 'indentation',
    value: 2,
    level: 'error',
    message: 'Line contains inconsistent indentation',
    description: "This rule imposes a standard number of spaces to be used for\nindentation. Since whitespace is significant in CoffeeScript, it's\ncritical that a project chooses a standard indentation format and\nstays consistent. Other roads lead to darkness. <pre> <code>#\nEnabling this option will prevent this ugly\n# but otherwise valid CoffeeScript.\ntwoSpaces = () ->\n  fourSpaces = () ->\n      eightSpaces = () ->\n            'this is valid CoffeeScript'\n\n</code>\n</pre>\nTwo space indentation is enabled by default."
  };

  Indentation.prototype.tokens = ['INDENT', '[', ']', '.'];

  function Indentation() {
    this.arrayTokens = [];
  }

  Indentation.prototype.lintToken = function(token, tokenApi) {
    var currentLine, expected, ignoreIndent, isArrayIndent, isInterpIndent, isMultiline, lineNumber, lines, numIndents, previous, previousSymbol, ref, ref1, ref2, type;
    type = token[0], numIndents = token[1], (ref = token[2], lineNumber = ref.first_line);
    lines = tokenApi.lines, lineNumber = tokenApi.lineNumber;
    expected = tokenApi.config[this.rule.name].value;
    if (type === '.') {
      currentLine = lines[lineNumber];
      if (((ref1 = currentLine.match(/\S/i)) != null ? ref1[0] : void 0) === '.') {
        return this.handleChain(tokenApi, expected);
      }
      return void 0;
    }
    if (type === '[' || type === ']') {
      this.lintArray(token);
      return void 0;
    }
    if (token.generated != null) {
      return null;
    }
    previous = tokenApi.peek(-2);
    isInterpIndent = previous && previous[0] === '+';
    previous = tokenApi.peek(-1);
    isArrayIndent = this.inArray() && (previous != null ? previous.newLine : void 0);
    previousSymbol = (ref2 = tokenApi.peek(-1)) != null ? ref2[0] : void 0;
    isMultiline = previousSymbol === '=' || previousSymbol === ',';
    ignoreIndent = isInterpIndent || isArrayIndent || isMultiline;
    numIndents = this.getCorrectIndent(tokenApi);
    if (!ignoreIndent && numIndents !== expected) {
      return {
        context: "Expected " + expected + " got " + numIndents
      };
    }
  };

  Indentation.prototype.inArray = function() {
    return this.arrayTokens.length > 0;
  };

  Indentation.prototype.lintArray = function(token) {
    if (token[0] === '[') {
      this.arrayTokens.push(token);
    } else if (token[0] === ']') {
      this.arrayTokens.pop();
    }
    return null;
  };

  Indentation.prototype.handleChain = function(tokenApi, expected) {
    var callStart, checkNum, currIsIndent, currentLine, currentSpaces, findCallStart, lastCheck, lineNumber, lines, numIndents, prevIsIndent, prevLine, prevNum, prevSpaces, ref, ref1;
    lastCheck = 1;
    callStart = 1;
    prevNum = 1;
    lineNumber = tokenApi.lineNumber, lines = tokenApi.lines;
    currentLine = lines[lineNumber];
    findCallStart = tokenApi.peek(-callStart);
    while (findCallStart && findCallStart[0] !== 'TERMINATOR') {
      lastCheck = findCallStart[2].first_line;
      callStart += 1;
      findCallStart = tokenApi.peek(-callStart);
    }
    while ((lineNumber - prevNum > lastCheck) && !/^\s*\./.test(lines[lineNumber - prevNum])) {
      prevNum += 1;
    }
    checkNum = lineNumber - prevNum;
    if (checkNum >= 0) {
      prevLine = lines[checkNum];
      if (prevLine.match(/\S/i)[0] === '.' || checkNum === lastCheck) {
        currentSpaces = (ref = currentLine.match(/\S/i)) != null ? ref.index : void 0;
        prevSpaces = (ref1 = prevLine.match(/\S/i)) != null ? ref1.index : void 0;
        numIndents = currentSpaces - prevSpaces;
        prevIsIndent = prevSpaces % expected !== 0;
        currIsIndent = currentSpaces % expected !== 0;
        if (prevIsIndent && currIsIndent) {
          numIndents = currentSpaces;
        }
        if (numIndents % expected !== 0) {
          return {
            context: "Expected " + expected + " got " + numIndents
          };
        }
      }
    }
  };

  Indentation.prototype.getCorrectIndent = function(tokenApi) {
    var curIndent, i, lineNumber, lines, prevIndent, prevLine, prevNum, ref, ref1, ref2, tokens;
    lineNumber = tokenApi.lineNumber, lines = tokenApi.lines, tokens = tokenApi.tokens, i = tokenApi.i;
    curIndent = (ref = lines[lineNumber].match(/\S/)) != null ? ref.index : void 0;
    prevNum = 1;
    while (/^\s*(#|$)/.test(lines[lineNumber - prevNum])) {
      prevNum += 1;
    }
    prevLine = lines[lineNumber - prevNum];
    prevIndent = (ref1 = prevLine.match(/^(\s*)\./)) != null ? ref1[1].length : void 0;
    if (prevIndent > 0) {
      return curIndent - ((ref2 = prevLine.match(/\S/)) != null ? ref2.index : void 0);
    } else {
      return tokens[i][1];
    }
  };

  return Indentation;

})();



},{}],19:[function(require,module,exports){
var LineEndings;

module.exports = LineEndings = (function() {
  function LineEndings() {}

  LineEndings.prototype.rule = {
    name: 'line_endings',
    level: 'ignore',
    value: 'unix',
    message: 'Line contains incorrect line endings',
    description: "This rule ensures your project uses only <tt>windows</tt> or\n<tt>unix</tt> line endings. This rule is disabled by default."
  };

  LineEndings.prototype.lintLine = function(line, lineApi) {
    var ending, lastChar, ref, valid;
    ending = (ref = lineApi.config[this.rule.name]) != null ? ref.value : void 0;
    if (!ending || lineApi.isLastLine() || !line) {
      return null;
    }
    lastChar = line[line.length - 1];
    valid = (function() {
      if (ending === 'windows') {
        return lastChar === '\r';
      } else if (ending === 'unix') {
        return lastChar !== '\r';
      } else {
        throw new Error("unknown line ending type: " + ending);
      }
    })();
    if (!valid) {
      return {
        context: "Expected " + ending
      };
    } else {
      return null;
    }
  };

  return LineEndings;

})();



},{}],20:[function(require,module,exports){
var MaxLineLength, regexes;

regexes = {
  literateComment: /^\#\s/,
  longUrlComment: /^\s*\#\s*http[^\s]+$/
};

module.exports = MaxLineLength = (function() {
  function MaxLineLength() {}

  MaxLineLength.prototype.rule = {
    name: 'max_line_length',
    value: 80,
    level: 'error',
    limitComments: true,
    message: 'Line exceeds maximum allowed length',
    description: "This rule imposes a maximum line length on your code. <a\nhref=\"http://www.python.org/dev/peps/pep-0008/\">Python's style\nguide</a> does a good job explaining why you might want to limit the\nlength of your lines, though this is a matter of taste.\n\nLines can be no longer than eighty characters by default."
  };

  MaxLineLength.prototype.lintLine = function(line, lineApi) {
    var limitComments, lineLength, max, ref, ref1;
    max = (ref = lineApi.config[this.rule.name]) != null ? ref.value : void 0;
    limitComments = (ref1 = lineApi.config[this.rule.name]) != null ? ref1.limitComments : void 0;
    lineLength = line.replace(/\s+$/, '').length;
    if (lineApi.isLiterate() && regexes.literateComment.test(line)) {
      lineLength -= 2;
    }
    if (max && max < lineLength && !regexes.longUrlComment.test(line)) {
      if (!limitComments) {
        if (lineApi.getLineTokens().length === 0) {
          return;
        }
      }
      return {
        context: "Length is " + lineLength + ", max is " + max
      };
    }
  };

  return MaxLineLength;

})();



},{}],21:[function(require,module,exports){
var MissingFatArrows, any, containsButIsnt,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

any = function(arr, test) {
  return arr.reduce((function(res, elt) {
    return res || test(elt);
  }), false);
};

containsButIsnt = function(node, nIsThis, nIsClass) {
  var target;
  target = void 0;
  node.traverseChildren(false, function(n) {
    if (nIsClass(n)) {
      return false;
    }
    if (nIsThis(n)) {
      target = n;
      return false;
    }
  });
  return target;
};

module.exports = MissingFatArrows = (function() {
  function MissingFatArrows() {
    this.isFatArrowCode = bind(this.isFatArrowCode, this);
    this.isThis = bind(this.isThis, this);
    this.isObject = bind(this.isObject, this);
    this.isValue = bind(this.isValue, this);
    this.isClass = bind(this.isClass, this);
    this.isCode = bind(this.isCode, this);
  }

  MissingFatArrows.prototype.rule = {
    name: 'missing_fat_arrows',
    level: 'ignore',
    is_strict: false,
    message: 'Used `this` in a function without a fat arrow',
    description: "Warns when you use `this` inside a function that wasn't defined\nwith a fat arrow. This rule does not apply to methods defined in a\nclass, since they have `this` bound to the class instance (or the\nclass itself, for class methods). The option `is_strict` is\navailable for checking bindings of class methods.\n\nIt is impossible to statically determine whether a function using\n`this` will be bound with the correct `this` value due to language\nfeatures like `Function.prototype.call` and\n`Function.prototype.bind`, so this rule may produce false positives."
  };

  MissingFatArrows.prototype.lintAST = function(node, astApi) {
    this.astApi = astApi;
    this.lintNode(node);
    return void 0;
  };

  MissingFatArrows.prototype.lintNode = function(node, methods) {
    var error, is_strict, ref;
    if (methods == null) {
      methods = [];
    }
    is_strict = (ref = this.astApi.config[this.rule.name]) != null ? ref.is_strict : void 0;
    if (this.isConstructor(node)) {
      return;
    }
    if ((!this.isFatArrowCode(node)) && (is_strict ? true : indexOf.call(methods, node) < 0) && (this.needsFatArrow(node))) {
      error = this.astApi.createError({
        lineNumber: node.locationData.first_line + 1
      });
      this.errors.push(error);
    }
    return node.eachChild((function(_this) {
      return function(child) {
        return _this.lintNode(child, (function() {
          switch (false) {
            case !this.isClass(node):
              return this.methodsOfClass(node);
            case !this.isCode(node):
              return [];
            default:
              return methods;
          }
        }).call(_this));
      };
    })(this));
  };

  MissingFatArrows.prototype.isCode = function(node) {
    return this.astApi.getNodeName(node) === 'Code';
  };

  MissingFatArrows.prototype.isClass = function(node) {
    return this.astApi.getNodeName(node) === 'Class';
  };

  MissingFatArrows.prototype.isValue = function(node) {
    return this.astApi.getNodeName(node) === 'Value';
  };

  MissingFatArrows.prototype.isObject = function(node) {
    return this.astApi.getNodeName(node) === 'Obj';
  };

  MissingFatArrows.prototype.isThis = function(node) {
    return this.isValue(node) && node.base.value === 'this';
  };

  MissingFatArrows.prototype.isFatArrowCode = function(node) {
    return this.isCode(node) && node.bound;
  };

  MissingFatArrows.prototype.isConstructor = function(node) {
    var ref, ref1;
    return ((ref = node.variable) != null ? (ref1 = ref.base) != null ? ref1.value : void 0 : void 0) === 'constructor';
  };

  MissingFatArrows.prototype.needsFatArrow = function(node) {
    return this.isCode(node) && (any(node.params, (function(_this) {
      return function(param) {
        return param.contains(_this.isThis) != null;
      };
    })(this)) || containsButIsnt(node.body, this.isThis, this.isClass));
  };

  MissingFatArrows.prototype.methodsOfClass = function(classNode) {
    var bodyNodes, returnNode;
    bodyNodes = classNode.body.expressions;
    returnNode = bodyNodes[bodyNodes.length - 1];
    if ((returnNode != null) && this.isValue(returnNode) && this.isObject(returnNode.base)) {
      return returnNode.base.properties.map(function(assignNode) {
        return assignNode.value;
      }).filter(this.isCode);
    } else {
      return [];
    }
  };

  return MissingFatArrows;

})();



},{}],22:[function(require,module,exports){
var NewlinesAfterClasses;

module.exports = NewlinesAfterClasses = (function() {
  function NewlinesAfterClasses() {}

  NewlinesAfterClasses.prototype.rule = {
    name: 'newlines_after_classes',
    value: 3,
    level: 'ignore',
    message: 'Wrong count of newlines between a class and other code',
    description: "<p>Checks the number of newlines between classes and other code.</p>\n\nOptions:\n- <pre><code>value</code></pre> - The number of required newlines\nafter class definitions. Defaults to 3."
  };

  NewlinesAfterClasses.prototype.lintLine = function(line, lineApi) {
    var context, ending, got, lineNumber;
    ending = lineApi.config[this.rule.name].value;
    if (!ending || lineApi.isLastLine()) {
      return null;
    }
    lineNumber = lineApi.lineNumber, context = lineApi.context;
    if (!context["class"].inClass && (context["class"].lastUnemptyLineInClass != null) && (lineNumber - context["class"].lastUnemptyLineInClass) !== ending) {
      got = lineNumber - context["class"].lastUnemptyLineInClass;
      return {
        context: "Expected " + ending + " got " + got
      };
    }
    return null;
  };

  return NewlinesAfterClasses;

})();



},{}],23:[function(require,module,exports){
var NoBackticks;

module.exports = NoBackticks = (function() {
  function NoBackticks() {}

  NoBackticks.prototype.rule = {
    name: 'no_backticks',
    level: 'error',
    message: 'Backticks are forbidden',
    description: "Backticks allow snippets of JavaScript to be embedded in\nCoffeeScript. While some folks consider backticks useful in a few\nniche circumstances, they should be avoided because so none of\nJavaScript's \"bad parts\", like <tt>with</tt> and <tt>eval</tt>,\nsneak into CoffeeScript.\nThis rule is enabled by default."
  };

  NoBackticks.prototype.tokens = ["JS"];

  NoBackticks.prototype.lintToken = function(token, tokenApi) {
    return true;
  };

  return NoBackticks;

})();



},{}],24:[function(require,module,exports){
var NoDebugger;

module.exports = NoDebugger = (function() {
  function NoDebugger() {}

  NoDebugger.prototype.rule = {
    name: 'no_debugger',
    level: 'warn',
    message: 'Found debugging code',
    console: false,
    description: "This rule detects `debugger` and optionally `console` calls\nThis rule is `warn` by default."
  };

  NoDebugger.prototype.tokens = ["DEBUGGER", "IDENTIFIER"];

  NoDebugger.prototype.lintToken = function(token, tokenApi) {
    var method, ref, ref1;
    if (token[0] === 'DEBUGGER') {
      return {
        context: "found '" + token[0] + "'"
      };
    }
    if ((ref = tokenApi.config[this.rule.name]) != null ? ref.console : void 0) {
      if (token[1] === 'console' && ((ref1 = tokenApi.peek(1)) != null ? ref1[0] : void 0) === '.') {
        method = tokenApi.peek(2);
        return {
          context: "found 'console." + method[1] + "'"
        };
      }
    }
  };

  return NoDebugger;

})();



},{}],25:[function(require,module,exports){
var NoEmptyFunctions, isEmptyCode;

isEmptyCode = function(node, astApi) {
  var nodeName;
  nodeName = astApi.getNodeName(node);
  return nodeName === 'Code' && node.body.isEmpty();
};

module.exports = NoEmptyFunctions = (function() {
  function NoEmptyFunctions() {}

  NoEmptyFunctions.prototype.rule = {
    name: 'no_empty_functions',
    level: 'ignore',
    message: 'Empty function',
    description: "Disallows declaring empty functions. The goal of this rule is that\nunintentional empty callbacks can be detected:\n<pre>\n<code>someFunctionWithCallback ->\ndoSomethingSignificant()\n</code>\n</pre>\nThe problem is that the call to\n<tt>doSomethingSignificant</tt> will be made regardless\nof <tt>someFunctionWithCallback</tt>'s execution. It can\nbe because you did not indent the call to\n<tt>doSomethingSignificant</tt> properly.\n\nIf you really meant that <tt>someFunctionWithCallback</tt>\nshould call a callback that does nothing, you can write your code\nthis way:\n<pre>\n<code>someFunctionWithCallback ->\n    undefined\ndoSomethingSignificant()\n</code>\n</pre>"
  };

  NoEmptyFunctions.prototype.lintAST = function(node, astApi) {
    this.lintNode(node, astApi);
    return void 0;
  };

  NoEmptyFunctions.prototype.lintNode = function(node, astApi) {
    var error;
    if (isEmptyCode(node, astApi)) {
      error = astApi.createError({
        lineNumber: node.locationData.first_line + 1
      });
      this.errors.push(error);
    }
    return node.eachChild((function(_this) {
      return function(child) {
        return _this.lintNode(child, astApi);
      };
    })(this));
  };

  return NoEmptyFunctions;

})();



},{}],26:[function(require,module,exports){
var NoEmptyParamList;

module.exports = NoEmptyParamList = (function() {
  function NoEmptyParamList() {}

  NoEmptyParamList.prototype.rule = {
    name: 'no_empty_param_list',
    level: 'ignore',
    message: 'Empty parameter list is forbidden',
    description: "This rule prohibits empty parameter lists in function definitions.\n<pre>\n<code># The empty parameter list in here is unnecessary:\nmyFunction = () -&gt;\n\n# We might favor this instead:\nmyFunction = -&gt;\n</code>\n</pre>\nEmpty parameter lists are permitted by default."
  };

  NoEmptyParamList.prototype.tokens = ["PARAM_START"];

  NoEmptyParamList.prototype.lintToken = function(token, tokenApi) {
    var nextType;
    nextType = tokenApi.peek()[0];
    return nextType === 'PARAM_END';
  };

  return NoEmptyParamList;

})();



},{}],27:[function(require,module,exports){
var NoImplicitBraces;

module.exports = NoImplicitBraces = (function() {
  NoImplicitBraces.prototype.rule = {
    name: 'no_implicit_braces',
    level: 'ignore',
    message: 'Implicit braces are forbidden',
    strict: true,
    description: 'This rule prohibits implicit braces when declaring object literals.\nImplicit braces can make code more difficult to understand,\nespecially when used in combination with optional parenthesis.\n<pre>\n<code># Do you find this code ambiguous? Is it a\n# function call with three arguments or four?\nmyFunction a, b, 1:2, 3:4\n\n# While the same code written in a more\n# explicit manner has no ambiguity.\nmyFunction(a, b, {1:2, 3:4})\n</code>\n</pre>\nImplicit braces are permitted by default, since their use is\nidiomatic CoffeeScript.'
  };

  NoImplicitBraces.prototype.tokens = ['{', 'OUTDENT', 'CLASS'];

  function NoImplicitBraces() {
    this.isClass = false;
    this.classBrace = false;
  }

  NoImplicitBraces.prototype.lintToken = function(token, tokenApi) {
    var lineNum, previousToken, type, val;
    type = token[0], val = token[1], lineNum = token[2];
    if (type === 'OUTDENT' || type === 'CLASS') {
      return this.trackClass.apply(this, arguments);
    }
    if (token.generated) {
      if (this.classBrace) {
        this.classBrace = false;
        return;
      }
      if (!tokenApi.config[this.rule.name].strict) {
        previousToken = tokenApi.peek(-1)[0];
        if (previousToken === 'INDENT') {
          return;
        }
      }
      return true;
    }
  };

  NoImplicitBraces.prototype.trackClass = function(token, tokenApi) {
    var ln, n0, n1, ref, ref1, ref2;
    ref = [token, tokenApi.peek()], (ref1 = ref[0], n0 = ref1[0], ln = ref1[ref1.length - 1]), (ref2 = ref[1], n1 = ref2[0]);
    if (n0 === 'OUTDENT' && n1 === 'TERMINATOR') {
      this.isClass = false;
      this.classBrace = false;
    }
    if (n0 === 'CLASS') {
      this.isClass = true;
      this.classBrace = true;
    }
    return null;
  };

  return NoImplicitBraces;

})();



},{}],28:[function(require,module,exports){
var NoImplicitParens;

module.exports = NoImplicitParens = (function() {
  function NoImplicitParens() {}

  NoImplicitParens.prototype.rule = {
    name: 'no_implicit_parens',
    strict: true,
    level: 'ignore',
    message: 'Implicit parens are forbidden',
    description: "This rule prohibits implicit parens on function calls.\n<pre>\n<code># Some folks don't like this style of coding.\nmyFunction a, b, c\n\n# And would rather it always be written like this:\nmyFunction(a, b, c)\n</code>\n</pre>\nImplicit parens are permitted by default, since their use is\nidiomatic CoffeeScript."
  };

  NoImplicitParens.prototype.tokens = ['CALL_END'];

  NoImplicitParens.prototype.lintToken = function(token, tokenApi) {
    var i, t;
    if (token.generated) {
      if (tokenApi.config[this.rule.name].strict !== false) {
        return true;
      } else {
        i = -1;
        while (true) {
          t = tokenApi.peek(i);
          if ((t == null) || (t[0] === 'CALL_START' && t.generated)) {
            return true;
          }
          if (t[2].first_line !== token[2].first_line) {
            return null;
          }
          i -= 1;
        }
      }
    }
  };

  return NoImplicitParens;

})();



},{}],29:[function(require,module,exports){
var NoInterpolationInSingleQuotes;

module.exports = NoInterpolationInSingleQuotes = (function() {
  function NoInterpolationInSingleQuotes() {}

  NoInterpolationInSingleQuotes.prototype.rule = {
    name: 'no_interpolation_in_single_quotes',
    level: 'ignore',
    message: 'Interpolation in single quoted strings is forbidden',
    description: 'This rule prohibits string interpolation in a single quoted string.\n<pre>\n<code># String interpolation in single quotes is not allowed:\nfoo = \'#{bar}\'\n\n# Double quotes is OK of course\nfoo = "#{bar}"\n</code>\n</pre>\nString interpolation in single quoted strings is permitted by\ndefault.'
  };

  NoInterpolationInSingleQuotes.prototype.tokens = ['STRING'];

  NoInterpolationInSingleQuotes.prototype.lintToken = function(token, tokenApi) {
    var hasInterpolation, tokenValue;
    tokenValue = token[1];
    hasInterpolation = tokenValue.match(/^\'.*#\{[^}]+\}.*\'$/);
    return hasInterpolation;
  };

  return NoInterpolationInSingleQuotes;

})();



},{}],30:[function(require,module,exports){
var NoNestedStringInterpolation;

module.exports = NoNestedStringInterpolation = (function() {
  NoNestedStringInterpolation.prototype.rule = {
    name: 'no_nested_string_interpolation',
    level: 'warn',
    message: 'Nested string interpolation is forbidden',
    description: 'This rule warns about nested string interpolation,\nas it tends to make code harder to read and understand.\n<pre>\n<code># Good!\nstr = "Book by #{firstName.toUpperCase()} #{lastName.toUpperCase()}"\n\n# Bad!\nstr = "Book by #{"#{firstName} #{lastName}".toUpperCase()}"\n</code>\n</pre>'
  };

  NoNestedStringInterpolation.prototype.tokens = ['STRING_START', 'STRING_END'];

  function NoNestedStringInterpolation() {
    this.startedStrings = 0;
    this.generatedError = false;
  }

  NoNestedStringInterpolation.prototype.lintToken = function(arg, tokenApi) {
    var type;
    type = arg[0];
    if (type === 'STRING_START') {
      return this.trackStringStart();
    } else {
      return this.trackStringEnd();
    }
  };

  NoNestedStringInterpolation.prototype.trackStringStart = function() {
    this.startedStrings += 1;
    if (this.startedStrings <= 1 || this.generatedError) {
      return;
    }
    this.generatedError = true;
    return true;
  };

  NoNestedStringInterpolation.prototype.trackStringEnd = function() {
    this.startedStrings -= 1;
    if (this.startedStrings === 1) {
      return this.generatedError = false;
    }
  };

  return NoNestedStringInterpolation;

})();



},{}],31:[function(require,module,exports){
var NoPlusPlus;

module.exports = NoPlusPlus = (function() {
  function NoPlusPlus() {}

  NoPlusPlus.prototype.rule = {
    name: 'no_plusplus',
    level: 'ignore',
    message: 'The increment and decrement operators are forbidden',
    description: "This rule forbids the increment and decrement arithmetic operators.\nSome people believe the <tt>++</tt> and <tt>--</tt> to be cryptic\nand the cause of bugs due to misunderstandings of their precedence\nrules.\nThis rule is disabled by default."
  };

  NoPlusPlus.prototype.tokens = ["++", "--"];

  NoPlusPlus.prototype.lintToken = function(token, tokenApi) {
    return {
      context: "found '" + token[0] + "'"
    };
  };

  return NoPlusPlus;

})();



},{}],32:[function(require,module,exports){
var NoPrivateFunctionFatArrows,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = NoPrivateFunctionFatArrows = (function() {
  function NoPrivateFunctionFatArrows() {
    this.isFatArrowCode = bind(this.isFatArrowCode, this);
    this.isObject = bind(this.isObject, this);
    this.isValue = bind(this.isValue, this);
    this.isClass = bind(this.isClass, this);
    this.isCode = bind(this.isCode, this);
  }

  NoPrivateFunctionFatArrows.prototype.rule = {
    name: 'no_private_function_fat_arrows',
    level: 'warn',
    message: 'Used the fat arrow for a private function',
    description: "Warns when you use the fat arrow for a private function\ninside a class defintion scope. It is not necessary and\nit does not do anything."
  };

  NoPrivateFunctionFatArrows.prototype.lintAST = function(node, astApi) {
    this.astApi = astApi;
    this.lintNode(node);
    return void 0;
  };

  NoPrivateFunctionFatArrows.prototype.lintNode = function(node, functions) {
    var error;
    if (functions == null) {
      functions = [];
    }
    if (this.isFatArrowCode(node) && indexOf.call(functions, node) >= 0) {
      error = this.astApi.createError({
        lineNumber: node.locationData.first_line + 1
      });
      this.errors.push(error);
    }
    return node.eachChild((function(_this) {
      return function(child) {
        return _this.lintNode(child, (function() {
          switch (false) {
            case !this.isClass(node):
              return this.functionsOfClass(node);
            case !this.isCode(node):
              return [];
            default:
              return functions;
          }
        }).call(_this));
      };
    })(this));
  };

  NoPrivateFunctionFatArrows.prototype.isCode = function(node) {
    return this.astApi.getNodeName(node) === 'Code';
  };

  NoPrivateFunctionFatArrows.prototype.isClass = function(node) {
    return this.astApi.getNodeName(node) === 'Class';
  };

  NoPrivateFunctionFatArrows.prototype.isValue = function(node) {
    return this.astApi.getNodeName(node) === 'Value';
  };

  NoPrivateFunctionFatArrows.prototype.isObject = function(node) {
    return this.astApi.getNodeName(node) === 'Obj';
  };

  NoPrivateFunctionFatArrows.prototype.isFatArrowCode = function(node) {
    return this.isCode(node) && node.bound;
  };

  NoPrivateFunctionFatArrows.prototype.functionsOfClass = function(classNode) {
    var bodyNode, bodyValues;
    bodyValues = (function() {
      var i, len, ref, results;
      ref = classNode.body.expressions;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        bodyNode = ref[i];
        if (this.isValue(bodyNode) && this.isObject(bodyNode.base)) {
          continue;
        }
        results.push(bodyNode.value);
      }
      return results;
    }).call(this);
    return bodyValues.filter(this.isCode);
  };

  return NoPrivateFunctionFatArrows;

})();



},{}],33:[function(require,module,exports){
var NoStandAloneAt;

module.exports = NoStandAloneAt = (function() {
  function NoStandAloneAt() {}

  NoStandAloneAt.prototype.rule = {
    name: 'no_stand_alone_at',
    level: 'ignore',
    message: '@ must not be used stand alone',
    description: "This rule checks that no stand alone @ are in use, they are\ndiscouraged. Further information in CoffeScript issue <a\nhref=\"https://github.com/jashkenas/coffee-script/issues/1601\">\n#1601</a>"
  };

  NoStandAloneAt.prototype.tokens = ['@'];

  NoStandAloneAt.prototype.lintToken = function(token, tokenApi) {
    var isDot, isIdentifier, isIndexStart, isValidProtoProperty, nextToken, protoProperty, spaced;
    nextToken = tokenApi.peek();
    spaced = token.spaced;
    isIdentifier = nextToken[0] === 'IDENTIFIER';
    isIndexStart = nextToken[0] === 'INDEX_START';
    isDot = nextToken[0] === '.';
    if (nextToken[0] === '::') {
      protoProperty = tokenApi.peek(2);
      isValidProtoProperty = protoProperty[0] === 'IDENTIFIER';
    }
    if (spaced || (!isIdentifier && !isIndexStart && !isDot && !isValidProtoProperty)) {
      return true;
    }
  };

  return NoStandAloneAt;

})();



},{}],34:[function(require,module,exports){
var NoTabs, indentationRegex,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

indentationRegex = /\S/;

module.exports = NoTabs = (function() {
  function NoTabs() {}

  NoTabs.prototype.rule = {
    name: 'no_tabs',
    level: 'error',
    message: 'Line contains tab indentation',
    description: "This rule forbids tabs in indentation. Enough said. It is enabled by\ndefault."
  };

  NoTabs.prototype.lintLine = function(line, lineApi) {
    var indentation;
    indentation = line.split(indentationRegex)[0];
    if (lineApi.lineHasToken() && indexOf.call(indentation, '\t') >= 0) {
      return true;
    } else {
      return null;
    }
  };

  return NoTabs;

})();



},{}],35:[function(require,module,exports){
var NoThis;

module.exports = NoThis = (function() {
  function NoThis() {}

  NoThis.prototype.rule = {
    name: 'no_this',
    description: 'This rule prohibits \'this\'.\nUse \'@\' instead.',
    level: 'ignore',
    message: "Don't use 'this', use '@' instead"
  };

  NoThis.prototype.tokens = ['THIS'];

  NoThis.prototype.lintToken = function(token, tokenApi) {
    return true;
  };

  return NoThis;

})();



},{}],36:[function(require,module,exports){
var NoThrowingStrings;

module.exports = NoThrowingStrings = (function() {
  function NoThrowingStrings() {}

  NoThrowingStrings.prototype.rule = {
    name: 'no_throwing_strings',
    level: 'error',
    message: 'Throwing strings is forbidden',
    description: "This rule forbids throwing string literals or interpolations. While\nJavaScript (and CoffeeScript by extension) allow any expression to\nbe thrown, it is best to only throw <a\nhref=\"https://developer.mozilla.org\n/en/JavaScript/Reference/Global_Objects/Error\"> Error</a> objects,\nbecause they contain valuable debugging information like the stack\ntrace. Because of JavaScript's dynamic nature, CoffeeLint cannot\nensure you are always throwing instances of <tt>Error</tt>. It will\nonly catch the simple but real case of throwing literal strings.\n<pre>\n<code># CoffeeLint will catch this:\nthrow \"i made a boo boo\"\n\n# ... but not this:\nthrow getSomeString()\n</code>\n</pre>\nThis rule is enabled by default."
  };

  NoThrowingStrings.prototype.tokens = ['THROW'];

  NoThrowingStrings.prototype.lintToken = function(token, tokenApi) {
    var n1, nextIsString, ref;
    ref = tokenApi.peek(), n1 = ref[0];
    nextIsString = n1 === 'STRING' || n1 === 'STRING_START';
    return nextIsString;
  };

  return NoThrowingStrings;

})();



},{}],37:[function(require,module,exports){
var NoTrailingSemicolons, regexes,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  slice = [].slice;

regexes = {
  trailingSemicolon: /;\r?$/
};

module.exports = NoTrailingSemicolons = (function() {
  function NoTrailingSemicolons() {}

  NoTrailingSemicolons.prototype.rule = {
    name: 'no_trailing_semicolons',
    level: 'error',
    message: 'Line contains a trailing semicolon',
    description: "This rule prohibits trailing semicolons, since they are needless\ncruft in CoffeeScript.\n<pre>\n<code># This semicolon is meaningful.\nx = '1234'; console.log(x)\n\n# This semicolon is redundant.\nalert('end of line');\n</code>\n</pre>\nTrailing semicolons are forbidden by default."
  };

  NoTrailingSemicolons.prototype.lintLine = function(line, lineApi) {
    var endPos, first, hasNewLine, hasSemicolon, i, last, lineTokens, newLine, ref, ref1, startCounter, startPos, stopTokens, tokenLen;
    lineTokens = lineApi.getLineTokens();
    tokenLen = lineTokens.length;
    stopTokens = ['TERMINATOR', 'HERECOMMENT'];
    if (tokenLen === 1 && (ref = lineTokens[0][0], indexOf.call(stopTokens, ref) >= 0)) {
      return;
    }
    newLine = line;
    if (tokenLen > 1 && lineTokens[tokenLen - 1][0] === 'TERMINATOR') {
      startPos = lineTokens[tokenLen - 2][2].last_column + 1;
      endPos = lineTokens[tokenLen - 1][2].first_column;
      if (startPos !== endPos) {
        startCounter = startPos;
        while (line[startCounter] !== '#' && startCounter < line.length) {
          startCounter++;
        }
        newLine = line.substring(0, startCounter).replace(/\s*$/, '');
      }
    }
    hasSemicolon = regexes.trailingSemicolon.test(newLine);
    first = 2 <= lineTokens.length ? slice.call(lineTokens, 0, i = lineTokens.length - 1) : (i = 0, []), last = lineTokens[i++];
    hasNewLine = last && (last.newLine != null);
    if (hasSemicolon && !hasNewLine && lineApi.lineHasToken() && !((ref1 = last[0]) === 'STRING' || ref1 === 'IDENTIFIER' || ref1 === 'STRING_END')) {
      return true;
    }
  };

  return NoTrailingSemicolons;

})();



},{}],38:[function(require,module,exports){
var NoTrailingWhitespace, regexes;

regexes = {
  trailingWhitespace: /[^\s]+[\t ]+\r?$/,
  onlySpaces: /^[\t ]+\r?$/,
  lineHasComment: /^\s*[^\#]*\#/
};

module.exports = NoTrailingWhitespace = (function() {
  function NoTrailingWhitespace() {}

  NoTrailingWhitespace.prototype.rule = {
    name: 'no_trailing_whitespace',
    level: 'error',
    message: 'Line ends with trailing whitespace',
    allowed_in_comments: false,
    allowed_in_empty_lines: true,
    description: "This rule forbids trailing whitespace in your code, since it is\nneedless cruft. It is enabled by default."
  };

  NoTrailingWhitespace.prototype.lintLine = function(line, lineApi) {
    var i, len, ref, ref1, ref2, str, token, tokens;
    if (!((ref = lineApi.config['no_trailing_whitespace']) != null ? ref.allowed_in_empty_lines : void 0)) {
      if (regexes.onlySpaces.test(line)) {
        return true;
      }
    }
    if (regexes.trailingWhitespace.test(line)) {
      if (!((ref1 = lineApi.config['no_trailing_whitespace']) != null ? ref1.allowed_in_comments : void 0)) {
        return true;
      }
      line = line;
      tokens = lineApi.tokensByLine[lineApi.lineNumber];
      if (!tokens) {
        return null;
      }
      ref2 = (function() {
        var j, len, results;
        results = [];
        for (j = 0, len = tokens.length; j < len; j++) {
          token = tokens[j];
          if (token[0] === 'STRING') {
            results.push(token[1]);
          }
        }
        return results;
      })();
      for (i = 0, len = ref2.length; i < len; i++) {
        str = ref2[i];
        line = line.replace(str, 'STRING');
      }
      if (!regexes.lineHasComment.test(line)) {
        return true;
      }
    }
  };

  return NoTrailingWhitespace;

})();



},{}],39:[function(require,module,exports){
var NoUnnecessaryDoubleQuotes;

module.exports = NoUnnecessaryDoubleQuotes = (function() {
  NoUnnecessaryDoubleQuotes.prototype.rule = {
    name: 'no_unnecessary_double_quotes',
    level: 'ignore',
    message: 'Unnecessary double quotes are forbidden',
    description: 'This rule prohibits double quotes unless string interpolation is\nused or the string contains single quotes.\n<pre>\n<code># Double quotes are discouraged:\nfoo = "bar"\n\n# Unless string interpolation is used:\nfoo = "#{bar}baz"\n\n# Or they prevent cumbersome escaping:\nfoo = "I\'m just following the \'rules\'"\n</code>\n</pre>\nDouble quotes are permitted by default.'
  };

  function NoUnnecessaryDoubleQuotes() {
    this.regexps = [];
    this.interpolationLevel = 0;
  }

  NoUnnecessaryDoubleQuotes.prototype.tokens = ['STRING', 'STRING_START', 'STRING_END'];

  NoUnnecessaryDoubleQuotes.prototype.lintToken = function(token, tokenApi) {
    var hasLegalConstructs, ref, stringValue, tokenValue, type;
    type = token[0], tokenValue = token[1];
    if (type === 'STRING_START' || type === 'STRING_END') {
      return this.trackParens.apply(this, arguments);
    }
    stringValue = tokenValue.match(/^\"(.*)\"$/);
    if (!stringValue) {
      return false;
    }
    if (((ref = tokenApi.peek(2)) != null ? ref[0] : void 0) === 'REGEX_END') {
      return false;
    }
    hasLegalConstructs = this.isInInterpolation() || this.hasSingleQuote(tokenValue);
    return !hasLegalConstructs;
  };

  NoUnnecessaryDoubleQuotes.prototype.isInInterpolation = function() {
    return this.interpolationLevel > 0;
  };

  NoUnnecessaryDoubleQuotes.prototype.trackParens = function(token, tokenApi) {
    if (token[0] === 'STRING_START') {
      this.interpolationLevel += 1;
    } else if (token[0] === 'STRING_END') {
      this.interpolationLevel -= 1;
    }
    return null;
  };

  NoUnnecessaryDoubleQuotes.prototype.hasSingleQuote = function(tokenValue) {
    return tokenValue.indexOf("'") !== -1;
  };

  return NoUnnecessaryDoubleQuotes;

})();



},{}],40:[function(require,module,exports){
var NoUnnecessaryFatArrows, any,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

any = function(arr, test) {
  return arr.reduce((function(res, elt) {
    return res || test(elt);
  }), false);
};

module.exports = NoUnnecessaryFatArrows = (function() {
  function NoUnnecessaryFatArrows() {
    this.needsFatArrow = bind(this.needsFatArrow, this);
    this.isThis = bind(this.isThis, this);
  }

  NoUnnecessaryFatArrows.prototype.rule = {
    name: 'no_unnecessary_fat_arrows',
    level: 'warn',
    message: 'Unnecessary fat arrow',
    description: "Disallows defining functions with fat arrows when `this`\nis not used within the function."
  };

  NoUnnecessaryFatArrows.prototype.lintAST = function(node, astApi) {
    this.astApi = astApi;
    this.lintNode(node);
    return void 0;
  };

  NoUnnecessaryFatArrows.prototype.lintNode = function(node) {
    var error;
    if ((this.isFatArrowCode(node)) && (!this.needsFatArrow(node))) {
      error = this.astApi.createError({
        lineNumber: node.locationData.first_line + 1
      });
      this.errors.push(error);
    }
    return node.eachChild((function(_this) {
      return function(child) {
        return _this.lintNode(child);
      };
    })(this));
  };

  NoUnnecessaryFatArrows.prototype.isCode = function(node) {
    return this.astApi.getNodeName(node) === 'Code';
  };

  NoUnnecessaryFatArrows.prototype.isFatArrowCode = function(node) {
    return this.isCode(node) && node.bound;
  };

  NoUnnecessaryFatArrows.prototype.isValue = function(node) {
    return this.astApi.getNodeName(node) === 'Value';
  };

  NoUnnecessaryFatArrows.prototype.isThis = function(node) {
    return this.isValue(node) && node.base.value === 'this';
  };

  NoUnnecessaryFatArrows.prototype.needsFatArrow = function(node) {
    return this.isCode(node) && (any(node.params, (function(_this) {
      return function(param) {
        return param.contains(_this.isThis) != null;
      };
    })(this)) || (node.body.contains(this.isThis) != null) || (node.body.contains((function(_this) {
      return function(child) {
        if (!_this.astApi.getNodeName(child)) {
          return (child.isSuper != null) && child.isSuper;
        } else {
          return _this.isFatArrowCode(child) && _this.needsFatArrow(child);
        }
      };
    })(this)) != null));
  };

  return NoUnnecessaryFatArrows;

})();



},{}],41:[function(require,module,exports){
var NonEmptyConstructorNeedsParens, ParentClass,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ParentClass = require('./empty_constructor_needs_parens.coffee');

module.exports = NonEmptyConstructorNeedsParens = (function(superClass) {
  extend(NonEmptyConstructorNeedsParens, superClass);

  function NonEmptyConstructorNeedsParens() {
    return NonEmptyConstructorNeedsParens.__super__.constructor.apply(this, arguments);
  }

  NonEmptyConstructorNeedsParens.prototype.rule = {
    name: 'non_empty_constructor_needs_parens',
    level: 'ignore',
    message: 'Invoking a constructor without parens and with arguments',
    description: "Requires constructors with parameters to include the parens"
  };

  NonEmptyConstructorNeedsParens.prototype.handleExpectedCallStart = function(expectedCallStart) {
    if (expectedCallStart[0] === 'CALL_START' && expectedCallStart.generated) {
      return true;
    }
  };

  return NonEmptyConstructorNeedsParens;

})(ParentClass);



},{"./empty_constructor_needs_parens.coffee":15}],42:[function(require,module,exports){
var PreferEnglishOperator;

module.exports = PreferEnglishOperator = (function() {
  function PreferEnglishOperator() {}

  PreferEnglishOperator.prototype.rule = {
    name: 'prefer_english_operator',
    description: 'This rule prohibits &&, ||, ==, != and !.\nUse and, or, is, isnt, and not instead.\n!! for converting to a boolean is ignored.',
    level: 'ignore',
    doubleNotLevel: 'ignore',
    message: 'Don\'t use &&, ||, ==, !=, or !'
  };

  PreferEnglishOperator.prototype.tokens = ['COMPARE', 'UNARY_MATH', 'LOGIC'];

  PreferEnglishOperator.prototype.lintToken = function(token, tokenApi) {
    var actual_token, config, context, first_column, last_column, level, line, ref;
    config = tokenApi.config[this.rule.name];
    level = config.level;
    ref = token[2], first_column = ref.first_column, last_column = ref.last_column;
    line = tokenApi.lines[tokenApi.lineNumber];
    actual_token = line.slice(first_column, +last_column + 1 || 9e9);
    context = (function() {
      var ref1, ref2;
      switch (actual_token) {
        case '==':
          return 'Replace "==" with "is"';
        case '!=':
          return 'Replace "!=" with "isnt"';
        case '||':
          return 'Replace "||" with "or"';
        case '&&':
          return 'Replace "&&" with "and"';
        case '!':
          if (((ref1 = tokenApi.peek(1)) != null ? ref1[0] : void 0) === 'UNARY_MATH') {
            level = config.doubleNotLevel;
            return '"?" is usually better than "!!"';
          } else if (((ref2 = tokenApi.peek(-1)) != null ? ref2[0] : void 0) === 'UNARY_MATH') {
            return void 0;
          } else {
            return 'Replace "!" with "not"';
          }
          break;
        default:
          return void 0;
      }
    })();
    if (context != null) {
      return {
        level: level,
        context: context
      };
    }
  };

  return PreferEnglishOperator;

})();



},{}],43:[function(require,module,exports){
var SpaceOperators,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = SpaceOperators = (function() {
  SpaceOperators.prototype.rule = {
    name: 'space_operators',
    level: 'ignore',
    message: 'Operators must be spaced properly',
    description: "This rule enforces that operators have space around them."
  };

  SpaceOperators.prototype.tokens = ['+', '-', '=', '**', 'MATH', 'COMPARE', 'LOGIC', 'COMPOUND_ASSIGN', 'STRING_START', 'STRING_END', 'CALL_START', 'CALL_END'];

  function SpaceOperators() {
    this.callTokens = [];
    this.parenTokens = [];
    this.interpolationLevel = 0;
  }

  SpaceOperators.prototype.lintToken = function(arg, tokenApi) {
    var type;
    type = arg[0];
    if (type === 'CALL_START' || type === 'CALL_END') {
      this.trackCall.apply(this, arguments);
      return;
    }
    if (type === 'STRING_START' || type === 'STRING_END') {
      return this.trackParens.apply(this, arguments);
    }
    if (type === '+' || type === '-') {
      return this.lintPlus.apply(this, arguments);
    } else {
      return this.lintMath.apply(this, arguments);
    }
  };

  SpaceOperators.prototype.lintPlus = function(token, tokenApi) {
    var isUnary, p, ref, unaries;
    if (this.isInInterpolation() || this.isInExtendedRegex()) {
      return null;
    }
    p = tokenApi.peek(-1);
    unaries = ['TERMINATOR', '(', '=', '-', '+', ',', 'CALL_START', 'INDEX_START', '..', '...', 'COMPARE', 'IF', 'THROW', 'LOGIC', 'POST_IF', ':', '[', 'INDENT', 'COMPOUND_ASSIGN', 'RETURN', 'MATH', 'BY', 'LEADING_WHEN'];
    isUnary = !p ? false : (ref = p[0], indexOf.call(unaries, ref) >= 0);
    if ((isUnary && (token.spaced != null)) || (!isUnary && !token.newLine && (!token.spaced || (p && !p.spaced)))) {
      return {
        context: token[1]
      };
    } else {
      return null;
    }
  };

  SpaceOperators.prototype.lintMath = function(token, tokenApi) {
    var p;
    p = tokenApi.peek(-1);
    if (!token.newLine && (!token.spaced || (p && !p.spaced))) {
      return {
        context: token[1]
      };
    } else {
      return null;
    }
  };

  SpaceOperators.prototype.isInExtendedRegex = function() {
    var i, len, ref, t;
    ref = this.callTokens;
    for (i = 0, len = ref.length; i < len; i++) {
      t = ref[i];
      if (t.isRegex) {
        return true;
      }
    }
    return false;
  };

  SpaceOperators.prototype.isInInterpolation = function() {
    return this.interpolationLevel > 0;
  };

  SpaceOperators.prototype.trackCall = function(token, tokenApi) {
    var p;
    if (token[0] === 'CALL_START') {
      p = tokenApi.peek(-1);
      token.isRegex = p && p[0] === 'IDENTIFIER' && p[1] === 'RegExp';
      this.callTokens.push(token);
    } else {
      this.callTokens.pop();
    }
    return null;
  };

  SpaceOperators.prototype.trackParens = function(token, tokenApi) {
    if (token[0] === 'STRING_START') {
      this.interpolationLevel += 1;
    } else if (token[0] === 'STRING_END') {
      this.interpolationLevel -= 1;
    }
    return null;
  };

  return SpaceOperators;

})();



},{}],44:[function(require,module,exports){
var SpacingAfterComma;

module.exports = SpacingAfterComma = (function() {
  SpacingAfterComma.prototype.rule = {
    name: 'spacing_after_comma',
    description: 'This rule requires a space after commas.',
    level: 'ignore',
    message: 'Spaces are required after commas'
  };

  SpacingAfterComma.prototype.tokens = [',', 'REGEX_START', 'REGEX_END'];

  function SpacingAfterComma() {
    this.inRegex = false;
  }

  SpacingAfterComma.prototype.lintToken = function(token, tokenApi) {
    var type;
    type = token[0];
    if (type === 'REGEX_START') {
      this.inRegex = true;
      return;
    }
    if (type === 'REGEX_END') {
      this.inRegex = false;
      return;
    }
    if (!(token.spaced || token.newLine || token.generated || this.isRegexFlag(token, tokenApi))) {
      return {
        context: token[1]
      };
    }
  };

  SpacingAfterComma.prototype.isRegexFlag = function(token, tokenApi) {
    var maybeEnd;
    if (!this.inRegex) {
      return false;
    }
    maybeEnd = tokenApi.peek(3);
    return (maybeEnd != null ? maybeEnd[0] : void 0) === 'REGEX_END';
  };

  return SpacingAfterComma;

})();



},{}],45:[function(require,module,exports){
var TransformMessesUpLineNumbers;

module.exports = TransformMessesUpLineNumbers = (function() {
  function TransformMessesUpLineNumbers() {}

  TransformMessesUpLineNumbers.prototype.rule = {
    name: 'transform_messes_up_line_numbers',
    level: 'warn',
    message: 'Transforming source messes up line numbers',
    description: "This rule detects when changes are made by transform function,\nand warns that line numbers are probably incorrect."
  };

  TransformMessesUpLineNumbers.prototype.tokens = [];

  TransformMessesUpLineNumbers.prototype.lintToken = function(token, tokenApi) {};

  return TransformMessesUpLineNumbers;

})();



},{}]},{},[1])(1)
});