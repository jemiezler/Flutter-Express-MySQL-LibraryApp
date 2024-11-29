const History = require('../models/historyModel');

exports.getAllHistory = async (req, res) => {
    try {
        const { status } = req.query;
        const history = await History.findAll(status);

        if (history.length === 0) {
            return res.status(404).json({ message: 'No history records found' });
        }

        const mappedHistory = history.map(record => ({
            ...record,
            book_image: record.book_image ? `${process.env.BASE_URL}/${record.book_image}` : null, // Add full URL for book image
        }));
        
        return res.status(200).json(mappedHistory);
    } catch (err) {
        console.error('Error fetching history records:', err);
        return res.status(500).json({ message: 'Database error' });
    }
};

exports.approveLender = async (req, res) => {
    const historyId = req.params.history_id;
    const approverId = req.body.approver_id;
    const approveDate = new Date().toISOString().slice(0, 10);
    console.log(historyId);
    
    try {
        // Update history
        await History.updateHistory({ approverId, approveDate, historyId });

        // Get book ID associated with the history record
        const bookId = await History.getBookIdByHistory(historyId);

        // Update book status to 'borrowed'
        await History.updateBookStatus({ bookId, status: 'borrowed' });

        res.status(200).json({ message: 'History record approved and book status updated successfully.' });
    } catch (err) {
        console.error('Error approving lender:', err);
        res.status(500).json({ message: err.message || 'Server error' });
    }
};

exports.disapproveLender = async (req, res) => {
    const historyId = req.params.history_id;
    const approverId = req.body.approver_id;
    const approveDate = new Date().toISOString().slice(0, 10);

    try {
        // Update history
        await History.updateHistory({ approverId, approveDate, historyId });

        // Get book ID associated with the history record
        const bookId = await History.getBookIdByHistory(historyId);

        // Update book status to 'available'
        await History.updateBookStatus({ bookId, status: 'available' });

        res.status(200).json({ message: 'History record disapproved and book status updated successfully.' });
    } catch (err) {
        console.error('Error disapproving lender:', err);
        res.status(500).json({ message: err.message || 'Server error' });
    }
};
