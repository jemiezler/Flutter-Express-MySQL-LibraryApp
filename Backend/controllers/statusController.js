const User = require('../models/userModel');
const History = require('../models/historyModel');

// Helper to format results
const formatResults = (results) => {
    return results.map((result) => {
        result.status = result.approver_id && result.approve_date
            ? 'Approved'
            : result.approver_id == null && result.approve_date
            ? 'Disapproved'
            : 'Pending';

        if (result.borrow_date) {
            const borrowDate = new Date(result.borrow_date);
            const returnDate = new Date(borrowDate.setDate(borrowDate.getDate() + 7));
            result.return_date = returnDate.toISOString().split('T')[0];
            result.borrow_date = borrowDate.toISOString().split('T')[0];
        }

        return result;
    });
};

exports.getBorrowerStatus = async (req, res) => {
    const { user_id } = req.body;

    if (!user_id) {
        return res.status(400).json({ message: 'ID is required' });
    }

    try {
        const results = await History.findByStatus(user_id); // General query
        if (results.length === 0) {
            return res.status(404).json({ message: 'No books found for this user' });
        }
        res.status(200).json(results);
    } catch (err) {
        console.error('Error fetching borrower status:', err);
        res.status(500).json({ message: 'Database server error' });
    }
};

exports.getStatus = async (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ message: 'Borrower name is required' });
    }

    try {
        const user = await User.findByUsername(name);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const results = await History.findByStatus(user.id, {
            staff_id: null,
            return_date: null,
        });

        if (results.length === 0) {
            return res.status(200).json({ message: 'No records found' });
        }

        res.status(200).json({ message: 'Status retrieved successfully', results: formatResults(results) });
    } catch (err) {
        console.error('Error fetching status:', err);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};

exports.getReturnStatus = async (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ message: 'Borrower name is required' });
    }

    try {
        const user = await User.findByUsername(name);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const results = await History.findByStatus(user.id, {
            staff_id: null,
            return_date: null,
            approve_date: true,
            approver_id: true,
        });

        if (results.length === 0) {
            return res.status(200).json({ message: 'No records found' });
        }

        res.status(200).json({ message: 'Return status retrieved successfully', results: formatResults(results) });
    } catch (err) {
        console.error('Error fetching return status:', err);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
