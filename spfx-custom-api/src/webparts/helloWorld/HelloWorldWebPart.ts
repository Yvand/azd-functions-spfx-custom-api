import { Version } from '@microsoft/sp-core-library';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';
import { AadHttpClient, HttpClientResponse } from '@microsoft/sp-http';

import styles from './HelloWorldWebPart.module.scss';
import { CommonConfig } from '../../common';

export interface IHelloWorldWebPartProps {
}

export default class HelloWorldWebPart extends BaseClientSideWebPart<IHelloWorldWebPartProps> {
  public render(): void {
    this.domElement.innerHTML = `<div class="${styles.helloWorld}">Webpart is loaded.</div>`;
    this.context.aadHttpClientFactory
      .getClient(CommonConfig.ClientAppId)
      .then((client: AadHttpClient): void => {
        this.domElement.innerHTML += `<div class="${styles.helloWorld}">Got the access token for resource '${CommonConfig.ClientAppId}', connecting to the function app...</div>`;
        client.get(`https://${CommonConfig.FunctionAppHost}/api/getData?code=${CommonConfig.FunctionAppCode}`, AadHttpClient.configurations.v1)
          .then((response: HttpClientResponse) => {
            response.json().then((data: any) => {
              this.domElement.innerHTML += `<div class="${styles.helloWorld}">${JSON.stringify(data)}</div>`;
            });
          })
          .catch((error: any) => {
            this.domElement.innerHTML += `<div class="${styles.helloWorld}">${error.message}</div>`;
          });
      });
  }

  protected onInit(): Promise<void> {
    return super.onInit();
  }

  protected get dataVersion(): Version {
    return Version.parse('1.0');
  }
}
