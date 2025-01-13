import { InvocationContext } from "@azure/functions";
import { CommonConfig } from "./common.js";


export enum LogLevel {
    Verbose = 0,
    Info,
    Warning,
    Error,
}

interface ILogEntry {
    level: LogLevel;
    message: any;
    data: any;
}

/**
 * Internal function which writes the entry to the log: application insights if possible, or the console if in local environment
 * @param entry 
 */
function writeEntryToLog(entry: ILogEntry): void {
    let logcontext: InvocationContext = entry.data;
    if (logcontext) {
        switch (entry.level) {
            case LogLevel.Info:
                logcontext.log(entry.message);
                break;
            case LogLevel.Warning:
                logcontext.warn(entry.message);
                break;
            case LogLevel.Error:
                logcontext.error(entry.message);
                break;
            case LogLevel.Verbose:
                logcontext.trace(entry.message);
                break;
            default:
                logcontext.log(entry.message);
                break;
        }
    } else if (CommonConfig.IsLocalEnvironment) {
        console.log(entry.message);
    }
}

export interface IMessageDocument {
    timestamp: string;
    level: LogLevel;
    message: string;
}

export interface IErrorMessageDocument extends IMessageDocument {
    error: string;
    type: string;
    sprequestguid?: string;
    httpStatus?: number;
}

/**
 * Process the error, record an error message and return a document with details about the error
 * @param error 
 * @param logcontext 
 * @param message 
 * @returns document with details about the error
 */
export function logError(logcontext: InvocationContext, error: Error | unknown, message: string): IErrorMessageDocument {
    let errorDocument: IErrorMessageDocument = { timestamp: new Date().toISOString(), level: LogLevel.Error, message: message, error: "", type: "", httpStatus: 500 };
    let errorDetails = "";
    if (error instanceof Error) {
        if (error instanceof AggregateError) {
            errorDocument.type = error.name;
            errorDetails += `AggregateError with ${error.errors.length} errors: `;
            for (let i = 0; i < error.errors.length; i++) {
                errorDetails += `Error ${i}: ${error.errors[i].name}: ${error.errors[i].message}. `;
            }
        } else {
            errorDocument.type = error.name;
            errorDetails += error.message;
        }
    } else if (typeof error === "string") {
        errorDocument.type = "string";
        errorDetails = error;
    }
    else {
        errorDocument.type = "unknown";
        errorDetails = JSON.stringify(error);
    }

    errorDocument.error = errorDetails;
    writeEntryToLog({
        data: logcontext,
        level: errorDocument.level,
        message: JSON.stringify(errorDocument),
    });
    return errorDocument;
}

/**
 * record the message and return a document with additionnal details
 * @param logcontext 
 * @param message 
 * @param level 
 * @returns 
 */
export function logInfo(logcontext: InvocationContext, message: string, level: LogLevel = LogLevel.Info): IMessageDocument {
    const messageResponse: IMessageDocument = { timestamp: new Date().toISOString(), level: level, message: message };
    writeEntryToLog({
        data: logcontext,
        level: messageResponse.level,
        message: JSON.stringify(messageResponse),
    });
    return messageResponse;
}
