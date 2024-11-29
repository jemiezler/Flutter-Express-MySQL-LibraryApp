const mysql = require("mysql2");
const con = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'project'
});

// Test the database connection
con.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
    } else {
        console.log('Database connected successfully');
    }
});

module.exports = con;
