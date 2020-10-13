const { src, dest } = require("gulp");
const babel = require("gulp-babel");
const uglify = require("gulp-uglify");
const rename = require("gulp-rename");
const header = require("gulp-header");
var pkg = require("./package.json");
var banner = [
  "/**",
  " * <%= pkg.name %> - <%= pkg.description %>",
  " * @version v<%= pkg.version %>",
  " * @author <%= pkg.author %>",
  " * @buildAt <%= buildTime %>",
  " */",
  ""
].join("\n");

exports.default = function() {
  return (
    src("lib/converter.js")
      // es6 => es5
      .pipe(babel())
      // 增加生成时间
      .pipe(
        header(banner, {
          pkg,
          buildTime: new Date().toISOString()
        })
      )
      .pipe(dest("lib/"))
      // 压缩
      .pipe(
        uglify({
          compress: {
            negate_iife: false,
            drop_console: true
          }
        })
      )
      // 增加生成时间
      .pipe(
        header(banner, {
          pkg,
          buildTime: new Date().toISOString()
        })
      )
      // 重命名
      .pipe(rename({ extname: ".min.js" }))
      .pipe(dest("lib/"))
  );
};
