module.exports = [
    {
        type: 'list',
        name: 'loginMode',
        message: 'Please choice one login mode',
        choices: [
          { name: 'noLogin', value: 'noLogin' },
          { name: 'appLogin', value: 'appLogin' },
          { name: 'tokenLogin', value: 'tokenMode' }
        ],
        default: 'tokenLogin'
      }
]