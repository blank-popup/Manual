const pino = require('pino');
const path = require('path');
const fs = require('fs');

const STACKTRACE_OFFSET = 2
const { symbols : { asJsonSym} } = pino

let config = JSON.parse(fs.readFileSync(__dirname + '/mmLogit.json'));

function getTimeString(timestamp) {
    let date = new Date(timestamp);
    let yyyy = date.getFullYear().toString();
    let mm = (date.getMonth() + 1).toString().padStart(2, '0');
    let dd = date.getDate().toString().padStart(2, '0');
    let hour = date.getHours().toString().padStart(2, '0');
    let minute = date.getMinutes().toString().padStart(2, '0');
    let second = date.getSeconds().toString().padStart(2, '0');
    let msecond = date.getMilliseconds().toString().padStart(3, '0');

    return `${yyyy}-${mm}-${dd} ${hour}:${minute}:${second}.${msecond}`;
}

function traceCaller (pinoInstance) {
    const get = (target, name) => name === asJsonSym ? asJson : target[name]

    function asJson (...args) {
        args[0] = args[0] || Object.create(null);
        let caller = Error().stack.split('\n');
        caller = caller.filter(s => !s.includes('node_modules/pino') && !s.includes('node_modules\\pino'))[STACKTRACE_OFFSET];
        caller = caller.substring(caller.indexOf(' (') + 2, caller.length - 1);
        caller = caller.replace(/^.*[\\\/]/, '');
        callerInfo = caller.split(':');
        args[0].caller = callerInfo[0] + ':' + callerInfo[1];
        return pinoInstance[asJsonSym].apply(this, args)
    }

    return new Proxy(pinoInstance, { get })
}

let streams = [];
let streams_file = config.stream.file;
let streams_console = config.stream.console;
for (let ii = 0; ii < streams_file.length; ++ ii) {
    let filename = streams_file[ii].filename;
    let timeString = getTimeString(new Date().getTime());
    filename = filename.replace('%DATE%', timeString.substring(0, 10));

    let stream = {
        ...streams_file[ii]
    };

    let pathLog = `${__dirname}/${filename}`
    let directoryLog = path.dirname(pathLog);
    if (fs.existsSync(directoryLog) == false) {
        fs.mkdirSync(directoryLog, { recursive: true });
    }
    stream.stream = pino.destination(pathLog);
    streams.push(stream);
}
for (let ii = 0; ii < streams_console.length; ++ ii) {
    let stream = {
        ...streams_console[ii]
    };
    stream.stream = process.stdout
    streams.push(stream);
}

const logger = traceCaller(pino({
    // // level: process.env.PINO_LOG_LEVEL || 'info',
    // level: 'trace',
    ...config.logger,
    // base: { group: 'application', pid: process.pid, hostname: os.hostname() },
    base: undefined,
    // timestamp: () => `,"time": "${new Date(Date.now()).toISOString()}"`,
    timestamp: () => `,"time":"${getTimeString(new Date().getTime())}"`,
    formatters: {
        level: (label) => {
            return { level: label };
        },
    },
},
pino.multistream(streams)
));

module.exports = logger;
