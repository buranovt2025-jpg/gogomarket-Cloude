module.exports = {
  apps: [{
    name: 'gogomarket-api',
    cwd: '/opt/gogomarket-Cloude/backend',
    script: 'dist/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '400M',
    env: { NODE_ENV: 'production' },
    error_file: '/var/log/gogomarket/error.log',
    out_file: '/var/log/gogomarket/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
  }]
}
