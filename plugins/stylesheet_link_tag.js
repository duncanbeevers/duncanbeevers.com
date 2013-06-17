module.exports = function(env, callback) {

  env.helpers.stylesheet_link_tag = function() {
    var args = Array.prototype.slice.call(arguments);

    function flatten(o, src, map) {
      for (var i = 0, len = src.length; i < len; i++) {
        if (Array.isArray(src[i])) {
          arguments.callee(o, src[i], map);
        } else {
          o.push(map(src[i]));
        }
      }

      return o;
    }

    var o = flatten([], args, function(arg) {
      return "<link rel=\"" + arg + "\" type=\"text/css\"></link>";
    });

    return o.join("");
  };

  callback();
};
