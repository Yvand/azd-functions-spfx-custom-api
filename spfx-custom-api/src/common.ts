export const CommonConfig = {
    ClientAppId: "77dd86d9-ea20-4816-89d7-4cc098e685ed",
    FunctionAppHost: "func-api-azzjijutvy2vc.azurewebsites.net",
    FunctionAppCode: "Yjnsljk44wahtUzwQkOkco405m87lKYXVQ7o8tO9Ok9_AzFu1anjDw==",
}

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