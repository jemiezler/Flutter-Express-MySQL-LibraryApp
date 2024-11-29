const multer = require('multer');
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const BASE_URL = process.env.BASE_URL || 'http://192.168.1.19:5000';

// Temporary storage for original file
const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
    console.log('File filter triggered');
    console.log('Received file:', file);
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('File must be an image'), false);
    }
};

const upload = multer({
    storage,
    fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max file size
});

// Middleware to resize and save the file
const resizeImage = async (req, res, next) => {
    if (!req.file) {
        return next(); // Skip if no file uploaded
    }
    console.log('File received by Multer:', req.file);
    try {
        const uniqueFilename = `uploads/${Date.now()}-${Math.round(
            Math.random() * 1e9
        )}.jpeg`;

        // Process the image with Sharp
        await sharp(req.file.buffer)
            .resize(800, 800, { fit: 'inside' }) // Resize to max dimensions
            .toFormat('jpeg') // Convert to JPEG
            .jpeg({ quality: 80 }) // Adjust quality to reduce file size
            .toFile(uniqueFilename);

        // Set the path of the processed image in the request object
        req.file.path = uniqueFilename;
        next();
    } catch (err) {
        console.error('Error processing image:', err);
        return res.status(500).json({ message: 'Error processing image' });
    }
};

module.exports = { upload, resizeImage };
