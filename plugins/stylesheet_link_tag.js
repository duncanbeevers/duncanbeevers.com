module.exports = function(wintersmith, callback) {
  var stylesView = function(env, locals, contents, templates, callback) {
    console.log("Apparently rendering the styles view?");
    callback();
  };

  wintersmith.registerView("styles", stylesView);
  callback();
};
