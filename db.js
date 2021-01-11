const mysql = require('mysql');

const pool = mysql.createPool({
    connectionLimit: 10,
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'jrozliczajaca',
    port: '3306'
});

module.exports= pool;
