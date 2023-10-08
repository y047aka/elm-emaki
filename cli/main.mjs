#!/usr/bin/env node

import { promisify } from "node:util";
import fs from "node:fs/promises";
import path from "node:path";
import child_process from "node:child_process";

main();

async function main() {
  console.debug("current working directory", process.cwd());
  const elmEmakiProjectRoot = path.resolve(process.cwd(), ".elm-emaki");
  console.log("create elm-emaki project dir (.emaki)");
  generateElmEmakiProject();

  console.log("build elm-emaki project");

  // FIXME: should fix `Error: spawn /bin/sh ENOENT`
  await promisify(child_process.exec)(
    "npx elm make src/Main.elm --output=output/index.html",
    { cwd: elmEmakiProjectRoot }
  );

  const port = parseInt(process.env.EMAKI_PORT, 10) || 8000;

  console.log(`serve elm-emaki project at ${port}`);

  // FIXME: should fix `Error: spawn /bin/sh ENOENT`
  const serveProcess = child_process.exec(
    `npx serve -p ${port} .elm-emaki/output`
  );
  serveProcess.stdout.pipe(process.stdout);
  serveProcess.stderr.pipe(process.stdin);
}

async function generateElmEmakiProject() {
  const elmJson = `
{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.2",
            "elm/core": "1.0.5",
            "elm/html": "1.0.0"
        },
        "indirect": {
            "elm/json": "1.1.3",
            "elm/time": "1.0.0",
            "elm/url": "1.0.0",
            "elm/virtual-dom": "1.0.3"
        }
    },
    "test-dependencies": {
        "direct": {},
        "indirect": {}
    }
}
`;
  const elmMain = `
module Main exposing (main)

import Html exposing (Html, text)


main : Html msg
main =
    text "Hello, World!"

    `;

  const gitignore = "*\n";

  // mkdir -p
  await fs.mkdir(path.join(process.cwd(), ".elm-emaki", "src"), {
    recursive: true,
  });

  await Promise.all([
    fs.writeFile(
      path.join(process.cwd(), ".elm-emaki", ".gitignore"),
      gitignore
    ),
    fs.writeFile(path.join(process.cwd(), ".elm-emaki", "elm.json"), elmJson),
    fs.writeFile(
      path.join(process.cwd(), ".elm-emaki", "src", "Main.elm"),
      elmMain
    ),
  ]);
}
