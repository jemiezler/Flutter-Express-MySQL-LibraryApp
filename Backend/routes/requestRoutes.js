const express = require('express');
const router = express.Router();
const requestController = require('../controllers/requestController');

// Route for staff to view pending requests
router.post('/', requestController.requestBook);
router.get('/staff', requestController.getStaffRequests);

module.exports = router;
