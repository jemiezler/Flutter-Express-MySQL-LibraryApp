const express = require('express');
const router = express.Router();
const historyController = require('../controllers/historyController');
const { checkRole } = require('../middlewares/authMiddleware');

// Borrowing and Returning History Routes
// router.get('/borrower', historyController.getBorrowerHistory);
// router.post('/lender', historyController.getLenderHistory);
// router.post('/staff', historyController.getStaffHistory);
router.get('/', historyController.getAllHistory);

// Approve a history record
router.post('/approve/:history_id', checkRole('lender'),historyController.approveLender);

// Disapprove a history record
router.post('/disapprove/:history_id', checkRole('lender'),historyController.disapproveLender);

router.patch("/:id/staff", historyController.updateStaffAndDateTime);

module.exports = router;
