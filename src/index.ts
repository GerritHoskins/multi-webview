import type { MsAppMultiWebviewPlugin } from './definitions'
import { registerPlugin } from '@capacitor/core'

const MsAppMultiWebview = registerPlugin<MsAppMultiWebviewPlugin>('MsAppMultiWebview', {
    web: () => import('./web').then((m) => new m.MsAppMultiWebviewWeb()),
})

export * from './definitions'
export { MsAppMultiWebview }
