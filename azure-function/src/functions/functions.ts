import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { logError } from "../utils/loggingHandler.js";

export async function getData(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    try {
        const jsonData = [
            {
                id: 1,
                name: 'user1',
            },
            {
                id: 2,
                name: 'user2',
            },
            {
                id: 3,
                name: 'user3',
            },
        ];
        return { status: 200, jsonBody: jsonData };
    }
    catch (error: unknown) {
        const errorDetails = await logError(context, error, context.functionName);
        return { status: errorDetails.httpStatus, jsonBody: errorDetails };
    }
};

app.http('getData', { methods: ['GET'], authLevel: 'function', handler: getData });
