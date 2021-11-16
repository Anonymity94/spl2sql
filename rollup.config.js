import { babel } from "@rollup/plugin-babel";
import commonjs from "@rollup/plugin-commonjs";
import clear from "rollup-plugin-clear";
import { uglify } from "rollup-plugin-uglify";
import pkg from "./package.json";

var banner = [
  `/**`,
  ` * ${pkg.name} - ${pkg.description}`,
  ` * @version v${pkg.version}`,
  ` * @author ${pkg.author}`,
  ` * @buildAt ${new Date().toISOString()}`,
  ` * Released under the ${pkg.license} License.`,
  ` **/`,
].join("\n");

export default [
  {
    input: "lib/converter.js",
    output: [
      {
        name: "splToSqlConverter",
        file: pkg.main,
        format: "umd",
        // sourcemap: true,
      },
    ],
    plugins: [
      clear({ targets: ["dist"] }),
      commonjs(),
      babel(),
      uglify({
        output: {
          // @see: https://github.com/TrySound/rollup-plugin-uglify/issues/7#issuecomment-374331668
          preamble: banner,
        },
      }),
    ],
  },
];
