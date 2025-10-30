#! /usr/bin/env node
import { readFile, writeFile } from 'fs/promises';

const packageFilePath = "../spfx-solution/config/package-solution.json"
const newAppNameValue = process.argv[2];

console.log(`Updating file ${packageFilePath} with new value for the resource: '${newAppNameValue}'`);
let fileContent = JSON.parse(await readFile(packageFilePath, "utf8"));
fileContent.solution.webApiPermissionRequests[0].resource = newAppNameValue;
await writeFile(packageFilePath, JSON.stringify(fileContent, null, 2), { encoding: 'utf8' });
console.log(`Updated webApiPermissionRequests in ${packageFilePath}:\n${JSON.stringify(fileContent.solution.webApiPermissionRequests, null, 2)}`);
