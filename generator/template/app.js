module.exports = {
  app: 'me.botim.base',
  url: 'http://192.168.120.64:8080/?source=gamecenter&channel=2',
  type: 'hybrid',
  oauthClientId: 'test',
  minSdk: 0,
  frameworkVersion: '5.0.3',
  browserDefaultHeader: 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI1WUo3WjBWRCIsInJlZ2lvbiI6IkNOIiwiZXhwIjoxNjA1OTQ3MDQyLCJpYXQiOjE2MDMzNTUwNDJ9.9GM9FMZJHKp8DYtribf5LytcfXb-Fe1Os0YUM0uIj5w0d6kFC_qSng3zo38YqF4S09vj71S9oafCAoMg2trOyw',
  permissions: [],
  pages: {
    index: { entry: true }
  },
  theme: {
    container: 1, // 0: miniprogram, 1: native navi
    titleBgColor: '000000',
    titleTextColor: 'FFFFFF',
    hideStatusBar: 0
  }
}
