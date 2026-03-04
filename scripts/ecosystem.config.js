module.exports = {
  apps: [{
    name:    'gogomarket-api',
    cwd:     '/opt/gogomarket-Cloude/backend',
    script:  'dist/index.js',
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch:   false,
    max_memory_restart: '512M',
    env: { NODE_ENV: 'production' },
    error_file: '/var/log/gogomarket/error.log',
    out_file:   '/var/log/gogomarket/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    merge_logs: true,
  }]
}
