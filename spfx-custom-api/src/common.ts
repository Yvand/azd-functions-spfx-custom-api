export const CommonConfig = {
    ClientAppId: "77dd86d9-ea20-4816-89d7-4cc098e685ed",
    FunctionAppHost: "func-api-azzjijutvy2vc.azurewebsites.net",
    FunctionAppCode: "Yjnsljk44wahtUzwQkOkco405m87lKYXVQ7o8tO9Ok9_AzFu1anjDw==",
}

// This method awaits on async calls and catches the exception if there is any - https://dev.to/sobiodarlington/better-error-handling-with-async-await-2e5m
export const safeWait = (promise: Promise<any>) => {
    return promise
        .then(data => ([data, undefined]))
        .catch(error => Promise.resolve([undefined, error]));
}
