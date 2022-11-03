const core = require('@actions/core');
const github = require('@actions/github');
const exec = require("@actions/exec");

async function run() {
    try {
        const filename = core.getInput('file-name');
        const src = __dirname;
        await exec.exec(`${src}/work.bat -v ${filename}`);
    } catch (error) {
        core.setFailed(error.message);
    }
}

run();