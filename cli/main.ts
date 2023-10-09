#!/usr/bin/env npx tsx
import { Command } from "commander";
import { init } from "./init";
import { serve } from "./serve";

// FIXME: should read from package.json.
const PACKAGE_VERSION = "0.0.1";

const program = new Command();

program.name("elm-emaki").version(PACKAGE_VERSION);

program
  .command("init")
  .description("initialize emaki-project at ./emaki")
  .action(() => init());

program
  .command("serve")
  .description("serve emaki-project at ./emaki")
  .option("-p, --port [port]", "port number", "8000")
  .action((options) => serve(options));

program.parse(process.argv);
