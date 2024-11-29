const db = require("../config/db");

exports.findAll = (status = null) => {
  return new Promise((resolve, reject) => {
    let query = `
          SELECT 
              h.history_id, 
              h.book_id, 
              DATE(h.borrow_date) AS borrow_date, 
              DATE(h.return_date) AS return_date, 
              DATE(h.approve_date) AS approve_date, 
              h.borrower_id,
              h.approver_id, 
              h.staff_id,
              CASE 
                  WHEN h.staff_id IS NULL AND h.approver_id IS NULL AND h.approve_date IS NULL AND h.return_date IS NULL 
                      THEN 'pending'
                  WHEN h.staff_id IS NULL AND h.return_date IS NULL 
                      THEN 'borrowed'
                  WHEN h.staff_id IS NULL 
                      THEN 'returned'
                  WHEN h.staff_id IS NOT NULL AND h.approver_id IS NOT NULL AND h.approve_date IS NOT NULL AND h.return_date IS NOT NULL 
                      THEN 'available'
                  ELSE 'unknown'
              END AS book_status,
              b.book_name, 
              b.book_details, 
              b.book_image,
              u.name AS borrowerName,
              q.name AS approverName,
              s.name AS staffName

          FROM 
              history h
          JOIN 
              book b ON h.book_id = b.book_id
          LEFT JOIN 
              users u ON h.borrower_id = u.id
          LEFT JOIN 
              users q ON h.approver_id = q.id
          LEFT JOIN 
              users s ON h.staff_id = s.id
      `;

    // Add a WHERE clause if a specific status is provided
    if (status) {
      query += ` HAVING book_status = ?`;
    }

    // Execute the query
    db.query(query, status ? [status] : [], (err, results) => {
      if (err) {
        console.error("Database error:", err);
        return reject(err);
      }
      resolve(results);
    });
  });
};



exports.updateHistory = ({ approverId, approveDate, historyId }) => {
  return new Promise((resolve, reject) => {
    const query = `
            UPDATE history h
            JOIN users u ON u.username = ?
            SET h.approver_id = u.id, h.approve_date = ?
            WHERE h.history_id = ?;
        `;

    db.query(query, [approverId, approveDate, historyId], (err, results) => {
      if (err) return reject(err);
      if (results.affectedRows === 0)
        return reject(new Error("History record not found"));
      resolve(results);
    });
  });
};

exports.getBookIdByHistory = (historyId) => {
  return new Promise((resolve, reject) => {
    const query = "SELECT book_id FROM history WHERE history_id = ?";
    db.query(query, [historyId], (err, results) => {
      if (err) return reject(err);
      if (results.length === 0)
        return reject(
          new Error("Book associated with history record not found")
        );
      resolve(results[0].book_id);
    });
  });
};

exports.updateBookStatus = ({ bookId, status }) => {
  return new Promise((resolve, reject) => {
    const query = "UPDATE book SET status = ? WHERE book_id = ?";
    db.query(query, [status, bookId], (err, results) => {
      if (err) return reject(err);
      if (results.affectedRows === 0)
        return reject(new Error("Book record not found"));
      resolve(results);
    });
  });
};

exports.getPendingStaffRequests = () => {
  return new Promise((resolve, reject) => {
    const query = `
            SELECT history_id, book_id, borrower_id, borrow_date
            FROM history
            WHERE staff_id IS NULL AND approver_id IS NULL AND approve_date IS NULL AND return_date IS NOT NULL;
        `;
    db.query(query, (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
};

exports.findByStatus = (borrower_id, conditions = {}) => {
  return new Promise((resolve, reject) => {
    let baseQuery = `
            SELECT 
                h.borrow_date, 
                h.book_id, 
                h.approver_id, 
                h.approve_date, 
                b.book_name, 
                b.book_image
            FROM history h
            LEFT JOIN book b ON h.book_id = b.book_id
            WHERE h.borrower_id = ?`;

    const queryParams = [borrower_id];

    // Append additional conditions dynamically
    if (conditions.staff_id === null) {
      baseQuery += " AND h.staff_id IS NULL";
    }
    if (conditions.return_date === null) {
      baseQuery += " AND h.return_date IS NULL";
    }
    if (conditions.approve_date !== undefined) {
      baseQuery += conditions.approve_date
        ? " AND h.approve_date IS NOT NULL"
        : " AND h.approve_date IS NULL";
    }
    if (conditions.approver_id !== undefined) {
      baseQuery += conditions.approver_id
        ? " AND h.approver_id IS NOT NULL"
        : " AND h.approver_id IS NULL";
    }

    db.query(baseQuery, queryParams, (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
};


// exports.findAll = () => {
//     return new Promise((resolve, reject) => {
//         const query = `
//             SELECT
//                 h.history_id,
//                 h.book_id,
//                 DATE(h.borrow_date) AS borrow_date,
//                 DATE(h.return_date) AS return_date,
//                 DATE(h.approve_date) AS approve_date,
//                 h.approver_id,
//                 h.staff_id,
//                 CASE
//                     WHEN h.borrow_date IS NOT NULL AND h.approver_id IS NULL AND h.approve_date IS NULL THEN 'pending'
//                     WHEN h.approve_date IS NOT NULL AND h.approver_id IS NULL THEN NULL
//                     WHEN h.approver_id IS NOT NULL AND h.approve_date IS NOT NULL
//                          AND (h.staff_id IS NULL OR h.return_date IS NULL) THEN 'borrowed'
//                     WHEN h.approver_id IS NOT NULL AND h.approve_date IS NOT NULL
//                          AND h.staff_id IS NOT NULL AND h.return_date IS NOT NULL THEN 'available'
//                     ELSE 'unknown'
//                 END AS book_status,
//                 b.book_name,
//                 b.book_details,
//                 u.name AS approverName
//             FROM
//                 history h
//             JOIN
//                 book b ON h.book_id = b.book_id
//             LEFT JOIN
//                 users u ON h.approver_id = u.id
//             WHERE
//                 NOT (h.approve_date IS NOT NULL AND h.approver_id IS NULL);
//         `;

//         db.query(query, (err, results) => {
//             if (err) return reject(err);
//             resolve(results);
//         });
//     });
// };