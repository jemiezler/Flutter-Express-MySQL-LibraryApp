const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { JWT_KEY } = require('../config/config');
const User = require('../models/userModel');

exports.login = async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password are required' });
    }

    try {
        const user = await User.findByUsername(username);
        if (!user) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }       

        const token = jwt.sign({ id: user.id, role: user.role }, JWT_KEY, { expiresIn: '1d' });
        res.status(200).json({ token });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.register = async (req, res) => {
    const { username, password, name, phoneNumber } = req.body;

    if (!username || !password || !name) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await User.create({ username, password: hashedPassword, name, phoneNumber });
        res.status(201).json({ message: 'User registered', user: newUser });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.logout = (req, res) => {
    res.status(200).json({ message: 'Logged out successfully' });
};

exports.getUsername = (req, res) => {
    if (!req.user) {
        return res.status(500).json({ message: 'User not found in request' });
    }
    res.status(200).json({ decoded: req.user });
};
