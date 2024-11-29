const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const con = require('./db'); // Database connection module
const app = express();

const JWT_KEY = 'P0rjeCtM0b1le';

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Endpoint to hash a raw password for testing purposes
app.get('/password/:raw', async (req, res) => {
    const raw = req.params.raw;
    try {
        const hash = await bcrypt.hash(raw, 10);
        res.json({ hash });
    } catch (err) {
        console.error('Error hashing password:', err);
        res.status(500).json({ message: 'Error Hashing Password' });
    }
});

// ================= Middleware ================
function verifyUser(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (token == undefined || token == null) {
        // no token
        return res.status(400).send('No token');
    }


    // token found
    if (req.headers.authorization) {
        const tokenString = token.split(' ');
        if (tokenString[0] == 'Bearer') {
            token = tokenString[1];
        }
    }
    jwt.verify(token, JWT_KEY, (err, decoded) => {
        if (err) {
            res.status(401).send('Incorrect token');
        }
        else if (decoded.role != 'borrower') {
            res.status(403).send('Forbidden to access the data');
        }
        else {
            req.decoded = decoded;
            next();
        }
    });
}

function verifyLender(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (token == undefined || token == null) {
        // no token
        return res.status(400).send('No token');
    }


    // token found
    if (req.headers.authorization) {
        const tokenString = token.split(' ');
        if (tokenString[0] == 'Bearer') {
            token = tokenString[1];
        }
    }
    jwt.verify(token, JWT_KEY, (err, decoded) => {
        if (err) {
            res.status(401).send('Incorrect token');
        }
        else if (decoded.role != 'lender') {
            res.status(403).send('Forbidden to access the data');
        }
        else {
            req.decoded = decoded;
            next();
        }
    });
}

// Login endpoint
app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    console.log('Received login data:', req.body);

    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password are required' });
    }

    const sql = "SELECT * FROM users WHERE username = ?";
    con.query(sql, [username], async (err, results) => {
        if (err) {
            console.error('Database query error:', err);
            return res.status(500).json({ message: 'Server error while querying database' });
        }

        console.log('Query results:', results);

        if (results.length === 0) {
            console.warn('No user found with this username');
            return res.status(401).json({ message: 'Incorrect username or password' });
        }

        const user = results[0];
        const storedHash = user.password;

        try {
            const isMatch = await bcrypt.compare(password, storedHash);
            if (!isMatch) {
                console.warn('Password does not match for username:', username);
                return res.status(401).json({ message: 'Incorrect username or password' });
            }

            // Successful login
            const user_id = user.id;
            const role = user.role || 'unknown';
            const payload = { "username": username, "role": `${role}` };
            const token = jwt.sign(payload, JWT_KEY, { expiresIn: '1d' });

            console.log('User ID:', user_id);
            console.log('Role:', role);
            console.log('Token:', token);

            return res.send(token);
        } catch (err) {
            console.error('Error comparing password hash:', err);
            return res.status(500).json({ message: 'Error comparing password hash' });
        }
    });
});

//-------------------------- JWT decode -----------------------
app.get('/username', (req, res) => {
    // Get token from headers
    let token = req.headers['authorization'] || req.headers['x-access-token'];

    if (!token) {
        // No token found
        return res.status(401).json({ message: 'No token provided' });
    }

    // Extract token if prefixed with "Bearer"
    if (req.headers.authorization) {
        const tokenParts = token.split(' ');
        if (tokenParts[0] === 'Bearer' && tokenParts[1]) {
            token = tokenParts[1];
        }
    }

    // Verify token
    jwt.verify(token, JWT_KEY, (err, decoded) => {
        if (err) {
            console.error('Token verification error:', err);
            return res.status(401).json({ message: 'Invalid token' });
        }

        // Send the decoded payload (or specific fields, e.g., username)
        res.json({ decoded });
    });
});

