const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');

// Dashboard Route
router.get('/', dashboardController.getDashboardStats);

module.exports = router;
