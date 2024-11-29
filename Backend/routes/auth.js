const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { verifyUser, verifyLender } = require('../middlewares/authMiddleware');

// Authentication Routes
router.post('/login', authController.login);
router.post('/register', authController.register);
router.post('/logout', authController.logout);
router.get('/username', verifyUser, authController.getUsername);

module.exports = router;
