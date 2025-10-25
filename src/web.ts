/* eslint-disable @typescript-eslint/no-unused-vars */
import type {
    AllWebviewsResult,
    CreateWebviewOptions,
    ExecuteJavaScriptOptions,
    ExecuteJavaScriptResult,
    FocusedWebviewResult,
    GetWebviewsByUrlOptions,
    ListWebviewsResult,
    LoadUrlOptions,
    MsAppMultiWebviewPlugin,
    SendMessageOptions,
    SetFocusedWebviewOptions,
    SetWebviewFrameOptions,
    WebviewIdentifier,
    WebviewInfo,
    WebviewsByUrlResult,
} from './definitions'
import { WebPlugin } from '@capacitor/core'

export class MsAppMultiWebviewWeb extends WebPlugin implements MsAppMultiWebviewPlugin {
    async createWebview(_options: CreateWebviewOptions): Promise<void> {
        return Promise.reject(new Error('Not implemented on web.'))
    }

    async setFocusedWebview(_options: SetFocusedWebviewOptions): Promise<void> {
        return Promise.reject(new Error('Not implemented on web.'))
    }

    async getFocusedWebview(): Promise<FocusedWebviewResult> {
        return Promise.reject(new Error('Not implemented on web.'))
    }

    async hideWebview(_options: WebviewIdentifier): Promise<void> {
        return Promise.reject(new Error('Not implemented on web.'))
    }

    async showWebview(_options: WebviewIdentifier): Promise<void> {
        return Promise.reject(new Error('Not implemented on web.'))
    }

    async destroyWebview(_options: WebviewIdentifier): Promise<void> {
        return Promise.reject(new Error('Not implemented on web.'))
    }

    async loadUrl(_options: LoadUrlOptions): Promise<void> {
        throw this.unimplemented('Not implemented on web.')
    }

    async listWebviews(): Promise<ListWebviewsResult> {
        throw this.unimplemented('Not implemented on web.')
    }

    async getWebviewInfo(_options: WebviewIdentifier): Promise<WebviewInfo> {
        throw this.unimplemented('Not implemented on web.')
    }

    async getAllWebviews(): Promise<AllWebviewsResult> {
        throw this.unimplemented('Not implemented on web.')
    }

    async getWebviewsByUrl(_options: GetWebviewsByUrlOptions): Promise<WebviewsByUrlResult> {
        throw this.unimplemented('Not implemented on web.')
    }

    async setWebviewFrame(_options: SetWebviewFrameOptions): Promise<void> {
        throw this.unimplemented('Not implemented on web.')
    }

    async executeJavaScript(_options: ExecuteJavaScriptOptions): Promise<ExecuteJavaScriptResult> {
        throw this.unimplemented('Not implemented on web.')
    }

    async sendMessage(_options: SendMessageOptions): Promise<void> {
        throw this.unimplemented('Not implemented on web.')
    }
}
