#!/usr/bin/env npx tsx

import { promisify } from "node:util";
import fs from "node:fs/promises";
import path from "node:path";
import child_process from "node:child_process";

const ELM_EMAKI_PROJECT_ROOT: string = path.resolve(process.cwd(), ".emaki");

main();

async function main(): Promise<void> {
  console.log(`create emaki project dir ${ELM_EMAKI_PROJECT_ROOT}`);
  await generateElmEmakiProject(ELM_EMAKI_PROJECT_ROOT);

  console.log("build elm-emaki project");

  await promisify(child_process.exec)(
    "npx elm make src/Main.elm --output=output/index.html",
    { cwd: ELM_EMAKI_PROJECT_ROOT },
  );

  const port = parseInt(process.env["EMAKI_PORT"] || "", 10) || 8000;

  console.log(`serve elm-emaki project at ${port}`);

  const serveProcess = child_process.exec(`npx serve -p ${port} output`, {
    cwd: ELM_EMAKI_PROJECT_ROOT,
  });
  serveProcess.stdout?.pipe(process.stdout);
  serveProcess.stderr?.pipe(process.stdin);
}

async function generateElmEmakiProject(projectRootDir: string): Promise<void> {
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
  await fs.mkdir(path.resolve(projectRootDir, "src"), {
    recursive: true,
  });

  await Promise.all([
    fs.writeFile(path.resolve(projectRootDir, ".gitignore"), gitignore),
    fs.writeFile(path.resolve(projectRootDir, "elm.json"), elmJson),
    fs.writeFile(path.resolve(projectRootDir, "src", "Main.elm"), elmMain),
  ]);
}
