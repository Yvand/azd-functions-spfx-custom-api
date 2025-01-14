import { Version } from '@microsoft/sp-core-library';
import { AadHttpClient, HttpClientResponse } from '@microsoft/sp-http';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';
import { CommonConfig, formatError } from '../../common';
import styles from './CustomApiWebPartWebPart.module.scss';

export interface ICustomApiWebPartWebPartProps {
}

export default class CustomApiWebPartWebPart extends BaseClientSideWebPart<ICustomApiWebPartWebPartProps> {
  public async render(): Promise<void> {
    let output: string = "Webpart is loaded";
    try {
      output += `<br>Getting an access token for the resource '${CommonConfig.ClientAppId}'`;
      const client: AadHttpClient = await this.context.aadHttpClientFactory.getClient(CommonConfig.ClientAppId);
      const functionUrl = `https://${CommonConfig.FunctionAppHost}/api/getData?code=${CommonConfig.FunctionAppCode}`;
      output += `<br>Access token received<br>Connecting to the function app '${functionUrl}'`;
      const response: HttpClientResponse = await client.get(functionUrl, AadHttpClient.configurations.v1);
      output += `<br>Data received:<br>`;
      const data = await response.json();
      output += JSON.stringify(data);
    }
    catch (error: unknown) {
      const errorMessage = formatError(error);
      output += `<br>Unexpected error: ${errorMessage}`;
      return;
    }
    finally {
      this.domElement.innerHTML = `<div class="${styles.customApiWebPart}"${output}</div>`;
    }
  }

  protected onInit(): Promise<void> {
    return super.onInit();
  }

  protected get dataVersion(): Version {
    return Version.parse('1.0');
  }
}
