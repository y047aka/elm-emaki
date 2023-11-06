#!/usr/bin/env npm exec --package=prompts@2.4 --commander@11.1 --package=tsx@3.14 -- tsx

import { Command, Option } from "commander";
import { init } from "./init.ts";
import { serve } from "./serve.ts";
import { resolve } from "node:path";

// FIXME: should read from package.json.
const PACKAGE_VERSION = "0.0.1";

const DEFAULT_EMAKI_RELATIVE_PATH = "./emaki";

const program = new Command();

program.name("elm-emaki").version(PACKAGE_VERSION);

program
  .command("init")
  .description("initialize emaki at ./emaki")
  .option("--dir <path>", "emaki root directory", DEFAULT_EMAKI_RELATIVE_PATH)
  .action(({ dir }) => init(resolve(process.cwd(), dir)));

program
  .command("serve")
  .description("serve emaki at ./emaki")
  .addOption(
    new Option("-p, --port <number>", "port number")
      .default(8000)
      .argParser(intParser),
  )
  .option("--dir <path>", "emaki root directory", DEFAULT_EMAKI_RELATIVE_PATH)
  .action(({ port, dir }) =>
    serve({ port, emakiProjectRoot: resolve(process.cwd(), dir) }),
  );

await program.parseAsync();

function intParser(val: string): number {
  const num = parseInt(val, 10);
  if (Number.isNaN(num)) throw new Error(`invalid number: ${val}`);
  return num;
}
