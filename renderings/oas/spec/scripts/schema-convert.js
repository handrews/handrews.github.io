#!/usr/bin/env node

'use strict';

const fs = require('fs');
const yaml = require('yaml');

function convert(
    filename,
    noDialectDate,
    vocabDate=false,
    dialectDate=false,
    strictDialectDate=false,
) {
    try {
        var s = fs.readFileSync(filename,'utf8');
        s = s.replace(
            /schema\/WORK-IN-PROGRESS/g,
            'schema/' + noDialectDate,
        );
        if (vocabDate) {
            s = s.replace(
                /meta\/base\/WORK-IN-PROGRESS/g,
                'meta/base/' + vocabDate,
            );
        }
        if (dialectDate) {
            s = s.replace(
                /dialect\/base\/WORK-IN-PROGRESS/g,
                'dialect/base/' + dialectDate,
            );
        }
        if (strictDialectDate) {
            s = s.replace(
                /schema-base\/WORK-IN-PROGRESS/g,
                'schema-base/' + strictDialectDate,
            );
        }
        const obj = yaml.parse(s, {prettyErrors: true});
        console.log(JSON.stringify(obj,null,2));
    }
    catch (ex) {
        console.warn('  ',ex.message);
        process.exitCode = 1;
    }
}

if (process.argv.length<4) {
    console.warn('Usage: convert-schema.js file.yaml YYYY-MM-DD [YYYY-MM-DD YYYY-MM-DD YYYY-MM-DD]');
}
else {
  if (process.argv.length>4) {
    convert(process.argv[2], process.argv[3], process.argv[4], process.argv[5], process.argv[6]);
  } else {
    convert(process.argv[2], process.argv[3]);
  }
}
