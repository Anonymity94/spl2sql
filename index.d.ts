export = SplToSqlConverter;
export as namespace converter;

declare namespace SplToSqlConverter {
  interface IParseOptions {
    /**
     * 结果是否返回json
     */
    json?: boolean;
    /**
     * 应用
     */
    applications?: {
      [propsName: string | number]: string;
    };
  }
  interface IParseResult {
    result: {
      source: string;
      target: string;
      params: {
        [propsName: string]: string | Array<string | number>;
      };
      dev: {
        expression: {
          WHERE: string;
          ORDER_BY: string;
          LIMIT: string;
          GENTIMES: {
            time_field: string;
            time_from: number;
            time_to: number;
          };
          COLUMNS: string;
        };
        fields: string[];
      };
    };
  }

  function parse(spl: string, options?: IParseOptions): IParseResult;
}
