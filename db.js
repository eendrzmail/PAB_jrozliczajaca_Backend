const mysql = require('mysql');

const pool = mysql.createPool({
    connectionLimit: 10,
    host: 'eu-cdbr-west-03.cleardb.net',
    user: 'b144005880e183',
    password: '8e95302a',
    database: 'heroku_e3dfd51e440abcc',
    port: '3306'
});

module.exports= pool;