app.post('/register', async (req, res) => {
    const { name, username, password, phoneNumber } = req.body;

    if (!name || !username || !password) {
        return res.status(400).json({ message: 'Name, username and password are required' });
    }

    try {
        // Check if the username already exists
        const checkUserSql = "SELECT * FROM users WHERE username = ?";
        con.query(checkUserSql, [username], async (err, results) => {
            if (err) {
                console.error('Database query error:', err);
                return res.status(500).json({ message: 'Server error while checking username' });
            }

            if (results.length > 0) {
                console.warn('Username already taken:', username);
                return res.status(409).json({ message: 'Username already taken' });
            }

            // Hash the password
            const hashedPassword = await bcrypt.hash(password, 10);

            // Insert the new user into the database
            const insertUserSql = "INSERT INTO users (name, username, password, Phone_Number, role) VALUES (?, ?, ?, ?, 'borrower')";
            con.query(insertUserSql, [name, username, hashedPassword, phoneNumber], (err, result) => {
                if (err) {
                    console.error('Error inserting user into database:', err);
                    return res.status(500).json({ message: 'Server error while registering user' });
                }

                console.log('User registered with ID:', result.insertId);
                res.status(201).json({ message: 'User registered successfully', user_id: result.insertId });
            });
        });
    } catch (err) {
        console.error('Error hashing password:', err);
        res.status(500).json({ message: 'Error hashing password' });
    }
});

app.get('/books', (req, res) => {
    const sql = "SELECT * FROM book";

    con.query(sql, (err, results) => {
        if (err) {
            console.error('Database query error:', err);
            return res.status(500).json({ message: 'Server error while fetching books' });
        }

        res.status(200).json(results);
    });
});

app.get('/borrower/history', (req, res) => {
    const { username } = req.query;  // Use req.query to access username from query parameters
    console.log('Received Username: ', username);

    if (!username) {
        return res.status(400).json({ message: 'Username is required' });
    }

    // Query to retrieve user_id from the username
    const getUserIdQuery = 'SELECT id FROM users WHERE username = ?';

    con.query(getUserIdQuery, [username], (err, userResult) => {
        if (err) {
            console.error('Error executing query to get user ID:', err);
            return res.status(500).json({ message: 'Database error' });
        }

        if (userResult.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user_id = userResult[0].id;  // Fixing this line to match the 'id' column in your 'users' table

        console.log('Received user_id: ', user_id);

        // Now that we have the user_id, we can retrieve the borrowing history
        const query = `SELECT
        h.history_id,
            h.book_id,
            h.borrow_date,
            h.return_date,
            h.approver_id,
            u.name AS approver_name,
                h.staff_id,
                CASE
        WHEN h.approver_id IS NULL AND h.staff_id IS NULL THEN 'pending'
        WHEN h.approver_id IS NOT NULL AND h.staff_id IS NULL THEN 'borrowed'
        WHEN h.approver_id IS NOT NULL AND h.staff_id IS NOT NULL THEN 'available'
        ELSE 'available'
    END AS book_status,
            b.book_name,
            b.book_details
FROM history h
JOIN book b ON h.book_id = b.book_id
LEFT JOIN users u ON h.approver_id = u.id  
WHERE h.borrower_id = ?
            AND h.approver_id IS NOT NULL;`


        con.query(query, [user_id], (err, results) => {
            if (err) {
                console.error('Error executing query:', err);
                return res.status(500).json({ message: 'Database error' });
            }

            if (results.length === 0) {
                return res.status(404).json({ message: 'No borrowing history found' });
            }

            return res.status(200).json({ history: results });
        });
    });
});

app.post('/lender/history', (req, res) => {
    const { user_id, role } = req.body;
    console.log('Received ID: ', user_id);
    console.log('Received Role: ', role);

    if (!user_id || role !== 'lender') {
        return res.status(400).json({ message: 'Invalid id or role' });
    }

    // Query to retrieve books requested by borrowers
    const query = `
        SELECT h.history_id, h.book_id, h.borrow_date, h.return_date, h.approver_id, h.staff_id,
               CASE 
                   WHEN h.approver_id IS NULL AND h.staff_id IS NULL THEN 'pending'
                   WHEN h.approver_id IS NOT NULL AND h.staff_id IS NULL THEN 'borrowed'
                   WHEN h.approver_id IS NOT NULL AND h.staff_id IS NOT NULL THEN 'available'
                   ELSE 'available'
               END AS book_status,
               b.book_name, b.book_details
        FROM history h
        JOIN book b ON h.book_id = b.book_id
        WHERE h.approver_id = ?
    `;

    con.query(query, [user_id], (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ message: 'Database error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'No pending requests found' });
        }

        return res.status(200).json({ history: results });
    });
});

