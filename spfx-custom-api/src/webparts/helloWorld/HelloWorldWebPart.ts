import { Version } from '@microsoft/sp-core-library';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';
import { AadHttpClient, HttpClientResponse } from '@microsoft/sp-http';

import styles from './HelloWorldWebPart.module.scss';

export interface IHelloWorldWebPartProps {
}

export default class HelloWorldWebPart extends BaseClientSideWebPart<IHelloWorldWebPartProps> {
  public render(): void {
    this.domElement.innerHTML = `<div class="${styles.helloWorld}">yooooooo</div>`;
    this.context.aadHttpClientFactory
      .getClient('5d7c36dd-9731-4fc2-9d3a-fe945f7e0084')
      .then((client: AadHttpClient): void => {
        client.get('https://func-api-6tqrn5iokosim.azurewebsites.net/api/getData?code=URMxTt3pK_7INep1MOMNOIKF6b-IRyT9VLaYKVe91oSeAzFuGVU0Uw==', AadHttpClient.configurations.v1)
          .then((response: HttpClientResponse) => {
            response.json().then((data: any) => {
              this.domElement.innerHTML = `<div class="${styles.helloWorld}">${JSON.stringify(data)}</div>`;
            });
          })
          .catch((error: any) => {
            this.domElement.innerHTML = `<div class="${styles.helloWorld}">${error.message}</div>`;
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
