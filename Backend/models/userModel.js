const db = require('../config/db');

exports.findByUsername = (username) => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM users WHERE username = ?';
        db.query(query, [username], (err, results) => {
            if (err) return reject(err);
            resolve(results[0]);
        });
    });
};

exports.create = ({ username, password, name, phoneNumber }) => {
    return new Promise((resolve, reject) => {
        const query = 'INSERT INTO users (username, password, name, phone_number) VALUES (?, ?, ?, ?)';
        db.query(query, [username, password, name, phoneNumber], (err, results) => {
            if (err) return reject(err);
            resolve({ id: results.insertId, username, name, phoneNumber });
        });
    });
};