app.get('/Allhistory', (req, res) => {

    // Query to retrieve books requested by borrowers
    const query = `SELECT 
    h.history_id, 
    h.book_id, 
    DATE(h.borrow_date) AS borrow_date, 
    DATE(h.return_date) AS return_date, 
    DATE(h.approve_date) AS approve_date, 
    h.approver_id, 
    h.staff_id,
    CASE 
        WHEN h.borrow_date IS NOT NULL AND h.approver_id IS NULL AND h.approve_date IS NULL THEN 'pending'
        WHEN h.approve_date IS NOT NULL AND h.approver_id IS NULL THEN NULL -- ไม่ดึงข้อมูล
        WHEN h.approver_id IS NOT NULL AND h.approve_date IS NOT NULL 
             AND (h.staff_id IS NULL OR h.return_date IS NULL) THEN 'borrowed'
        WHEN h.approver_id IS NOT NULL AND h.approve_date IS NOT NULL 
             AND h.staff_id IS NOT NULL AND h.return_date IS NOT NULL THEN 'available'
        ELSE 'unknown'
    END AS book_status,
    b.book_name, 
    b.book_details, 
    u.name AS approverName
FROM 
    history h
JOIN 
    book b ON h.book_id = b.book_id
LEFT JOIN 
    users u ON h.approver_id = u.id
WHERE 
    NOT (h.approve_date IS NOT NULL AND h.approver_id IS NULL);

`;

    con.query(query, (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ message: 'Database error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'No pending requests found' });
        }

        return res.status(200).json({ history: results });
    });
});

app.post('/staff/history', (req, res) => {
    const { role } = req.body;

    console.log('Received role:', role);

    if (role !== 'staff') {
        return res.status(400).json({ message: 'Invalid role' });
    }

    const sql = `
        SELECT 
            book.book_name,
            book_image,
            history.borrow_date,
            history.return_date,
            history.approve_date,
            borrower.username AS borrower_name,
            approver.username AS approver_name,
            reclaimer.username AS asset_reclaimer_name,
            CASE
                WHEN history.approve_date IS NULL THEN 'pending'
                WHEN history.return_date IS NULL THEN 'Approved'
                ELSE 'Returned'
            END AS book_status
        FROM history
        JOIN book ON history.book_id = book.book_id
        LEFT JOIN users AS borrower ON history.borrower_id = borrower.id
        LEFT JOIN users AS approver ON history.approver_id = approver.id
        LEFT JOIN users AS reclaimer ON history.staff_id = reclaimer.id;
    `;

    con.query(sql, (err, results) => {
        if (err) {
            console.error("Database error:", err);
            return res.status(500).json({ message: 'Database error while fetching history' });
        }
        if (results.length === 0) {
            return res.status(404).json({ message: 'No history found' });
        }
        res.json(results);
    });
});

app.get('/dashboard', (req, res) => {
    const sql = `
      SELECT 
        COUNT(CASE WHEN status = 'available' THEN 1 END) AS available,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending,
        COUNT(CASE WHEN status = 'borrowed' THEN 1 END) AS borrowed,
        COUNT(CASE WHEN status = 'disabled' THEN 1 END) AS disabled
      FROM book;
    `;

    // Execute the query
    con.query(sql, (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ message: 'Database error' });
        }

        // Extract the data from the results and send it as a response
        const { available, pending, borrowed, disabled } = results[0];
        return res.status(200).json({
            dashboard: {
                available,
                pending,
                borrowed,
                disabled
            }
        });
    });
});

