import { Version } from '@microsoft/sp-core-library';
import { AadHttpClient, HttpClientResponse } from '@microsoft/sp-http';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';
import { IPropertyPaneConfiguration, PropertyPaneTextField } from '@microsoft/sp-property-pane'
import { formatError } from '../../common';
import styles from './CustomApiWebPartWebPart.module.scss';

export interface ICustomApiWebPartWebPartProps {
  clientAppId: string;
  functionAppHost: string;
  functionAppCode: string;
}

export default class CustomApiWebPartWebPart extends BaseClientSideWebPart<ICustomApiWebPartWebPartProps> {
  public async render(): Promise<void> {
    this.domElement.innerHTML = `<div class="${styles.customApiWebPart}">Webpart is loaded</div>`;
    const clientAppId = this.properties.clientAppId;
    const functionAppHost = this.properties.functionAppHost;
    const functionAppCode = this.properties.functionAppCode;

    if (!clientAppId || !functionAppHost || !functionAppCode) {
      this.domElement.innerHTML += `<div class="${styles.customApiWebPart}">Configuration is missing, edit the webpart to provide the missing values</div>`;
      return;
    }

    try {
      this.domElement.innerHTML += `<div class="${styles.customApiWebPart}">Getting an access token for the resource '${clientAppId}'</div>`;
      const client: AadHttpClient = await this.context.aadHttpClientFactory.getClient(clientAppId);
      const functionUrl = `https://${functionAppHost}/api/getData?code=${functionAppCode}`;
      this.domElement.innerHTML += `<div class="${styles.customApiWebPart}">Access token received<br>Connecting to the function app '${functionUrl}'</div>`;
      const response: HttpClientResponse = await client.get(functionUrl, AadHttpClient.configurations.v1);
      if (response.status === 200) {
        this.domElement.innerHTML += `<div class="${styles.customApiWebPart}">Data received:</div>`;
        const data = await response.json();
        this.domElement.innerHTML += JSON.stringify(data);
      } else {
        this.domElement.innerHTML += `<div class="${styles.customApiWebPart}">Could not get the data from the function app, received HTTP status ${response.status}</div>`;
      }
    }
    catch (error: unknown) {
      const errorMessage = formatError(error);
      this.domElement.innerHTML += `<div class="${styles.customApiWebPart}">Unexpected error: ${errorMessage}`;
      return;
    }
    finally {
      this.domElement.innerHTML += `<div class="${styles.customApiWebPart}">Finished.</div>`;
    }
  }

  protected onInit(): Promise<void> {
    return super.onInit();
  }

  protected get dataVersion(): Version {
    return Version.parse('1.0');
  }

  protected getPropertyPaneConfiguration(): IPropertyPaneConfiguration {
    return {
      pages: [
        {
          header: {
            description: "Configure the webpart"
          },
          groups: [
            {
              groupName: "Settings",
              groupFields: [
                PropertyPaneTextField("clientAppId", {
                  label: "Client App ID",
                  description: "The client ID of the app registration created in your Entra ID tenant",
                  value: this.properties.clientAppId,
                }),
                PropertyPaneTextField("functionAppHost", {
                  label: "Azure function app hostname",
                  description: "The hostname of your Azure function app",
                  placeholder: "<yourAppName>.azurewebsites.net",
                  value: this.properties.functionAppHost,
                }),
                PropertyPaneTextField("functionAppCode", {
                  label: "Azure function app key",
                  description: "The value of one of the app keys of your Azure function app",
                  value: this.properties.functionAppCode,
                }),
              ]
            }
          ]
        }
      ],
    };
  }

  protected get disableReactivePropertyChanges(): boolean {
    return false;
  }
}
