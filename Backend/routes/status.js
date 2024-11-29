const express = require('express');
const router = express.Router();
const statusController = require('../controllers/statusController');

// Status-Checking Routes
router.get('/borrower', statusController.getBorrowerStatus);
router.get('/return', statusController.getReturnStatus);
router.get('/request/lender', statusController.getPendingRequests);

module.exports = router;