app.get('/borrower/status', (req, res) => {
    const { user_id } = req.body;
    console.log('Received ID:', user_id);

    if (!user_id) {
        return res.status(400).json({ message: 'ID is required' });
    }

    const sql = `
        SELECT book.book_name, book.status, history.borrow_date
        FROM book
        JOIN history ON book.book_id = history.book_id
        WHERE history.borrower_id = ?
    `;

    con.query(sql, [user_id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ message: 'Database server error' });
        }
        // If no records found
        if (results.length === 0) {
            return res.status(404).json({ message: 'No books found for this user' });
        }
        // Return the results as a JSON response
        return res.status(200).json(results);
    });
});

app.get('/status', (req, res) => {
    // Retrieve name from query parameter
    const borrower_name = req.query.name; // Adjusted to use 'name' as per the URL parameter

    // Check if borrower_name is provided
    if (!borrower_name) {
        return res.status(400).json({ message: 'Borrower name is required' });
    }

    // Query user_id based on username
    const getUserIdSql = `SELECT id FROM users WHERE username = ?`;

    con.query(getUserIdSql, [borrower_name], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ message: 'Internal Server Error' });
        }

        // Check if a user was found
        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Extract user_id
        const borrower_id = results[0].id;

        // Query the status of books associated with the borrower_id
        const checkStatusSql = `
            SELECT h.borrow_date, h.book_id, h.approver_id, h.approve_date, b.book_name, b.book_image
            FROM history h
            LEFT JOIN book b ON h.book_id = b.book_id
            WHERE h.staff_id IS NULL AND h.return_date IS NULL AND h.borrower_id = ?
        `;

        con.query(checkStatusSql, [borrower_id], (err, statusResults) => {
            if (err) {
                console.error('Database error:', err);
                return res.status(500).json({ message: 'Internal Server Error' });
            }

            // Check if there are any status records
            if (statusResults.length > 0) {
                // Modify the part where you're setting the borrow_date
                statusResults.forEach(result => {
                    // Set the status of the book based on conditions
                    if (result.approver_id && result.approve_date) {
                        result.status = 'Approved';
                    } else if (result.approver_id == null && result.approve_date) {
                        result.status = 'Disapproved';
                    } else {
                        result.status = 'Pending';
                    }

                    // Calculate the return date (borrow_date + 7 days)
                    if (result.borrow_date) {
                        const borrowDate = new Date(result.borrow_date); // Convert borrow_date to Date object
                        const returnDate = new Date(borrowDate.setDate(borrowDate.getDate() + 7)); // Add 7 days
                        result.return_date = returnDate.toISOString().split('T')[0]; // Convert to ISO string and remove time
                    }

                    // Format borrow_date to "YYYY-MM-DD" (without time)
                    if (result.borrow_date) {
                        const formattedBorrowDate = new Date(result.borrow_date).toISOString().split('T')[0]; // Extract only date part
                        result.borrow_date = formattedBorrowDate;
                    }
                });


                // Return the results with return_date
                return res.status(200).json({ message: 'Status retrieved successfully', results: statusResults });
            } else {
                return res.status(200).json({ message: 'No records found' });
            }
        });
    });
});

