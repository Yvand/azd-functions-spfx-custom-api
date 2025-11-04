#! /usr/bin/env node
import { readFile, writeFile } from 'fs/promises';

const packageFilePath = "../spfx-solution/config/package-solution.json"
const newAppNameValue = process.argv[2];

const YELLOW = '\x1b[33m';
const NC = '\x1b[0m'; // No Color

console.log(`\nUpdating file '${packageFilePath}' with new value for the resource: '${newAppNameValue}'`);
let fileContent = JSON.parse(await readFile(packageFilePath, "utf8"));
const oldValue = fileContent.solution.webApiPermissionRequests[0].resource;
fileContent.solution.webApiPermissionRequests[0].resource = newAppNameValue;
await writeFile(packageFilePath, JSON.stringify(fileContent, null, 2), { encoding: 'utf8' });
console.log(`${YELLOW}Updated 'webApiPermissionRequests' in '${packageFilePath}':\nFormer value: ${oldValue}\nNew value: ${newAppNameValue}\nResulting JSON:\n${JSON.stringify(fileContent.solution.webApiPermissionRequests, null, 2)}${NC}`);
