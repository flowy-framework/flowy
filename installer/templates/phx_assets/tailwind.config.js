module.exports = {
  content: [
    "./js/**/*.js",
    "./css/**/*.css",
    "../lib/**/*.ex",
    "../lib/**/*.*ex",
    "../**/*.*exs",
    "../../../config/*.*exs",

    // We need to include the Paleta dependency so the classes get picked up by JIT.
    "../deps/paleta/**/*.*ex",

    // TODO: This is for development only... we need to find a way to remove this line.
    "../../paleta/**/*.*ex"
  ]
};
