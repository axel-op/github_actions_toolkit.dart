const core = require('@actions/core');
const exec = require('@actions/exec');
const path = require('path');

async function run() {
  try {
    const appDir = __dirname;

    const execOptions = { cwd: appDir };

    core.startGroup('Getting dependencies');
    await exec.exec('pub', ['get'], execOptions);
    core.endGroup();

    execOptions.ignoreReturnCode = true;
    execOptions.silent = true;
    execOptions.listeners = {
      stdout: (data) => process.stdout.write(data.toString()),
      stderr: (data) => process.stderr.write(data.toString())
    };
    const exitCode = await exec.exec('dart', ['bin/main.dart'], execOptions);

    process.exitCode = exitCode;
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();