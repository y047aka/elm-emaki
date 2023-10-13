import { mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve, relative } from "node:path";
import prompt from "prompts";

type Path = string;

type FileContent = string;

type GenerateTemplates = Record<Path, FileContent>;

/**
 *
 */
export async function init(emakiRootDir: Path) {
  return generateElmEmakiProject(emakiRootDir);
}

async function generateElmEmakiProject(emakiRootDir: string): Promise<void> {
  const directories = Object.keys(generateTemplates).map((path) =>
    dirname(resolve(emakiRootDir, path))
  );

  await Promise.all(directories.map((dir) => mkdir(dir, { recursive: true })));

  for (const [path, content] of Object.entries(generateTemplates)) {
    await generateFile(emakiRootDir, path, content);
  }
}

const elmJson = `
{
    "type": "application",
    "source-directories": [
        "src",
        "../src"
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
}`;

const elmMain = `
module Main exposing (main)

import Html exposing (Html, text)


main : Html msg
main =
    text "Hello, World!"

    `;

const gitignore = `
# elm-package generated files
elm-stuff
# elm-repl generated files
repl-temp-*
`;

const generateTemplates: GenerateTemplates = {
  "./elm.json": elmJson,
  "./src/Main.elm": elmMain,
  "./.gitignore": gitignore,
};

const delay = (ms: number = 0) =>
  new Promise((resolve) => setTimeout(resolve, ms));

async function generateFile(
  emakiRootDir: Path,
  filePath: Path,
  content: FileContent
): Promise<void> {
  const outputPath = resolve(emakiRootDir, filePath);
  const relPath = relative(process.cwd(), outputPath);

  return writeFile(outputPath, content, { flag: "wx" })
    .then(() => console.log(`${relPath} ... generated`))
    .catch(async (err) => {
      if (err?.code !== "EEXIST") throw err;
      const { overwrite } = await prompt({
        type: "confirm",
        name: "overwrite",
        message: `${relPath} already exists. Overwrite?`,
        stdin: process.stdin,
        stdout: process.stdout,
        initial: false,
      });
      await delay(0); // wait for prompt feedback rendering

      if (overwrite) {
        return writeFile(outputPath, content, { flag: "w" }).then(() =>
          console.log(`${relPath} ... overwritten`)
        );
      }
    });
}
