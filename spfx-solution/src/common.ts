export function formatError(error: unknown): string {
    let errorMessage = "";
    if (error instanceof Error) {
        errorMessage += `${error.name}: ${error.message}`;
    } else if (typeof error === "string") {
        errorMessage = error;
    }
    else {
        errorMessage = JSON.stringify(error);
    }
    return errorMessage;
}