import child_process from "node:child_process";
import { promisify } from "node:util";
import { resolve } from "node:path";

type BuildTaskOptions = {
  port: number;
  emakiProjectRoot: string;
};
export async function serve({ port, emakiProjectRoot }: BuildTaskOptions) {
  console.log("build emaki project");

  await promisify(child_process.exec)(
    "npx elm make src/Main.elm --output=output/index.html",
    { cwd: resolve(emakiProjectRoot) },
  );

  console.log(`serve emaki at ${port}`);

  const serveProcess = child_process.exec(`npx serve -p ${port} output`, {
    cwd: emakiProjectRoot,
  });
  serveProcess.stdout?.pipe(process.stdout);
  serveProcess.stderr?.pipe(process.stdin);
}
