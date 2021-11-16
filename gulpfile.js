const { src, dest, series } = require("gulp");
const babel = require("gulp-babel");
const uglify = require("gulp-uglify");
const rename = require("gulp-rename");
const header = require("gulp-header");
const del = require("del");
const pkg = require("./package.json");

var banner = [
  "/**",
  " * <%= pkg.name %> - <%= pkg.description %>",
  " * @version v<%= pkg.version %>",
  " * @author <%= pkg.author %>",
  " * @buildAt <%= buildTime %>",
  " */",
  "",
].join("\n");

const buildTime = new Date().toISOString();

function clean() {
  return del(["dist/**/*"]);
}

function build() {
  return (
    src("lib/compiler.js")
      // es6 => es5
      .pipe(babel())
      // 增加生成时间
      .pipe(
        header(banner, {
          pkg,
          buildTime,
        })
      )
      .pipe(rename("spl2sql.js"))
      .pipe(dest("dist/"))
      // 压缩
      .pipe(
        uglify({
          compress: {
            negate_iife: false,
            drop_console: true,
          },
        })
      )
      // 增加生成时间
      .pipe(
        header(banner, {
          pkg,
          buildTime,
        })
      )
      // 重命名
      .pipe(rename("spl2sql.min.js"))
      .pipe(dest("dist/"))
  );
}

exports.default = series(clean, build);
