// src/i18nPlugin.js
import { ref, provide, inject } from 'vue'
var componentName = ''
const createI18n = config => ({
  locale: ref(config.locale),
  messages: config.messages,
  $t(key) {
    return this.messages[this.locale.value][componentName][key]
  }
})

const i18nSymbol = Symbol()

export function provideI18n(i18nConfig) {
  const i18n = createI18n(i18nConfig)
  provide(i18nSymbol, i18n)
}

export function useI18n(name) {
  const i18n = inject(i18nSymbol)
  componentName = name
  if (!i18n) throw new Error('No i18n provided!!!')

  return i18n
}
