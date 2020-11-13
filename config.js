import fs from 'fs'
import dotenv from 'dotenv'

const IGNORE_KEYS = /npm_*|KUBERNETES_*|HOSTNAME|NODE_VERSION|YARN_VERSION|SHLVL|HOME|TERM|PATH|PWD/
const SECRETS_PATH = '/usr/src/app/secrets/.env'

const logEnvTable = obj => {
    let table = []
    Object.keys(obj).forEach(key => {
        let value = obj[key] ? obj[key] : ''
        if (key.match(/KEY|TOKEN|SECRET|CERT/)) {
            value = value.length > 0 ? '*'.repeat(12) : ''
        }
        table.push({ KEY: key, VALUE: value })
    })
    console.table(table)
}

if (process.env.DOPPLER_PROJECT) {
    console.log(`\n[info]: Doppler detected for configuration: ${process.env.DOPPLER_PROJECT} > ${process.env.DOPPLER_CONFIG}`)
}

if (fs.existsSync(SECRETS_PATH) || !process.env.DOPPLER_PROJECT) {
    console.log(`[info]: Populating env vars using .env file: ${SECRETS_PATH}`)
    dotenv.config({ path: SECRETS_PATH })
}

const envConfig = {}
Object.keys(process.env).forEach(key => {
    if (key.match(IGNORE_KEYS)) {
        return
    }
    envConfig[key] = process.env[key]
})


console.log('[info]: Config and Secrets\n')
logEnvTable(envConfig)
