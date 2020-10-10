const { src, dest } = require("gulp");
const babel = require("gulp-babel");
const uglify = require("gulp-uglify");
const rename = require("gulp-rename");

exports.default = function() {
  return (
    src("lib/splunk-spl-to-sql-converter.js")
      // es6 => es5
      .pipe(babel())
      // 压缩
      .pipe(uglify())
      // 重命名
      .pipe(rename({ extname: ".min.js" }))
      .pipe(dest("lib/"))
  );
};