app.get('/status/return', (req, res) => {
    // Retrieve name from query parameter
    const borrower_name = req.query.name; // Adjusted to use 'name' as per the URL parameter

    // Check if borrower_name is provided
    if (!borrower_name) {
        return res.status(400).json({ message: 'Borrower name is required' });
    }

    // Query user_id based on username
    const getUserIdSql = `SELECT id FROM users WHERE username = ?`;

    con.query(getUserIdSql, [borrower_name], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ message: 'Internal Server Error' });
        }

        // Check if a user was found
        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Extract user_id
        const borrower_id = results[0].id;

        // Query the status of books associated with the borrower_id
        const checkStatusSql = `
    SELECT h.borrow_date, h.book_id, h.approver_id, h.approve_date, b.book_name, b.book_image
    FROM history h
    LEFT JOIN book b ON h.book_id = b.book_id
    WHERE h.staff_id IS NULL 
      AND h.return_date IS NULL 
      AND h.approve_date IS NOT NULL 
      AND h.approver_id IS NOT NULL 
      AND h.borrower_id = ?
`;


        con.query(checkStatusSql, [borrower_id], (err, statusResults) => {
            if (err) {
                console.error('Database error:', err);
                return res.status(500).json({ message: 'Internal Server Error' });
            }

            // Check if there are any status records
            if (statusResults.length > 0) {
                // Modify the part where you're setting the borrow_date
                statusResults.forEach(result => {
                    // Set the status of the book based on conditions
                    if (result.approver_id && result.approve_date) {
                        result.status = 'Approved';
                    } else if (result.approver_id == null && result.approve_date) {
                        result.status = 'Disapproved';
                    } else {
                        result.status = 'Pending';
                    }

                    // Calculate the return date (borrow_date + 7 days)
                    if (result.borrow_date) {
                        const borrowDate = new Date(result.borrow_date); // Convert borrow_date to Date object
                        const returnDate = new Date(borrowDate.setDate(borrowDate.getDate() + 7)); // Add 7 days
                        result.return_date = returnDate.toISOString().split('T')[0]; // Convert to ISO string and remove time
                    }

                    // Format borrow_date to "YYYY-MM-DD" (without time)
                    if (result.borrow_date) {
                        const formattedBorrowDate = new Date(result.borrow_date).toISOString().split('T')[0]; // Extract only date part
                        result.borrow_date = formattedBorrowDate;
                    }
                });


                // Return the results with return_date
                return res.status(200).json({ message: 'Status retrieved successfully', results: statusResults });
            } else {
                return res.status(200).json({ message: 'No records found' });
            }
        });
    });
});

app.get('/request/Lender', (req, res) => {
    const checkHistorySql = `
    SELECT
      h.history_id,
      b.book_name AS namebook,
      u.name AS borrower_name,
      h.borrow_date
    FROM
      history h
    JOIN
      book b ON h.book_id = b.book_id
    JOIN
      users u ON h.borrower_id = u.id
    WHERE
      h.staff_id IS NULL
      AND h.approver_id IS NULL
      AND h.approve_date IS NULL
      AND h.return_date IS NULL;
  `;

    con.query(checkHistorySql, (err, result) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ message: 'Database error' });
        }

        res.status(200).json(result); // Return the correct result
    });
});

app.post('/request', (req, res) => {
    const { username, book_id } = req.body; // เปลี่ยนจาก user_id เป็น username
    console.log('Received Username:', username);
    console.log('Received Book ID:', book_id);

    if (!username || !book_id) {
        return res.status(400).json({ message: 'Username and Book ID are required' });
    }

    // Step 1: ค้นหา user_id จาก username
    const getUserIdSql = `SELECT id FROM users WHERE username = ?`;

    con.query(getUserIdSql, [username], (err, results) => {
        if (err) {
            console.error('Error fetching user ID:', err);
            return res.status(500).json({ message: 'Database error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user_id = results[0].id; // ได้ user_id จากผลลัพธ์

        // Step 2: ตรวจสอบสถานะของหนังสือ
        const checkStatusSql = `
            SELECT status
            FROM book
            WHERE book_id = ?
        `;

        con.query(checkStatusSql, [book_id], (err, results) => {
            if (err) {
                console.error('Error checking book status:', err);
                return res.status(500).json({ message: 'Database error' });
            }

            if (results.length === 0) {
                return res.status(404).json({ message: 'Book not found' });
            }

            const bookStatus = results[0].status;

            if (bookStatus === 'pending' || bookStatus === 'disabled') {
                // ถ้าหนังสืออยู่ในสถานะ pending หรือ disabled
                return res.status(400).json({ message: 'This book is currently unavailable for request.' });
            }

            // Step 3: บันทึกการยืมหนังสือลงใน history
            const insertHistorySql = `
                INSERT INTO history (book_id, borrower_id, borrow_date)
                VALUES (?, ?, NOW())
            `;

            con.query(insertHistorySql, [book_id, user_id], (insertErr, insertResults) => {
                if (insertErr) {
                    console.error('Error inserting borrow request into history:', insertErr);
                    return res.status(500).json({ message: 'Database error' });
                }

                // Step 4: อัพเดตสถานะของหนังสือเป็น 'pending'
                const updateBookStatusSql = `
                    UPDATE book
                    SET status = 'pending'
                    WHERE book_id = ?
                `;

                con.query(updateBookStatusSql, [book_id], (updateErr, updateResults) => {
                    if (updateErr) {
                        console.error('Error updating book status:', updateErr);
                        return res.status(500).json({ message: 'Database error' });
                    }

                    return res.status(200).json({ message: 'Book request successful. The book is now pending.' });
                });
            });
        });
    });
});

app.post('/return/borrower', verifyUser, (req, res) => {
    const borrower_name = req.body.name; // Use req.body for POST request data

    if (!borrower_name) {
        return res.status(400).json({ message: 'Borrower name is required' });
    }

    // Query user_id based on username
    const getUserIdSql = `SELECT id FROM users WHERE username = ?`;

    con.query(getUserIdSql, [borrower_name], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ message: 'Internal Server Error' });
        }

        // Check if a user was found
        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Extract user_id
        const borrower_id = results[0].id;

        // SQL query to update the return_date for records with borrower_id and return_date IS NULL
        const updateHistorySql = `
            UPDATE history
            SET return_date = NOW()
            WHERE borrower_id = ? AND return_date IS NULL AND approver_id IS NOT NULL AND approve_date IS NOT NULL
        `;

        con.query(updateHistorySql, [borrower_id], (err, result) => {
            if (err) {
                console.error('Database error:', err);
                return res.status(500).json({ message: 'Error updating return date' });
            }

            if (result.affectedRows === 0) {
                // If no rows were affected, it may mean no pending records to update
                return res.status(404).json({ message: 'No records found for update' });
            }

            // Successful update response
            return res.status(200).json({ message: 'Return date set to now successfully' });
        });
    });
});

