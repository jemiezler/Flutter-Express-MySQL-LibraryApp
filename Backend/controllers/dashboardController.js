const Book = require('../models/bookModel'); // Import the model

exports.getDashboardStats = async (req, res) => {
    try {
        const statusCounts = await Book.getBookStatusCounts(); // Fetch the dashboard data
        res.status(200).json({
            dashboard: {
                available: statusCounts.available,
                pending: statusCounts.pending,
                borrowed: statusCounts.borrowed,
                disabled: statusCounts.disabled
            }
        });
    } catch (err) {
        console.error('Error fetching dashboard data:', err);
        res.status(500).json({ message: 'Database error' });
    }
};
