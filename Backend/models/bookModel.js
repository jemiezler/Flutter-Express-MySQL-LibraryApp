const db = require('../config/db');

exports.findAll = () => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM book';
        db.query(query, (err, results) => {
            if (err) return reject(err);
            resolve(results);
        });
    });
};

exports.create = ({ book_name, book_details, book_image, category  }) => {
    return new Promise((resolve, reject) => {
        const query = 'INSERT INTO book (book_name, book_details, book_image, category, status ) VALUES (?, ?, ?, ?, "available")';
        db.query(query, [book_name, book_details, book_image, category ], (err, results) => {
            if (err) return reject(err);
            resolve({ id: results.insertId, book_name, book_details, book_image });
        });
    });
};

exports.edit = ({ id, book_name, book_details, book_image, category }) => {
    return new Promise((resolve, reject) => {
        const updates = [];
        const values = [];

        // Dynamically build the query based on provided fields
        if (book_name) {
            updates.push('book_name = ?');
            values.push(book_name);
        }
        if (book_details) {
            updates.push('book_details = ?');
            values.push(book_details);
        }
        if (book_image) {
            updates.push('book_image = ?');
            values.push(book_image);
        }
        if (category) {
            updates.push('category = ?');
            values.push(category);
        }

        if (updates.length === 0) {
            return reject(new Error('No fields to update'));
        }

        const query = `UPDATE book SET ${updates.join(', ')} WHERE book_id = ?`;
        values.push(id);

        db.query(query, values, (err, results) => {
            if (err) return reject(err);
            if (results.affectedRows === 0) return reject(new Error('Book not found'));
            resolve({ id, book_name, book_details, book_image, category });
        });
    });
};

exports.editStatus = ({ id, status }) => {
    return new Promise((resolve, reject) => {
        const query = 'UPDATE book SET status = ? WHERE book_id = ?';
        db.query(query, [status, id], (err, results) => {
            if (err) return reject(err);
            if (results.affectedRows === 0) return reject(new Error('Book not found'));
            resolve({ id, status });
        });
    });
};

exports.delete = (id) => {
    return new Promise((resolve, reject) => {
        const query = 'DELETE FROM book WHERE book_id = ?';
        db.query(query, [id], (err, results) => {
            if (err) return reject(err);
            if (results.affectedRows === 0) return reject(new Error('Book not found'));
            resolve({ id });
        });
    });
};

exports.getBookStatusCounts = () => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                COUNT(CASE WHEN status = 'available' THEN 1 END) AS available,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending,
                COUNT(CASE WHEN status = 'borrowed' THEN 1 END) AS borrowed,
                COUNT(CASE WHEN status = 'disabled' THEN 1 END) AS disabled
            FROM book;
        `;
        db.query(query, (err, results) => {
            if (err) return reject(err);
            resolve(results[0]); // Return the first row (summary counts)
        });
    });
};