app.get('/request/staff', (req, res) => {

    const checkHistorySql = `
        SELECT history_id, book_id, borrower_id, borrow_date
        FROM history
        WHERE staff_id IS NULL AND approver_id IS NULL AND approve_date IS NULL AND return_date IS NOT NULL
    `;

    con.query(checkHistorySql, (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ message: 'Error' });
        }

        console.log('SQL Query Results:', results); // Log the results to the console for debugging

        if (results.length > 0) {
            // If there's an entry with missing staff_id, approver_id, or approve_date, respond with "Acception Done"
            return res.status(200).json({ message: 'Acception Done :', results });
        } else {
            // If no matching entry found, respond with "No accept"
            return res.status(200).json({ message: 'No accept' });
        }
    });
});

app.post('/add-book', (req, res) => {
    const { book_name, book_details, book_image } = req.body;

    if (!book_name || !book_details || !book_image) {
        return res.status(400).json({ message: 'Book name, details, and image are required' });
    }

    // SQL query to insert a new book with status set to 'available' by default
    const sql = `
        INSERT INTO book (book_name, book_details, book_image, status)
        VALUES (?, ?, ?, 'available')
    `;

    con.query(sql, [book_name, book_details, book_image], (err, results) => {
        if (err) {
            console.error('Error adding new book:', err);
            return res.status(500).json({ message: 'Database error' });
        }

        return res.status(201).json({ message: 'Book added successfully', bookId: results.insertId });
    });
});

app.post('/edit', (req, res) => {
    const { id, book_name, category, status, book_details, book_image } = req.body;

    // Check if required fields are provided
    if (!id) {
        return res.status(400).json({ message: 'ID is required' });
    }

    // Prepare the SQL query to update the book table
    const updateHistorySql = `
        UPDATE book
        SET 
            book_name = COALESCE(?, book_name),
            category = COALESCE(?, category),
            status = COALESCE(?, status),
            book_details = COALESCE(?, book_details),
            book_image = COALESCE(?, book_image)
        WHERE book_id = ?
    `;

    // Use an array to hold the values for the query
    const values = [book_name, category, status, book_details, book_image, id];

    con.query(updateHistorySql, values, (err, result) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ message: 'Error updating book record' });
        }

        if (result.affectedRows === 0) {
            // If no rows were affected, the id may not exist
            return res.status(404).json({ message: 'ID not found' });
        }

        // Successful update response
        return res.status(200).json({ message: 'Book record updated successfully' });
    });
});

