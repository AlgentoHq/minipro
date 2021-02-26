module.exports =  {
    appLogin : `Global.Run(($rootScope, BOT) => {
        app.config.globalProperties.BOT = BOT
        if (process.env.NODE_ENV === 'production') {
          BOT.doLogin({ success: function(res) {
            console.log('IndexCtrl - doLogin', res)
            app.mount('#app')
          }, fail: function(err) {
            console.warn('IndexCtrl - doLogin Failed', err)
          } })
        } else {
          BOT.browserSetDefaultHeader({ Authorization: appInfo.browserDefaultHeader })
          app.mount('#app')
        })`,
    tokenLogin : ` const AppConfig = app.config.globalProperties
        Global.Run(($rootScope, BOT) => {
        setReqConfig({ requestCtx: BOT })
        AppConfig.BOT = BOT
        AppConfig.$api = request()
        AppConfig.appLogin = (fn) => {
          BOT.getAuthcode({ state: '', scope: '', redirectUri: process.env.VUE_APP_REDIRECTURI }, {
            success: (res) => {
              const { code } = res.data
              setReqConfig({ header: { Authorization: '' }})
              localStorage.removeItem('authToken')
              AppConfig.$api({ url: process.env.VUE_APP_LOGIN, data: { code, redirectUri: process.env.VUE_APP_REDIRECTURI }}).then(res => {
                localStorage.setItem('authToken', res)
                setReqConfig({ header: { Authorization: res }})
                Toast('Login success')
                if (Array.isArray(fn)) {
                  fn.forEach(f => {
                    f()
                  })
                } else {
                  fn && fn()
                }
              }).catch(err => {
                Toast('Login fail' + err)
              })
            },
            fail: (res) => {
              Toast('fail' + res)
              console.error(res, 'fail')
            }
          })
        }
        setReqConfig({ defaultLoginFn: AppConfig.appLogin })
        if (process.env.NODE_ENV !== 'production') {
          BOT.browserSetDefaultHeader({ Authorization: appInfo.browserDefaultHeader })
        }
        app.mount('#app')
      })`
}