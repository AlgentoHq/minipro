// import { appLogin, tokenLogin } from './loginMode'
const { appLogin, tokenLogin } = require('./loginMode')
const path  = require('path')
const fs = require('fs')
const { EOL } = require('os')
/**
 * 创建登录方式选择
 * @lines 解析的主文件
 * @type 参数
 */
// function createLoginLogic(lines, type, createIndex) {
//     if (type === 'appLogin') {
//         lines[createIndex] += `${EOL} ${loginModeOne}`
//         console.log('app登录模式')
//     } else if (type === 'tokenLogin') {
//         console.log('授权登录模式')
//     } else {
//         lines[createIndex] += `${EOL} app.mount('#app')`
//         console.log('原生h5模式')
//     }
//     return lines
// }

module.exports = (api, opts) => {
    api.render('./template')
    // api.extendPackage({
    //     "dependencies": {
    //         // "@algento/mp-framework-include": "git+ssh://git@gitlab.corp.algento.com:miniprogram-public/mp-framework-include.git#5.0.8",
    //         "core-js": "^3.6.5",
    //         "mitt": "^2.1.0",
    //         "vant": "^v3.0.1",
    //         "vue": "^3.0.0-0",
    //         "vue-router": "^4.0.0-0"
    //       },
    //     devDependencies: {
    //         "zip-webpack-plugin": "^3.0.0",
    //         'babel-plugin-component': '^1.1.1',
    //         "lib-flexible": "^0.3.2",
    //         "cross-env": "^7.0.2",
    //         "postcss-px2rem": "^0.3.0",
    //         "moment": "^2.29.1",
    //         "cssnano": "^4.1.10",
    //         "es6-promise": "^4.2.8",
    //         "vue-template-compiler": "^2.6.11",
    //         "babel-plugin-transform-remove-console": "^6.9.4",
    //     },
    //     scripts: {
    //         "serve": "cross-env env=dev vue-cli-service serve --open --inline --hot",
    //         "test": "cross-env  package=package platform=bridge vue-cli-service --mode test",
    //         "build": "cross-env env=prod package=package platform=bridge vue-cli-service build --mode pro",
    //         "lint": "vue-cli-service lint",
    //         "postversion": "bash ci/post-version.sh"
    //     }
    // })
    // api.injectImports(api.entryFile, `import router from './router'`)
    // api.injectImports(api.entryFile, `import 'lib-flexible'`)
    // api.injectImports(api.entryFile, `import Global from './global'`)
    // api.injectImports(api.entryFile, `import { Toast } from 'vant'`)
    // api.injectImports(api.entryFile, `import appInfo from '../app'`)
    // opts.loginMode === 'tokenMode' &&  api.injectImports(api.entryFile, `import { request, setReqConfig } from '@/request'`)
   
    // if (opts.import === 'test') {
    //     api.extendPackage({
    //         devDependencies: {
    //           'babel-plugin-component': '^1.1.1'
    //         }
    //     })
    // }
    api.afterInvoke(() => {
        const contentMain = fs.readFileSync(api.resolve(api.entryFile), { encoding: 'utf-8' })
        const lines = contentMain.split(/\r?\n/g)
        const renderIndex = lines.findIndex(line => line.match(/createApp\(App\)(\.use\(\w*\))*\.mount\('#app'\)/))
        // lines.splice(renderIndex , 1, `const app = createApp(App)`)
        // if (opts.loginMode === 'appLogin') {
        //     lines[renderIndex+1] += `${appLogin}`
        // } else if (opts.loginMode === 'tokenMode') {
        //     lines[renderIndex+1] += `${tokenLogin}`
        // } else {
        //     lines[renderIndex+1] += `app.mount('#app')`
        // }
        // lines[renderIndex+1] += `${EOL} app.config.productionTip = false ${EOL} app.use(router)`
        // fs.writeFileSync(api.entryFile, lines.join(EOL), { encoding: 'utf-8' })
    })
    api.onCreateComplete(() => {
        // 拷贝agent包进入node_modules
        // 检测node_modules
        // const contentMain = fs.readFileSync(api.resolve(api.entryFile), { encoding: 'utf-8' })
        // console.log('完成安装', api.entryFile, contentMain)
    })
}