const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const session = require('express-session');
const helmet = require('helmet');
const dotenv = require('dotenv');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const path = require('path');

// Load environment variables
dotenv.config();

const app = express();

// Import database connection
const db = require('./config/db');

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
app.use(morgan('dev'));
app.use(helmet());
app.use(
    session({
        secret: process.env.SESSION_SECRET || 'defaultsecret',
        resave: false,
        saveUninitialized: true,
        cookie: { secure: false }, // Change to `true` when using HTTPS
    })
);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Route Imports
const authRoutes = require('./routes/auth');
const bookRoutes = require('./routes/books');
const historyRoutes = require('./routes/history');
// const statusRoutes = require('./routes/status');
const dashboardRoutes = require('./routes/dashboard');
const requestRoutes = require('./routes/requestRoutes');

// Use Routes
app.use('/auth', authRoutes);        // Authentication and User Routes
app.use('/books', bookRoutes);      // Book Management Routes
app.use('/history', historyRoutes); // Borrowing/Returning History Routes
app.use('/dashboard', dashboardRoutes); // Dashboard Stats
app.use('/request', requestRoutes); // request routes Stats
// app.use('/status', statusRoutes);   // Book Status Routes
// app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Error Handling Middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal server error', error: err.message });
});

// Server Listener
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
