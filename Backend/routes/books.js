const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');
const { upload, resizeImage } = require('../middlewares/upload');


// Book Management Routes
router.get('/', bookController.getAllBooks);
router.post('/', upload.single('book_image'), resizeImage , bookController.addBook);
router.put('/:id', upload.single('book_image'), resizeImage, bookController.editBook);
router.patch('/status/:id', bookController.editBookStatus);
router.delete('/:id', bookController.deleteBook);

// // Approval & Disapproval for Books
// router.post('/approve/lender/:history_id', bookController.approveBook);
// router.post('/disapprove/lender/:history_id', bookController.disapproveBook);

module.exports = router;
