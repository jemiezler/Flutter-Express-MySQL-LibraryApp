const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// User Management Routes
router.get('/status', userController.getBorrowerStatus);
router.post('/return/borrower', userController.returnBorrowedBooks);

module.exports = router;
