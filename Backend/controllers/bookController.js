const Book = require('../models/bookModel');
const BASE_URL = process.env.BASE_URL || 'http://localhost:5000';

exports.getAllBooks = async (req, res) => {
    try {
        const books = await Book.findAll();

        // Append BASE_URL to book_image paths
        const booksWithBaseUrl = books.map((book) => ({
            ...book,
            book_image: `${BASE_URL}/${book.book_image}`, // Add base URL to the image path
        }));

        res.status(200).json(booksWithBaseUrl);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.addBook = async (req, res) => {
    const { book_name, book_details,category } = req.body;

    if (!book_name || !book_details || !req.file) {
        return res.status(400).json({ message: 'All fields including an image are required' });
    }

    const book_image = req.file.path; // Use resized image path

    try {
        const newBook = await Book.create({ book_name, book_details, book_image,category });
        res.status(201).json({ message: 'Book added', book: newBook });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.editBook = async (req, res) => {
    const { id } = req.params;
    const { book_name, book_details, category, status } = req.body;
    const book_image = req.file?.path; // Optional image update

    // Build the update object dynamically from the provided fields
    const updateFields = {};
    if (book_name !== undefined) updateFields.book_name = book_name;
    if (book_details !== undefined) updateFields.book_details = book_details;
    if (status !== undefined) updateFields.status = status;
    if (category !== undefined) updateFields.category = category;
    if (book_image) updateFields.book_image = book_image;

    // Check if there are fields to update
    if (Object.keys(updateFields).length === 0) {
        return res.status(400).json({ message: 'No fields provided for update' });
    }

    try {
        const updatedBook = await Book.edit({ id, ...updateFields });
        res.status(200).json({ message: 'Book updated successfully', book: updatedBook });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: err.message || 'Server error' });
    }
};

exports.editBookStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    if (!['available', 'pending', 'borrowed', 'disabled'].includes(status)) {
        return res.status(400).json({ message: 'Invalid status value' });
    }

    try {
        const updatedStatus = await Book.editStatus({ id, status });
        res.status(200).json({ message: 'Book status updated successfully', book: updatedStatus });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: err.message || 'Server error' });
    }
};

exports.deleteBook = async (req, res) => {
    const { id } = req.params;

    try {
        await Book.delete(id);
        res.status(200).json({ message: 'Book deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: err.message || 'Server error' });
    }
};