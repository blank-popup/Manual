const { format, createLogger, transports } = require('winston');
const { combine, timestamp, label, json, printf } = format;
require('winston-daily-rotate-file');
const path = require('path');
const ROOT_PROJECT = path.join(__dirname);

const fs = require('fs');
let config = JSON.parse(fs.readFileSync('./mmLogit.json'));

const mmFormat = printf(({ level, message, timestamp }) => {
    let date = new Date(timestamp);
    let yyyy = date.getFullYear().toString();
    let mm = (date.getMonth() + 1).toString().padStart(2, '0');
    let dd = date.getDate().toString().padStart(2, '0');
    let hour = date.getHours().toString().padStart(2, '0');
    let minute = date.getMinutes().toString().padStart(2, '0');
    let second = date.getSeconds().toString().padStart(2, '0');
    let msecond = date.getMilliseconds().toString().padStart(3, '0');

    return `${yyyy}-${mm}-${dd} ${hour}:${minute}:${second}.${msecond} [${level}] ${message}`;
});

config.transports = [];
let porters_file = config.transports_file;
let porters_console = config.transports_console;
for (let ii = 0; ii < porters_file.length; ++ ii) {
    porters_file[ii].filename = ROOT_PROJECT + porters_file[ii].filename;
    config.transports.push(new transports.DailyRotateFile(porters_file[ii]));
}
for (let ii = 0; ii < porters_console.length; ++ ii) {
    config.transports.push(new transports.Console(porters_console[ii]));
}
delete config.transports_file;
delete config.transports_console;

const logger = createLogger({
    ...config,
    format: combine(timestamp(), mmFormat),
});

silly = function() {
    logger.silly.apply(logger, formatLogArgs(arguments));
}
debug = function() {
    logger.debug.apply(logger, formatLogArgs(arguments));
}
verbose = function() {
    logger.verbose.apply(logger, formatLogArgs(arguments));
}
http = function() {
    logger.http.apply(logger, formatLogArgs(arguments));
}
info = function() {
    logger.info.apply(logger, formatLogArgs(arguments));
}
warn = function() {
    logger.warn.apply(logger, formatLogArgs(arguments));
}
error = function() {
    logger.error.apply(logger, formatLogArgs(arguments));
}

module.exports = {
    silly,
    debug,
    verbose,
    http,
    info,
    warn,
    error,
}


function formatLogArgs(args) {
    args = Array.prototype.slice.call(args);
    var stackInfo = getStackInfo(1);
    if (stackInfo) {
        var callee = '(' + stackInfo.relativePath + ':' + stackInfo.line + ')';
        if (typeof args[0] === 'string') {
            args[0] = args[0] + ' ' + callee;
        } else {
            args.unshift(callee);
        }
    }
    return args;
}

function getStackInfo(stackIndex) {
    var stacklist = (new Error()).stack.split('\n').slice(3)
    var stackReg = /at\s+(.*)\s+\((.*):(\d*):(\d*)\)/gi
    var stackReg2 = /at\s+()(.*):(\d*):(\d*)/gi

    var s = stacklist[stackIndex] || stacklist[0]
    var sp = stackReg.exec(s) || stackReg2.exec(s)

    if (sp && sp.length === 5) {
        return {
            method: sp[1],
            relativePath: path.relative(ROOT_PROJECT, sp[2]),
            line: sp[3],
            pos: sp[4],
            file: path.basename(sp[2]),
            stack: stacklist.join('\n')
        }
    }
}
