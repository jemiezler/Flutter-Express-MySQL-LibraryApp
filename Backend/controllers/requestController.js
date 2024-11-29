const History = require('../models/historyModel');

exports.getStaffRequests = async (req, res) => {
    try {
        const results = await History.getPendingStaffRequests(); // Fetch data from the model

        if (results.length > 0) {
            return res.status(200).json({ message: 'Acception Done:', results });
        } else {
            return res.status(200).json({ message: 'No accept' });
        }
    } catch (err) {
        console.error('Error fetching staff requests:', err);
        res.status(500).json({ message: 'Database error' });
    }
};

exports.requestBook = async (req, res) => {
    const { username, book_id } = req.body;

    if (!username || !book_id) {
        return res.status(400).json({ message: 'Username and Book ID are required' });
    }

    try {
        // Step 1: Find the user by username
        const user = await User.findByUsername(username);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user_id = user.id;

        // Step 2: Check the book's status
        const book = await Book.findAll(); // Assuming this gets all books; a specific method for `findById` is preferred.
        const bookStatus = book.find((b) => b.book_id === book_id)?.status;

        if (!bookStatus) {
            return res.status(404).json({ message: 'Book not found' });
        }

        if (bookStatus === 'pending' || bookStatus === 'disabled') {
            return res.status(400).json({ message: 'This book is currently unavailable for request.' });
        }

        // Step 3: Create a new borrow request in the history
        await History.insertBorrowRequest(book_id, user_id);

        // Step 4: Update the book's status to 'pending'
        await Book.editStatus({ id: book_id, status: 'pending' });

        return res.status(200).json({ message: 'Book request successful. The book is now pending.' });
    } catch (err) {
        console.error('Error processing book request:', err);
        res.status(500).json({ message: 'Server error' });
    }
};