app.post('/approve/lender/:history_id', (req, res) => {
    const historyId = req.params.history_id;
    const approverId = req.body.approver_id;
    const approveDate = new Date().toISOString().slice(0, 10);

    // Update history table to set approver_id and approve_date
    const updateHistoryQuery = `
        UPDATE history h
JOIN users u ON u.username = ?
SET h.approver_id = u.id, h.approve_date = ?
WHERE h.history_id = ?;

    `;

    // First, update the history table
    con.query(updateHistoryQuery, [approverId, approveDate, historyId], (err, result) => {
        if (err) {
            console.error('Error updating history:', err);
            return res.status(500).send('An error occurred while updating the history record.');
        }

        if (result.affectedRows === 0) {
            return res.status(404).send('History record not found.');
        }

        // Get the book_id from the history record
        const getBookQuery = `SELECT book_id FROM history WHERE history_id = ?`;
        con.query(getBookQuery, [historyId], (err, bookResult) => {
            if (err) {
                console.error('Error fetching book ID:', err);
                return res.status(500).send('An error occurred while fetching the book ID.');
            }

            if (bookResult.length === 0) {
                return res.status(404).send('Book associated with history record not found.');
            }

            const bookId = bookResult[0].book_id;

            // Update the book status to 'borrowed'
            const updateBookQuery = `
                UPDATE book
                SET status = 'borrowed'
                WHERE book_id = ?;
            `;

            con.query(updateBookQuery, [bookId], (err, bookUpdateResult) => {
                if (err) {
                    console.error('Error updating book status:', err);
                    return res.status(500).send('An error occurred while updating the book status.');
                }

                if (bookUpdateResult.affectedRows === 0) {
                    return res.status(404).send('Book record not found.');
                }

                res.status(200).send('History record approved and book status updated successfully.');
            });
        });
    });
});

app.post('/disapprove/lender/:history_id', (req, res) => {
    const historyId = req.params.history_id;
    const approverId = req.body.approver_id;
    const approveDate = new Date().toISOString().slice(0, 10); // Gets the current date in today's format

    // Update history table to set approver_id and approve_date
    const updateHistoryQuery = `
        UPDATE history
        SET approver_id = ?, approve_date = ?
        WHERE history_id = ?;
    `;

    // First, update the history table
    con.query(updateHistoryQuery, [approverId, approveDate, historyId], (err, result) => {
        if (err) {
            console.error('Error updating history:', err);
            return res.status(500).send('An error occurred while updating the history record.');
        }

        if (result.affectedRows === 0) {
            return res.status(404).send('History record not found.');
        }

        // Get the book_id from the history record
        const getBookQuery = `SELECT book_id FROM history WHERE history_id = ?`;
        con.query(getBookQuery, [historyId], (err, bookResult) => {
            if (err) {
                console.error('Error fetching book ID:', err);
                return res.status(500).send('An error occurred while fetching the book ID.');
            }

            if (bookResult.length === 0) {
                return res.status(404).send('Book associated with history record not found.');
            }

            const bookId = bookResult[0].book_id;

            // Update the book status to 'available'
            const updateBookQuery = `
                UPDATE book
                SET status = 'available'
                WHERE book_id = ?;
            `;

            con.query(updateBookQuery, [bookId], (err, bookUpdateResult) => {
                if (err) {
                    console.error('Error updating book status:', err);
                    return res.status(500).send('An error occurred while updating the book status.');
                }

                if (bookUpdateResult.affectedRows === 0) {
                    return res.status(404).send('Book record not found.');
                }

                res.status(200).send('History record disapproved and book status updated successfully.');
            });
        });
    });
});

app.post('/logout', (req, res) => {
    req.session.destroy(err => {
        if (err) {
            console.error('Error logging out:', err);
            return res.status(500).json({ message: 'Error logging out' });
        }
        res.status(200).json({ message: 'Logout successful' });
    });
});

// Start the server
const PORT = 5001;
app.listen(PORT, () => {
    console.log(`Server is running at port ${PORT}`);
});