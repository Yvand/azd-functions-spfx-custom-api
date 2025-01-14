export const CommonConfig = {
    ClientAppId: "5d7c36dd-9731-4fc2-9d3a-fe945f7e0084",
    FunctionAppHost: "func-api-azzjijutvy2vc.azurewebsites.net",
    FunctionAppCode: "Yjnsljk44wahtUzwQkOkco405m87lKYXVQ7o8tO9Ok9_AzFu1anjDw==",
}

// This method awaits on async calls and catches the exception if there is any - https://dev.to/sobiodarlington/better-error-handling-with-async-await-2e5m
export const safeWait = (promise: Promise<any>) => {
    return promise
        .then(data => ([data, undefined]))
        .catch(error => Promise.resolve([undefined, error]));
}
